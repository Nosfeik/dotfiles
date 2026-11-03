pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// asusd platform profile (Quiet / Balanced / Performance) for the OSD.
// power-profiles-daemon can drift from asusd on this laptop, so it asks
// asusctl directly. The fan key bind changes the profile and then calls
//   qs ipc --pid <ambxst> call rog announce
Singleton {
    id: root

    property string profile: ""
    readonly property var levels: ["Quiet", "Balanced", "Performance"]
    // 1/3, 2/3, 1 for the OSD bar; 0 when unknown
    readonly property real value: (levels.indexOf(profile) + 1) / levels.length

    signal announced

    property bool _announce: false

    function refresh(announce) {
        _announce = _announce || announce;
        if (!getProc.running)
            getProc.running = true;
    }

    Process {
        id: getProc
        command: ["asusctl", "profile", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = (text || "").match(/Active profile:\s*(\S+)/);
                if (m)
                    root.profile = m[1];
                if (root._announce && m)
                    root.announced();
                root._announce = false;
            }
        }
    }

    IpcHandler {
        target: "rog"

        function announce(): void {
            root.refresh(true);
        }
        function profile(): string {
            return root.profile;
        }
    }

    Component.onCompleted: refresh(false)
}
