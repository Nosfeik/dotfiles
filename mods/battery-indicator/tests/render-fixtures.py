#!/usr/bin/env python3
"""Render real BatteryGraphic offscreen with native palettes; no live hardware.
Uses temporary qs import roots and an offscreen window, never a second desktop bar.
"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

MOD = Path(__file__).resolve().parents[1]
BASE = Path.home()/'.local/src/ambxst'
OUT = MOD.parents[1]/'docs/assets/battery-indicator'
OUT.mkdir(parents=True,exist_ok=True)
cases=[(5,'discharging'),(15,'discharging'),(35,'discharging'),(51,'discharging'),(65,'discharging'),(80,'discharging'),(80,'limit'),(100,'full'),(20,'charging'),(60,'charging'),(79,'charging'),(None,'unknown'),(0,'discharging'),(1,'discharging'),(50,'discharging'),(79.5,'limit')]
palettes={'dark':Path.home()/'.cache/ambxst/colors.json','light':BASE/'assets/colors/Catppuccin/light.json'}
with tempfile.TemporaryDirectory(prefix='battery-fixtures-') as tmp:
    root=Path(tmp)
    for folder in ('config','modules/theme','modules/bar'): (root/folder).mkdir(parents=True)
    for file in ('BatteryGraphic.qml','BatteryState.js'):shutil.copyfile(MOD/'payload/modules/bar'/file,root/'modules/bar'/file)
    (root/'config/Config.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject { property int animDuration: 0; property QtObject theme: QtObject {property string font: "Sans"} }')
    icons=(BASE/'modules/theme/Icons.qml').read_text()
    # Only fixed native glyphs; avoid starting any live singleton dependency.
    import re
    glyphs={n:re.search(r'property string '+n+r': "([^"]+)"',icons).group(1) for n in ('lightning',)}
    (root/'modules/theme/Icons.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject { property string font: "Phosphor-Bold";'+''.join('property string '+k+': '+json.dumps(v)+';' for k,v in glyphs.items())+'}')
    (root/'fixtures.json').write_text(json.dumps([{'percent':p,'state':s} for p,s in cases]))
    for theme,path in palettes.items():
        colors=json.loads(path.read_text())
        (root/'modules/theme/Colors.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject {'+''.join('property color '+k+': '+json.dumps(colors[k])+';' for k in ('green','yellow','red','background','overBackground','surfaceContainer'))+'}')
        for scale in ('1','1.6','2'):
            output=OUT/(theme+'-'+scale+'.png')
            output.unlink(missing_ok=True)
            qml='''import QtQuick
import QtQuick.Window
import Quickshell
import "modules/bar"
import qs.modules.theme
ShellRoot {
    Window {
        visible: true
        width: 880; height: 520
        Rectangle {
            id: sheet
            anchors.fill: parent
            color: Colors.background
            Text { x: 20; y: 12; text: TITLE; color: Colors.overBackground; font.pixelSize: 16 }
            Grid {
                x: 20; y: 50; columns: 4; spacing: 12
                Repeater {
                    model: CASES
                    delegate: Rectangle {
                        required property var modelData
                        width: 201; height: 104; radius: 8; color: Colors.surfaceContainer
                        BatteryGraphic { id: actual; x: 8; y: 18; percentage: modelData.percent; charging: modelData.state === "charging"; limitReached: modelData.state === "limit"; animate: false }
                        BatteryGraphic { x: 88; y: 26; scale: 2; percentage: modelData.percent; charging: modelData.state === "charging"; limitReached: modelData.state === "limit"; animate: false }
                        Text { x: 8; y: 74; text: (modelData.percent === null ? "Unknown" : modelData.percent + "%") + " · " + modelData.state; color: Colors.overBackground; font.pixelSize: 12 }
                        Component.onCompleted: {
                            const expected = modelData.percent === null ? 0 : 19 * Math.max(0, Math.min(100, modelData.percent)) / 100;
                            if (Math.abs(actual.fillWidth - expected) > 0.001) throw new Error("Fill geometry mismatch");
                        }
                    }
                }
            }
        }
        Timer { interval: 500; running: true; onTriggered: sheet.grabToImage(result => { if (!result.saveToFile(OUTPUT)) throw new Error("Screenshot failed"); Qt.quit(); }) }
    }
}'''.replace('CASES',json.dumps([{'percent':p,'state':s} for p,s in cases])).replace('TITLE',json.dumps('BatteryGraphic · '+theme+' · scale '+scale+' · normal + 2× detail')).replace('OUTPUT',json.dumps(str(output)))
            (root/'shell.qml').write_text(qml)
            env=dict(os.environ,QT_QPA_PLATFORM='offscreen',QT_QUICK_BACKEND='software',QT_SCALE_FACTOR=scale)
            run=subprocess.run(['qs','-p',str(root/'shell.qml')],env=env,capture_output=True,text=True,timeout=20)
            log=run.stdout+run.stderr
            if run.returncode or not output.exists() or any(error in log for error in ('Error:', 'Unable to assign', 'Binding loop')):raise RuntimeError(log)
            print(output.name,'OK')
