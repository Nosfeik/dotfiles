#!/usr/bin/env python3
"""Private mock D-Bus only: no connection to asusd or hardware writes."""
import json
import os
from pathlib import Path
import select
import subprocess
import time
from gi.repository import Gio, GLib

assert os.environ.get('BATTERY_TEST_PRIVATE_BUS') == '1', 'Run via dbus-run-session'
connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
name, path, interface = 'xyz.ljones.Asusd', '/xyz/ljones', 'xyz.ljones.Platform'
value = 80
info = Gio.DBusNodeInfo.new_for_xml('''<node><interface name="xyz.ljones.Platform">
<property name="ChargeControlEndThreshold" type="y" access="read"/>
</interface></node>''').interfaces[0]
connection.register_object_with_closures2(path, info, None, lambda *args: GLib.Variant('y', value), None)

def ownership(method):
    args = GLib.Variant('(su)', (name, 0)) if method == 'RequestName' else GLib.Variant('(s)', (name,))
    connection.call_sync('org.freedesktop.DBus', '/org/freedesktop/DBus', 'org.freedesktop.DBus',
                         method, args, None, Gio.DBusCallFlags.NONE, 2000, None)

ownership('RequestName')
env = dict(os.environ, DBUS_SYSTEM_BUS_ADDRESS=os.environ['DBUS_SESSION_BUS_ADDRESS'])
script = Path(__file__).resolve().parents[1]/'payload/scripts/battery-indicator/charge-limit.js'
bridge = subprocess.Popen(['gjs', '-m', str(script)], env=env, stdin=subprocess.PIPE,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def expect(expected):
    deadline = time.monotonic() + 4
    while time.monotonic() < deadline:
        while GLib.MainContext.default().pending():
            GLib.MainContext.default().iteration(False)
        if select.select([bridge.stdout], [], [], .01)[0]:
            assert json.loads(bridge.stdout.readline()) == {'threshold': expected}
            return
    raise AssertionError('Missing D-Bus event')

def change(new_value):
    global value
    value = new_value
    connection.emit_signal(None, path, 'org.freedesktop.DBus.Properties', 'PropertiesChanged',
                           GLib.Variant('(sa{sv}as)', (interface, {'ChargeControlEndThreshold': GLib.Variant('y', value)}, [])))

try:
    expect(80)
    change(75); expect(75)
    change(0); expect(None)
    change(80); expect(80)
    ownership('ReleaseName'); expect(None)
    value = 79
    ownership('RequestName'); expect(79)
    assert not select.select([bridge.stdout], [], [], .2)[0], 'Unexpected polling/output'
    bridge.stdin.close()
    assert bridge.wait(timeout=3) == 0
    assert not bridge.stderr.read(), 'Unexpected bridge diagnostics'
    print('Private D-Bus: changes, invalid data, daemon loss/recovery, idle silence, EOF exit: OK')
finally:
    if bridge.poll() is None:
        bridge.kill(); bridge.wait()
