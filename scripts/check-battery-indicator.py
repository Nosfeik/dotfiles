#!/usr/bin/env python3
"""Read-only mod validation; never change hardware or the installed shell."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]
MOD = REPO / 'mods/battery-indicator'
BASE = Path.home() / '.local/src/ambxst'


def validate(base=BASE):
    manifest = json.loads((MOD / 'ambxst.mod.json').read_text())
    replaced = []
    for op in manifest['operations']:
        assert op['type'] == 'overlay', 'No patches required'
        source, target = MOD / op['source'], base / op['target']
        assert source.is_file()
        if target.exists():
            assert op.get('replace') is True
            assert hashlib.sha256(target.read_bytes()).hexdigest() == op['expectedSha256'], 'Upstream changed; review required'
            replaced.append(op['target'])
    assert replaced == ['modules/bar/BatteryIndicator.qml']
    return manifest


if __name__ == '__main__':
    manifest = validate()
    with tempfile.TemporaryDirectory(prefix='battery-check-') as name:
        stage = Path(name)
        for file in ('manifest.go', 'version.go'):
            (stage/file).write_text((BASE/'backend/pkg/mods'/file).read_text().replace('package mods', 'package main', 1))
        (stage/'main.go').write_text('package main\nimport("os";"fmt")\nfunc main(){_,e:=LoadManifest(os.Args[1]);if e!=nil{panic(e)};fmt.Println("Official manifest parser: OK")}')
        subprocess.run(['go','run','manifest.go','version.go','main.go',str(MOD)],cwd=stage,check=True)
        # Regression: a different upstream body must fail closed.
        fake=stage/'changed';(fake/'modules/bar').mkdir(parents=True)
        (fake/'modules/bar/BatteryIndicator.qml').write_text('changed upstream')
        try:validate(fake)
        except AssertionError:print('Changed upstream hash rejected: OK')
        else:raise AssertionError('Hash guard missing')
    for path in MOD.rglob('*.qml'):
        subprocess.run(['/usr/lib/qt6/bin/qmlformat',str(path)],stdout=subprocess.DEVNULL,check=True)
    state=(MOD/'payload/modules/bar/BatteryState.js').read_text().split('\n',1)[1]
    subprocess.run(['gjs','-c',state+'\n'+(MOD/'tests/state.js').read_text()],check=True)
    subprocess.run(['dbus-run-session','--','env','GIO_USE_VFS=local','BATTERY_TEST_PRIVATE_BUS=1','python3',str(MOD/'tests/test_bridge.py')],check=True)
    for command in manifest['commands']:assert shutil.which(command), command
    indicator=(MOD/'payload/modules/bar/BatteryIndicator.qml').read_text()
    assert 'MouseArea {' not in indicator and 'TapHandler {' not in indicator
    assert 'notifyInternal' not in indicator and 'notify-send' not in indicator
    subprocess.run(['git','diff','--check'],cwd=REPO,check=True)
    print('Overlay hash, QML syntax, state, no click/notification producer, dependencies, whitespace: OK')
