// One read-only, signal-driven bridge. No setters, shell, hardware writes or polling.
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import GioUnix from 'gi://GioUnix';

const loop = new GLib.MainLoop(null, false);
let proxy = null;
let last = '';
function publish() {
    const cached = proxy?.get_name_owner() ? proxy.get_cached_property('ChargeControlEndThreshold') : null;
    const value = cached?.unpack();
    const threshold = Number.isInteger(value) && value >= 20 && value <= 100 ? value : null;
    const line = JSON.stringify({threshold});
    if (line !== last) { print(line); last = line; }
}
// Follow daemon restarts without starting it or changing any property.
Gio.DBusProxy.new_for_bus(Gio.BusType.SYSTEM,
    Gio.DBusProxyFlags.DO_NOT_AUTO_START | Gio.DBusProxyFlags.GET_INVALIDATED_PROPERTIES,
    null, 'xyz.ljones.Asusd', '/xyz/ljones', 'xyz.ljones.Platform', null,
    (_source, result) => {
        try {
            proxy = Gio.DBusProxy.new_for_bus_finish(result);
            proxy.connect('g-properties-changed', publish);
            proxy.connect('notify::g-name-owner', publish);
        } catch (_) { /* sysfs fallback belongs to QML */ }
        publish();
    });
// Quickshell closes this pipe on shutdown. No detached/orphaned bridge remains.
const input = new Gio.DataInputStream({base_stream: new GioUnix.InputStream({fd: 0, close_fd: false})});
function readInput() {
    input.read_line_async(GLib.PRIORITY_DEFAULT, null, (stream, result) => {
        try {
            const [line] = stream.read_line_finish(result);
            if (line === null) { loop.quit(); return; }
            if (new TextDecoder().decode(line) === 'refresh') publish();
            readInput();
        } catch (_) { loop.quit(); }
    });
}
readInput();
loop.run();
