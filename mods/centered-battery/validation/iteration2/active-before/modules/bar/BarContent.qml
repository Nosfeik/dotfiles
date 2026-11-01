import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.bar.workspaces
import qs.modules.theme
import qs.modules.bar.clock
import qs.modules.bar.systray
import qs.modules.widgets.overview
import qs.modules.widgets.dashboard
import qs.modules.widgets.powermenu
import qs.modules.widgets.presets
import qs.modules.corners
import qs.modules.components
import qs.modules.services
import qs.modules.globals
import qs.modules.bar
import qs.config
import "." as Bar

Item {
    id: root

    // roadie: the farewell. The bar's pills fade to black while the notch is
    // still on its way over, instead of being wiped out by its edge.
    opacity: ShellFarewell.chromeOpacity

    required property ShellScreen screen

    property string barPosition: (Config.bar && Config.bar.position !== undefined && ["top", "bottom", "left", "right"].includes(Config.bar.position) ? Config.bar.position : "top")
    property string orientation: barPosition === "left" || barPosition === "right" ? "vertical" : "horizontal"

    // roadie: slides the bar out past the screen edge (progress 0)
    // and back into place (1), in step with the frame.
    // (On a boot the bar is held away and arrives on its own slide instead,
    // so the chrome offset is skipped: barChrome is 1 then.)
    readonly property real enterX: orientation === "vertical" ? (barPosition === "left" ? -1 : 1) * (totalBarWidth + frameOffset) * (1 - ShellTransitions.barChrome) : 0
    readonly property real enterY: orientation === "horizontal" ? (barPosition === "top" ? -1 : 1) * (totalBarHeight + frameOffset) * (1 - ShellTransitions.barChrome) : 0

    // Auto-hide properties
    onPinnedChanged: {
        if (Config.bar && Config.bar.pinnedOnStartup !== pinned) {
            Config.bar.pinnedOnStartup = pinned;
        }
    }

    property bool pinned: (Config.bar && Config.bar.pinnedOnStartup !== undefined ? Config.bar.pinnedOnStartup : true)

    // Keybind toggle (SUPER+SHIFT+B by default). Unpinning also drops any
    // pending hover reveal so the bar hides immediately instead of after
    // the mouse-leave delay.
    Connections {
        target: GlobalStates
        function onBarPinToggled() {
            root.pinned = !root.pinned;
            if (!root.pinned) {
                root.hoverActive = false;
                root.hideDelayTimer.stop();
            }
        }
    }

    // Monitor reference and reference to toplevels on monitor
    readonly property var compositorMonitor: AxctlService.monitorFor(screen)
    readonly property var toplevels: (!compositorMonitor || !compositorMonitor.visibleWorkspace || !AxctlService.clients.values) ? [] : AxctlService.clients.values.filter(c => c.workspace.id === compositorMonitor.visibleWorkspace.id && c.monitor === compositorMonitor.id)

    // Fullscreen detection - scoped to this monitor so the effect only
    // applies to the screen that actually has the fullscreen window
    readonly property bool activeWindowFullscreen: CompositorData.monitorHasFullscreen(compositorMonitor)

    // This screen's own fullscreen state, set by UnifiedShellPanel from its
    // per-output hasFullscreenWindow (which also sees a game on the special
    // workspace the output has pulled up).
    property bool screenFullscreen: false

    // What actually hides the bar: a fullscreen window on THIS screen.
    //
    // Since Ambxst 1.3.9 upstream's `activeWindowFullscreen` is scoped to the
    // monitor as well (it used to be the focused toplevel, one window for the
    // whole session, which hid every bar at once and put this one back over
    // the game the moment focus left it). The panel's state is the one used
    // here because it sees more than that scan does: a game on the special
    // workspace the output has pulled up, and Hyprland's own record of a
    // window where axctl's is late or stale.
    readonly property bool fullscreenHidden: screenFullscreen

    // ─── follow the focused screen ─────────────────────────────────────
    // A pinned bar shows on the focused screen only; when focus moves it
    // slides out here and in there, taking its space with it, so the windows
    // on both screens move in step. The focused monitor is latched from the
    // compositor abstraction and never treated as "none" (-1) once known, so
    // a transient empty value cannot hide every bar at once.
    property int focusedMonId: -1
    Connections {
        target: AxctlService
        function onFocusedMonitorChanged() {
            const m = AxctlService.focusedMonitor;
            if (m && m.id !== undefined && m.id !== null)
                root.focusedMonId = m.id;
        }
    }
    readonly property bool screenFocused: !!compositorMonitor && compositorMonitor.id === focusedMonId
    readonly property bool awayHidden: BarSlideSync.followFocus && focusedMonId >= 0 && !screenFocused
    // Everything the deliberate slide responds to.
    // roadie: at boot the bar is held away until the shell has entered (and
    // unlocked, if it locks), so it arrives with this slide rather than with
    // the notch and dock.
    readonly property bool barAway: fullscreenHidden || awayHidden || ShellTransitions.barHeld

    // The hide a fullscreen window causes gets its own movement channel.
    //
    // It is not the hover auto-hide: it is the shell leaving the screen, and
    // the exclusive zone released with it sets the compositor's own window
    // move going at the same instant. The stock 150 ms cross-fade blinked the
    // bar out and left the windows drifting after it for another third of a
    // second. This slides instead -- one unhurried travel past the screen
    // edge at full opacity, timed to land with the windows, ease-in-out on
    // the way out and ease-out on the way home -- which is how the shell's own
    // enter and leave read.
    //
    // How long depends on how much is moving. A bar contained in the frame is
    // a slab the width (or height) of the screen with the frame's wrap around
    // it, and 1.6 x animDuration suits that mass; the same time on a strip of
    // pills with nothing behind them read as sluggish. So: contained in the
    // frame 1.6, a frame or a bar background without that 1.2, pills alone
    // (no frame, no bar background) 0.9.
    readonly property bool slideHasFrame: (Config.bar && Config.bar.frameEnabled !== undefined) ? Config.bar.frameEnabled : false
    readonly property real fsSlideFactor: root.actualContainBar ? 1.6 : ((root.slideHasFrame || Config.showBackground) ? 1.2 : 0.9)
    // Settings > Roadie, barSlideMode: "roadie" = this slide, for the duration
    // the user typed or the automatic one above; "immediate" = 0 ms; "stock" =
    // upstream's motion instead -- the quick half-animDuration hide and reveal,
    // no staging, nothing synced with the windows (slideStock below). The
    // space the bar holds is still released and taken back, at once: that is
    // a fix, not a style.
    readonly property bool slideStock: RoadieSettings.barSlideMode === "stock"
    readonly property int fsSlideAuto: Math.round((Config.animDuration !== undefined ? Config.animDuration : 300) * root.fsSlideFactor)
    readonly property int fsSlideDuration: RoadieSettings.barSlideMode === "immediate" ? 0
        : (root.slideStock ? Math.round((Config.animDuration !== undefined ? Config.animDuration : 300) / 2)
        : (RoadieSettings.barSlideDuration > 0 ? RoadieSettings.barSlideDuration : root.fsSlideAuto))
    // frameMode: the frame's collapse and return around a fullscreen window
    // (and the stage timers that pace them). Automatic = Ambxst's animation
    // speed; "stock" = upstream, which does not animate it at all.
    readonly property int frameAnim: RoadieSettings.frameMode !== "roadie" ? 0 : (RoadieSettings.frameDuration > 0 ? RoadieSettings.frameDuration : (Config.animDuration !== undefined ? Config.animDuration : 0))

    // Upstream's motion: straight to the target on the quick curve, the space
    // following at once. `zoneTarget` is separate because a hover reveal of an
    // away bar must not take space back.
    function fsQuick(target, zoneTarget) {
        const anim = (Config.animDuration !== undefined ? Config.animDuration : 0);
        root.fsDuration = Math.round(anim / 2);
        root.fsEasing = Easing.OutCubic;
        root.fsBezier = [];
        root.zoneDuration = 0;
        root.fsTarget = target;
        root.zoneProgress = zoneTarget;
        root.fsProgress = target;
    }

    // 1 = in place, 0 = past the screen edge.
    property real fsProgress: 1
    // Set imperatively BEFORE fsProgress, so the Behavior reads this run's
    // values whatever order the bindings happen to run in.
    property int fsDuration: 0
    property int fsEasing: Easing.OutCubic
    // Where fsProgress was last sent, so a reveal change that lands in the
    // same tick as the fullscreen change can tell it is asking for the same
    // thing and leave the deliberate timing alone.
    property real fsTarget: 1
    // How much of the bar's exclusive zone is held: 1 all, 0 none. Walked
    // along the same curve as fsProgress, from the same instant, so the
    // windows the compositor lays out against it move in lockstep with the
    // pills and the frame slab (shell.qml scales the reserved size by this;
    // BarSlideSync holds the compositor's own move animation near-instant
    // meanwhile). Only deliberate and quick fullscreen hides drive it -- a
    // hover reveal while hidden must not take space back -- which is why it
    // is a separate value from fsProgress with its own animation parameters.
    property real zoneProgress: 1
    property int zoneDuration: 0
    property int zoneEasing: Easing.OutCubic
    property var zoneBezier: []
    Behavior on zoneProgress {
        enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
        NumberAnimation {
            duration: root.zoneDuration
            easing.type: root.zoneEasing
            easing.bezierCurve: root.zoneBezier
        }
    }
    // For the deliberate slide the curve is a BezierSpline that BarSlideSync
    // also hands to Hyprland for `windowsMove`, so the bar and the windows
    // moving into (or out of) its space follow the same function of time.
    property var fsBezier: []

    Behavior on fsProgress {
        enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
        NumberAnimation {
            duration: root.fsDuration
            easing.type: root.fsEasing
            easing.bezierCurve: root.fsBezier
        }
    }

    // `deliberate` is the fullscreen state change itself; a hover while the
    // screen is already hiding is a quick reveal and keeps the stock timing.
    function fsRetarget(deliberate) {
        if (!root.pinned)
            return; // stock auto-hide owns an unpinned bar
        if (root.slideStock) {
            root.fsQuick((root.barAway && !root.reveal) ? 0 : 1, root.barAway ? 0 : 1);
            return;
        }
        const anim = (Config.animDuration !== undefined ? Config.animDuration : 0);
        root.fsDuration = deliberate ? root.fsSlideDuration : Math.round(anim / 2);
        // Ease in and out both ways. Pure OutCubic front-loads the travel, so
        // the bar covered most of the distance in the first third and crawled
        // the rest -- it read as arriving too fast and then hanging about.
        if (deliberate && root.screenFullscreen)
            return; // the covered screen's exit is staged by fsStage below
        if (deliberate && root.stage.startsWith("in-"))
            return; // the frame is coming back first; the slide follows it
        if (deliberate) {
            const want = root.barAway;
            // Already heading there on the deliberate slide (a hover on this
            // away bar got in first): leave it be.
            if (root.fsTarget === (want ? 0 : 1) && root.fsDuration === root.fsSlideDuration)
                return;
            root.fsEasing = Easing.BezierSpline;
            root.fsBezier = BarSlideSync.bezier.concat([1, 1]);
            // The slide and the exclusive-zone change both wait for the
            // compositor to have the retuned window move, so bar, frame slab
            // and windows start on the same curve at the same instant. Off
            // Hyprland the callback runs synchronously.
            root.fsTarget = want ? 0 : 1;
            BarSlideSync.tune(root.fsSlideDuration, function() {
                // An abandoned move must not leave its intent behind: fsTarget
                // was set above, before the compositor round trip, and the
                // "already heading there" guards (here, in fsAutoHide and in
                // fsRevealCheck) compare against it. A fullscreen state that
                // flickered during those ~60 ms -- closing a game tends to
                // report gone, back, gone -- dropped the slide here with
                // fsTarget still saying 1, and every later attempt then
                // believed the bar was on its way in: it stayed out until a
                // workspace switch went round the guard.
                if (root.barAway !== want) {
                    root.fsTarget = -1;
                    return; // superseded by a newer change
                }
                if (root.screenFullscreen) {
                    root.fsTarget = -1;
                    return; // this screen became the covered one meanwhile; fsStage owns it
                }
                // The bar's space goes in one step; Hyprland moves the windows
                // into it on the slide's own duration and curve (tuned
                // above). Walking it every frame resized every window on the
                // screen every frame, and heavy clients stalled the slide.
                root.zoneDuration = 0;
                root.fsProgress = root.fsTarget;
                root.zoneAfterFrames(root.fsTarget);
            }, true);
            return;
        }
        root.fsEasing = Easing.OutCubic;
        root.fsBezier = [];
        // The deliberate target comes from fullscreenHidden ALONE. Inside its
        // change handler `reveal` has not been re-evaluated yet -- QML
        // dirtiness travels down the notify chain in signal order, and
        // reveal -> shouldAutoHide -> fsEngaged is still stale here -- so on
        // the way out it still read true, the target came out as 1 (where
        // the bar already was) and nothing slid; the only movement was the
        // deferred reveal check's 150 ms hover-hide, arriving 150 ms late.
        // A hover that is genuinely holding the bar up is still honoured:
        // the deferred check runs after the bindings settle and retargets.
        root.fsTarget = deliberate ? (root.barAway ? 0 : 1)
                                   : ((root.barAway && !root.reveal) ? 0 : 1);
        root.fsProgress = root.fsTarget;
    }

    // The auto-hide slide of an unpinned bar: in when revealed (hover, an
    // open notch), out when not, on the deliberate slide's duration and curve
    // both ways -- and, exactly as on a screen hiding in sympathy with a
    // fullscreen window, the bar's space goes with it: the exclusive zone is
    // walked along the slide once the compositor has the retuned window
    // move, so the windows shrink as the bar arrives and grow back as it
    // leaves, in lockstep. Deferred from onRevealChanged so `reveal` is
    // settled.
    function fsAutoHide() {
        const want = root.reveal;
        if (root.slideStock) {
            // An unpinned bar's space follows its reveal; a pinned one that is
            // only away (unfocused screen) keeps none while away.
            root.fsQuick(want ? 1 : 0, root.pinned ? (root.barAway ? 0 : 1) : (want ? 1 : 0));
            return;
        }
        // Already heading there on the deliberate slide: leave it be.
        if (root.fsTarget === (want ? 1 : 0) && root.fsDuration === root.fsSlideDuration)
            return;
        root.fsDuration = root.fsSlideDuration;
        root.fsEasing = Easing.BezierSpline;
        root.fsBezier = BarSlideSync.bezier.concat([1, 1]);
        root.fsTarget = want ? 1 : 0;
        BarSlideSync.tune(root.fsSlideDuration, function() {
            if (root.reveal !== want) {
                root.fsTarget = -1; // see fsRetarget: no stale intent
                return; // superseded
            }
            // One step for the space, Hyprland moves the windows (see fsRetarget).
            root.zoneDuration = 0;
            root.fsProgress = root.fsTarget;
            root.zoneAfterFrames(root.fsTarget);
        }, true);
    }

    // The bar's space, handed to the compositor a couple of drawn frames after
    // the slide starts. Hyprland moves the windows as soon as it has the new
    // zone, while the bar's first moved frame is only drawn a frame or two
    // later: committed together, the windows ran ~2 frames ahead of the bar
    // all the way (the gap between them swung from 4 to 11 px mid-slide).
    // Measured on a virtual screen: 1 frame keeps it within ~1 px of the
    // resting gap both ways (2 and 3 frames put the windows behind).
    // On his real monitors (2026-10-13, 165 and 60 Hz) that frame left the
    // windows a steady ~0.75 px behind (2 px at the fastest part); handed over
    // at once they sit ~0.6 px behind, at worst 1 px on the 165 Hz screen:
    // what is left is Hyprland placing windows on whole pixels. 0 = at once.
    readonly property int zoneLagFrames: 0
    function zoneAfterFrames(target) {
        if (root.zoneLagFrames <= 0) {
            zoneLag.running = false;
            root.zoneProgress = target;
            return;
        }
        zoneLag.target = target;
        zoneLag.left = root.zoneLagFrames;
        zoneLag.running = true;
    }
    FrameAnimation {
        id: zoneLag
        property real target: 1
        property int left: 0
        running: false
        onTriggered: {
            if (--left > 0)
                return;
            running = false;
            // Superseded meanwhile (the slide turned round): its own call wins.
            if (root.fsTarget === target)
                root.zoneProgress = target;
        }
    }

    onBarAwayChanged: root.fsRetarget(true)

    // ─── the last word ─────────────────────────────────────────────────
    // Everything above reacts to changes, several of them through an async
    // round trip, in handler orders QML does not define. Once things have
    // been quiet for longer than any of it takes, compare where the bar is
    // with where it should be and put it right: a pinned bar that is not
    // away must be fully in, with its space; one that is away (or covered)
    // and not held up by a hover or an open notch must be fully out. A
    // warning says so, because it means a race got past the rest.
    property int settleTries: 0
    Timer {
        id: settleTimer
        interval: root.fsSlideDuration + (Config.animDuration !== undefined ? Config.animDuration : 300) + 500
        onTriggered: root.fsSettle()
    }
    function fsSettleArm() {
        root.settleTries = 0;
        settleTimer.restart();
    }
    onStageChanged: root.fsSettleArm()
    Connections {
        target: root
        function onBarAwayChanged() { root.fsSettleArm(); }
        function onScreenFullscreenChanged() { root.fsSettleArm(); }
        function onRevealChanged() { root.fsSettleArm(); }
    }
    function fsSettle() {
        if (!root.pinned || root.stage !== "")
            return;
        const shouldBeIn = !root.barAway && !root.screenFullscreen;
        let wrong = false;
        if (shouldBeIn)
            wrong = root.fsProgress < 1 || root.zoneProgress < 1;
        else if (!root.reveal)
            wrong = root.fsProgress > 0 || root.zoneProgress > 0;
        if (!wrong) {
            root.settleTries = 0;
            return;
        }
        root.settleTries += 1;
        console.warn("BarContent: bar stranded on", (root.screen ? root.screen.name : "?"), "-- should be", shouldBeIn ? "in" : "out",
                     "fsProgress", root.fsProgress, "zoneProgress", root.zoneProgress, "fsTarget", root.fsTarget, "try", root.settleTries);
        root.fsTarget = -1;
        if (root.settleTries >= 3) {
            // The synced slide keeps failing: take the end state outright.
            root.fsDuration = 0;
            root.zoneDuration = 0;
            root.fsTarget = shouldBeIn ? 1 : 0;
            root.fsProgress = root.fsTarget;
            root.zoneProgress = root.fsTarget;
            return;
        }
        if (root.screenFullscreen)
            root.fsStage(true);
        else
            root.fsRetarget(true);
        settleTimer.restart();
    }

    // ─── the covered screen ────────────────────────────────────────────
    // On the screen a fullscreen window itself covers, the chrome leaves and
    // returns in stages, the way the shell's own enter and leave do:
    //
    //   window arrives:  hold while the compositor brings it on screen
    //                    -> bar slides out, the frame's slab following it
    //                       back to the plain gutter (the wrap around the bar
    //                       keeps its full thickness meanwhile, so the bar's
    //                       edge is never exposed)
    //                    -> gutter collapses to nothing, corners go sharp
    //   window leaves:   gutter grows back, corners round
    //                    -> bar slides in (with the windows, via fsRetarget)
    //
    // frameCollapse is what ScreenFrameContent scales the base gutter and the
    // inner radius by on this screen: 1 in place, 0 gone.
    property real frameCollapse: 1
    property int frameDuration: 0
    property int frameEasing: Easing.OutCubic
    property var frameBezier: []
    Behavior on frameCollapse {
        enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
        NumberAnimation {
            duration: root.frameDuration
            easing.type: root.frameEasing
            easing.bezierCurve: root.frameBezier
        }
    }
    // The inner corners' rounding, its own channel: 1 round, 0 sharp. Tied to
    // the gutter's value the corners went sharp in the first few frames of an
    // ease-out; on the timeline they straighten first, over their own S-curve,
    // and the gutter's collapse starts partway through -- two motions with an
    // overlap, reading as one. The way in is the reverse: gutter, then corners.
    property real cornerCollapse: 1
    property int cornerDuration: 0
    property var cornerBezier: []
    Behavior on cornerCollapse {
        enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
        NumberAnimation {
            duration: root.cornerDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.cornerBezier
        }
    }
    // Timeline proportions of animDuration: how long the corners take, and
    // how far into them the gutter starts (and, coming in, how far into the
    // gutter the corners start).
    // Out only. Coming back in, the gutter and the corners return together
    // as one motion; that read better than a staggered arrival.
    readonly property real cornerSpan: 0.8
    readonly property real stagger: 0.35
    property string stage: ""
    Timer {
        id: stageTimer
        onTriggered: root.fsStageAdvance()
    }

    onScreenFullscreenChanged: root.fsStage(root.screenFullscreen)

    // An OPENED notch (launcher, dashboard, power menu, tools) on a covered
    // screen already brings the bar and its pills in over the window. The
    // frame comes with them, gutter and corners as one motion the way it
    // returns when the window leaves, and goes again -- corners first, then
    // the gutter -- when the notch closes, so the three read as one piece. No
    // space is reserved for it: the window underneath does not resize. A
    // notch that is only peeking (hover, a notification) leaves the frame
    // away.
    readonly property bool coveredOpen: root.screenFullscreen && root.notchOpen && RoadieSettings.notchCoverMode === "roadie"
    onCoveredOpenChanged: {
        if (!root.pinned || !root.screenFullscreen)
            return; // the window left with the notch open: fsStage(false) owns the return
        const anim = root.frameAnim;
        stageTimer.stop();
        if (root.coveredOpen) {
            root.stage = "";
            root.frameDuration = anim;
            root.frameEasing = Easing.OutCubic;
            root.frameBezier = [];
            root.frameCollapse = 1;
            root.cornerDuration = anim;
            root.cornerBezier = [0.33, 1, 0.68, 1, 1, 1]; // OutCubic
            root.cornerCollapse = 1;
        } else {
            // Same exit as when the window arrived, from the point where the
            // bar is on its way out: corners, then the gutter.
            root.stage = "out-bar";
            root.fsStageAdvance();
        }
    }

    function fsStage(covered) {
        stageTimer.stop();
        if (!root.pinned) {
            root.stage = "";
            return;
        }
        if (root.slideStock) {
            // Upstream: no staging. The frame takes its end state (on its
            // own pace, frameMode), the bar goes on the quick curve -- next
            // turn, when barAway and reveal have caught up with this change.
            root.stage = "";
            root.frameDuration = root.frameAnim;
            root.frameEasing = Easing.OutCubic;
            root.frameBezier = [];
            root.cornerDuration = root.frameAnim;
            root.cornerBezier = [0.33, 1, 0.68, 1, 1, 1];
            root.frameCollapse = covered ? 0 : 1;
            root.cornerCollapse = root.frameCollapse;
            Qt.callLater(() => root.fsRetarget(true));
            return;
        }
        const anim = root.frameAnim;
        if (covered) {
            if (root.fsProgress <= 0 && root.fsTarget !== 1) {
                // Already out and staying out (a fast close and re-open):
                // straight to the frame.
                //
                // "Staying out" matters. A slide back in that has been ordered
                // but has not moved a pixel yet -- fsTarget 1 with fsProgress
                // still 0: the compositor round trip, a shell that is still
                // starting, a fullscreen state that reports gone, back, gone as
                // a game closes -- used to pass for "already out" here. The
                // bar was never sent out again, its slide in then finished over
                // the fullscreen window, and the mirror image of the same
                // collision left it out for good after the window had closed.
                root.fsTarget = 0;
                root.stage = "out-bar";
                root.fsStageAdvance();
            } else if (root.fsProgress < 1) {
                // Already on its way (the toplevel's activation beat the
                // compositor's event): carry on, skip the hold.
                root.stage = "out-wait";
                root.fsStageAdvance();
            } else {
                root.stage = "out-wait";
                stageTimer.interval = Math.max(1, anim > 0 ? BarSlideSync.arrivalDelayMs : 1);
                stageTimer.restart();
            }
        } else {
            // Frame back as one motion: gutter and corners together, then
            // the bar.
            //
            // Only when there is a frame to bring back. With the frame turned
            // off, or a window that was fullscreen so briefly the frame never
            // collapsed, this stage used to be a full animDuration of nothing
            // before the bar even started: on a frameless setup, switching
            // from a workspace with a fullscreen window to a normal one left
            // the screen sitting barless for a third of a second and read as
            // the bar "coming back slow". The bar then goes on the next turn
            // of the event loop instead -- not from inside this handler, where
            // barAway (downstream of screenFullscreen) has not re-evaluated.
            const frameOn = (Config.bar && Config.bar.frameEnabled !== undefined) ? Config.bar.frameEnabled : false;
            const frameAway = frameOn && (root.frameCollapse < 1 || root.cornerCollapse < 1);
            root.stage = "in-frame";
            root.frameDuration = frameAway ? anim : 0;
            root.frameEasing = Easing.OutCubic;
            root.frameBezier = [];
            root.frameCollapse = 1;
            root.cornerDuration = frameAway ? anim : 0;
            root.cornerBezier = [0.33, 1, 0.68, 1, 1, 1]; // OutCubic
            root.cornerCollapse = 1;
            stageTimer.interval = frameAway ? Math.max(1, anim) : 1;
            stageTimer.restart();
        }
    }

    function fsStageAdvance() {
        const anim = root.frameAnim;
        if (root.stage === "out-wait") {
            // Bar out. No window sync: nothing below is visible.
            root.stage = "out-bar";
            root.fsDuration = root.fsSlideDuration;
            root.fsEasing = Easing.BezierSpline;
            root.fsBezier = BarSlideSync.bezier.concat([1, 1]);
            root.fsTarget = 0;
            // Nothing below is visible: the space goes in one step.
            root.zoneDuration = 0;
            root.zoneProgress = 0;
            root.fsProgress = 0;
            // The frame goes as the bar's last pixels leave, not after a full
            // stop: at 70% of the slide's time the bar is ~90% of the way out
            // on its ease-in-out curve, and the frame's shorter collapse then
            // finishes together with it.
            stageTimer.interval = Math.max(1, anim > 0 ? Math.round(root.fsSlideDuration * 0.7) : 1);
            stageTimer.restart();
        } else if (root.stage === "out-bar") {
            // Corners first: round -> sharp on the smooth S-curve, as the bar's
            // tail hands over.
            root.stage = "out-corners";
            root.cornerDuration = Math.round(anim * root.cornerSpan);
            root.cornerBezier = BarSlideSync.bezier.concat([1, 1]);
            root.cornerCollapse = 0;
            stageTimer.interval = Math.max(1, Math.round(anim * root.stagger));
            stageTimer.restart();
        } else if (root.stage === "out-corners") {
            // Gutter, partway through the corners: a long-tailed ease-out
            // (easeOutExpo) over the full base duration, so most of the
            // travel happens at once and the last pixel or two settle onto
            // the screen edge -- the border fitting itself to the screen.
            root.stage = "";
            root.frameDuration = anim;
            root.frameEasing = Easing.BezierSpline;
            root.frameBezier = [0.16, 1, 0.3, 1, 1, 1];
            root.frameCollapse = 0;
        } else if (root.stage === "in-frame") {
            // Frame is back; now the bar, synced with the windows.
            root.stage = "";
            if (!root.barAway)
                root.fsRetarget(true);
        }
    }

    // A Connections block rather than a handler: the file already defines the
    // pinned handler upstream, and QML rejects a duplicate outright.
    Connections {
        target: root
        function onPinnedChanged() {
            // Pinning while a fullscreen window is up starts from the hidden
            // state; unpinning hands the bar back to the stock auto-hide.
            // Neither is a slide.
            root.fsDuration = 0;
            root.zoneDuration = 0;
            root.fsTarget = root.pinned ? (root.barAway ? 0 : 1) : (root.reveal ? 1 : 0);
            root.fsProgress = root.fsTarget;
            root.zoneProgress = root.fsTarget;
            stageTimer.stop();
            root.stage = "";
            root.frameDuration = 0;
            root.cornerDuration = 0;
            root.frameCollapse = (root.pinned && root.screenFullscreen) ? 0 : 1;
            root.cornerCollapse = root.frameCollapse;
        }
    }

    // On the way out `reveal` flips false in the same tick as
    // `fullscreenHidden`, and handler order between the two is not defined.
    // Retargeting synchronously here turned the deliberate 480 ms slide into
    // the 150 ms hover hide the moment it had been set up (the windows, tuned
    // to 480 ms, then trailed a bar that had already gone). Deferring lets
    // the deliberate handler finish first; if it already sent fsProgress
    // where this would, there is nothing to do.
    onRevealChanged: Qt.callLater(root.fsRevealCheck)
    function fsRevealCheck() {
        if (!root.pinned) {
            root.fsAutoHide();
            return;
        }
        // A bar that is away only because its screen is not focused behaves
        // under the pointer like an auto-hide bar: the deliberate slide, space
        // and all. The pointer often crosses the bar's edge a few ms before
        // the compositor reports the focus change (a left bar on the screen
        // entered from the left), and the quick 150 ms hover reveal here made
        // the bar snap in ahead of the windows; now hover and focus produce
        // the same motion and whichever comes second is a no-op.
        if (root.awayHidden && !root.fullscreenHidden) {
            root.fsAutoHide();
            return;
        }
        if (!(root.barAway || root.fsProgress < 1))
            return;
        const target = (root.barAway && !root.reveal) ? 0 : 1;
        if (target === root.fsTarget)
            return;
        root.fsRetarget(false);
    }

    Component.onCompleted: {
        // A screen already showing a fullscreen window when the shell starts
        // has nothing to slide out of: take the end state without animating.
        root.fsDuration = 0;
        const m = AxctlService.focusedMonitor;
        if (m && m.id !== undefined && m.id !== null)
            root.focusedMonId = m.id;
        const away = root.screenFullscreen
            || ShellTransitions.barHeld
            || (BarSlideSync.followFocus && root.focusedMonId >= 0 && !(root.compositorMonitor && root.compositorMonitor.id === root.focusedMonId));
        root.fsTarget = root.pinned ? ((away && !root.reveal) ? 0 : 1) : (root.reveal ? 1 : 0);
        root.fsProgress = root.fsTarget;
        root.zoneDuration = 0;
        root.zoneProgress = root.pinned ? (away ? 0 : 1) : (root.reveal ? 1 : 0);
        root.frameDuration = 0;
        root.cornerDuration = 0;
        root.frameCollapse = (root.pinned && root.screenFullscreen) ? 0 : 1;
        root.cornerCollapse = root.frameCollapse;
    }

    // True from the moment the slide starts until it has fully come home, so
    // the stock reveal transform and its Behavior stand aside for the whole
    // travel instead of fighting it or snapping the last pixel.
    //
    // A pinned bar engages it for fullscreen hides. An unpinned (auto-hide)
    // bar lives on it permanently: its every hide and reveal is the same
    // slide -- pills and frame slab together on the slide's curve, at full
    // opacity -- instead of the stock 150 ms cross-fade (fsAutoHide below).
    // Its space comes and goes with it (fsAutoHide), so the windows move too.
    readonly property bool fsEngaged: pinned ? (barAway || fsProgress < 1) : true

    // How far the bar is in place: 0 gone, 1 home. The frame's contain-bar
    // slab follows this instead of running its own animation off `reveal`,
    // which is a boolean that flips at one end of the travel or the other --
    // the slab collapsed out from under the pills on the way out and popped
    // in after they had already arrived on the way back.
    readonly property real barInPlace: fsEngaged ? fsProgress : (reveal ? 1 : 0)

    // The travel is exactly the distance the exclusive zone changes by
    // (bar + its outer margin + the frame's contain-bar allowance): the
    // windows and the frame slab move by that, so with the same curve the
    // three stay locked and the gap between bar and window is constant for
    // the whole slide. It is the stock hide distance, and it lands the bar's
    // far edge exactly on the screen edge. The shell leave's larger figure
    // (totalBarWidth + frameOffset) is right for a shell leave, where the
    // frame goes too; here it sent the pills 18% farther than the windows,
    // so they cleared the screen while the windows were still in the slow
    // tail of the curve, and on the way in were not visible until the
    // windows were already moving.
    readonly property real fsTravel: orientation === "vertical"
        ? bar.width + frameOffset + (barPosition === "left" ? leftOuterMargin : rightOuterMargin)
        : bar.height + frameOffset + (barPosition === "top" ? topOuterMargin : bottomOuterMargin)
    readonly property real fsX: orientation === "vertical" ? (barPosition === "left" ? -1 : 1) * fsTravel * (1 - fsProgress) : 0
    readonly property real fsY: orientation === "horizontal" ? (barPosition === "top" ? -1 : 1) * fsTravel * (1 - fsProgress) : 0

    // Whether auto-hide should be active (not pinned, or fullscreen forces it)
    readonly property bool shouldAutoHide: !pinned || fsEngaged

    onShouldAutoHideChanged: {
        if (!shouldAutoHide) {
            hoverActive = false;
            hideDelayTimer.stop();
        }
    }

    // Hover state with delay to prevent flickering
    property bool hoverActive: false

    // Track if mouse is over bar area
    readonly property bool isMouseOverBar: barMouseArea.containsMouse

    // Check if notch hover is active (for synchronized reveal when bar is at same side)
    // NOTE: We access Visibilities.notchPanels directly because UnifiedShellPanel registers itself as the panel ref
    readonly property var notchPanelRef: Visibilities.notchPanels[screen?.name ?? ""]
    readonly property string notchPosition: (Config.notchPosition !== undefined ? Config.notchPosition : "top")
    readonly property bool notchHoverActive: {
        if (barPosition !== notchPosition)
            return false;
        
        if (notchPanelRef) {
            // UnifiedShellPanel exposes 'notchHoverActive' property alias pointing to notchContent.hoverActive
            // We need to check if that property exists on the panel object
            if (typeof notchPanelRef.notchHoverActive !== 'undefined') {
                return notchPanelRef.notchHoverActive;
            }
            // Fallback for compatibility
            if (typeof notchPanelRef.hoverActive !== 'undefined') {
                return notchPanelRef.hoverActive;
            }
        }
        return false;
    }

    // Check if notch is open (dashboard, powermenu, etc.)
    readonly property var screenVisibilities: Visibilities.getForScreen(screen?.name ?? "")
    readonly property bool notchOpen: screenVisibilities ? (screenVisibilities.launcher || screenVisibilities.dashboard || screenVisibilities.powermenu || screenVisibilities.tools) : false

    // Radius logic for "Squished" style
    readonly property real outerRadius: Styling.radius(0)
    readonly property real innerRadius: (Config.bar && Config.bar.pillStyle === "squished") ? Styling.radius(0) / 2 : Styling.radius(0)
    readonly property bool pinButtonVisible: (Config.bar && Config.bar.showPinButton !== undefined ? Config.bar.showPinButton : true)

    // Reveal logic
    readonly property bool reveal: {
        // If not auto-hiding, always reveal
        if (!shouldAutoHide)
            return true;

        // This screen is the one holding the fullscreen window: the pointer
        // does not bring the bar back over it. Sweeping the cursor off the
        // game towards the next monitor crosses the bar's edge, which flashed
        // it up over the game for the hide delay. Only a notch the user has
        // deliberately opened still counts. `availableOnFullscreen` keeps its
        // meaning on the OTHER screens, which are only hiding in sympathy
        // with the focused toplevel.
        if (screenFullscreen)
            return notchOpen;

        // If fullscreen and not available on fullscreen, hide
        if (fullscreenHidden && !(Config.bar && Config.bar.availableOnFullscreen !== undefined ? Config.bar.availableOnFullscreen : false)) {
            return false;
        }

        // Show if: hovering, notch hovering (when at top), notch open
        // IMPORTANT: notchHoverActive must be checked to synchronize with notch
        return isMouseOverBar || hoverActive || notchHoverActive || notchOpen;
    }

    // Timer to delay hiding the bar after mouse leaves
    Timer {
        id: hideDelayTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (!root.isMouseOverBar) {
                root.hoverActive = false;
            }
        }
    }

    // Watch for mouse state changes
    onIsMouseOverBarChanged: {
        if (isMouseOverBar) {
            hideDelayTimer.stop();
            hoverActive = true;
        } else {
            // Si está fijada, podemos resetear el hoverActive inmediatamente
            // Si está en auto-hide, usamos el timer para dar margen
            if (shouldAutoHide) {
                hideDelayTimer.restart();
            } else {
                hoverActive = false;
            }
        }
    }

    // Integrated dock configuration
    readonly property bool integratedDockEnabled: (Config.dock && Config.dock.enabled !== undefined ? Config.dock.enabled : false) && (Config.dock && Config.dock.theme !== undefined ? Config.dock.theme : "default") === "integrated"
    // Map dock position for integrated based on orientation
    readonly property string integratedDockPosition: {
        const pos = (Config.dock && Config.dock.position !== undefined ? Config.dock.position : "center");

        if (root.orientation === "horizontal") {
            if (pos === "left" || pos === "start")
                return "start";
            if (pos === "right" || pos === "end")
                return "end";
            return "center";
        }
        
        // Vertical always falls back to center logic inside the column but we treat it as appended to group
        return "center";
    }

    // Radius helpers for dock connections
    readonly property bool dockAtStart: integratedDockEnabled && integratedDockPosition === "start"
    readonly property bool dockAtEnd: integratedDockEnabled && integratedDockPosition === "end"

    readonly property int frameOffset: (Config.bar && Config.bar.frameEnabled !== undefined ? Config.bar.frameEnabled : false) ? (Config.bar && Config.bar.frameThickness !== undefined ? Config.bar.frameThickness : 6) : 0

    // Size derived from barBg properties
    readonly property int barPadding: barBg.padding
    readonly property int topOuterMargin: (orientation === "vertical" || barPosition === "top") ? barBg.outerMargin : 0
    readonly property int bottomOuterMargin: (orientation === "vertical" || barPosition === "bottom") ? barBg.outerMargin : 0
    readonly property int leftOuterMargin: (orientation === "horizontal" || barPosition === "left") ? barBg.outerMargin : 0
    readonly property int rightOuterMargin: (orientation === "horizontal" || barPosition === "right") ? barBg.outerMargin : 0

    readonly property int contentImplicitWidth: orientation === "horizontal" ? (horizontalLoader.item && horizontalLoader.item.implicitWidth !== undefined ? horizontalLoader.item.implicitWidth : 0) : (verticalLoader.item && verticalLoader.item.implicitWidth !== undefined ? verticalLoader.item.implicitWidth : 0)
    readonly property int contentImplicitHeight: orientation === "horizontal" ? (horizontalLoader.item && horizontalLoader.item.implicitHeight !== undefined ? horizontalLoader.item.implicitHeight : 0) : (verticalLoader.item && verticalLoader.item.implicitHeight !== undefined ? verticalLoader.item.implicitHeight : 0)
    
    readonly property int barTargetWidth: orientation === "vertical" ? (contentImplicitWidth + 2 * barPadding) : 0
    readonly property int barTargetHeight: orientation === "horizontal" ? (contentImplicitHeight + 2 * barPadding) : 0

    readonly property bool actualContainBar: (Config.bar && Config.bar.containBar !== undefined ? Config.bar.containBar : false) && (Config.bar && Config.bar.frameEnabled !== undefined ? Config.bar.frameEnabled : false)
    readonly property int totalBarWidth: barTargetWidth + 
        ((root.barPosition === "left" || root.orientation === "horizontal") ? (root.frameOffset + root.leftOuterMargin) : 0) +
        ((root.barPosition === "right" || root.orientation === "horizontal") ? (root.frameOffset + root.rightOuterMargin) : 0)

    readonly property int totalBarHeight: barTargetHeight + 
        ((root.barPosition === "top" || root.orientation === "vertical") ? (root.frameOffset + root.topOuterMargin) : 0) +
        ((root.barPosition === "bottom" || root.orientation === "vertical") ? (root.frameOffset + root.bottomOuterMargin) : 0)

    // Base outer margin for reservation logic (4px + border when !containBar)
    readonly property int baseOuterMargin: barBg.outerMargin

    // Shadow logic for bar components
    readonly property bool shadowsEnabled: Config.showBackground && (!actualContainBar || (Config.bar && Config.bar.keepBarShadow !== undefined ? Config.bar.keepBarShadow : false))

    // The hitbox for the mask
    property alias barHitbox: barMouseArea

    // MouseArea for hover detection - contains bar content (like Dock)
    MouseArea {
        id: barMouseArea
        hoverEnabled: true

        // Size includes margins
        width: root.orientation === "horizontal" ? root.width : (root.reveal ? root.totalBarWidth : Math.max((Config.bar && Config.bar.hoverRegionHeight !== undefined ? Config.bar.hoverRegionHeight : 8), 4) + root.frameOffset)
        height: root.orientation === "vertical" ? root.height : (root.reveal ? root.totalBarHeight : Math.max((Config.bar && Config.bar.hoverRegionHeight !== undefined ? Config.bar.hoverRegionHeight : 8), 4) + root.frameOffset)


        // Position using x/y
        x: {
            if (root.barPosition === "right") return parent.width - width;
            return 0;
        }
        y: {
            if (root.barPosition === "bottom") return parent.height - height;
            return 0;
        }

        Behavior on x {
            enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0 && root.orientation === "vertical"
            NumberAnimation {
                duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 4
                easing.type: Easing.OutCubic
            }
        }
        Behavior on y {
            enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0 && root.orientation === "horizontal"
            NumberAnimation {
                duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 4
                easing.type: Easing.OutCubic
            }
        }

        Behavior on width {
            enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0 && root.orientation === "vertical"
            NumberAnimation {
                duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 4
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0 && root.orientation === "horizontal"
            NumberAnimation {
                duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 4
                easing.type: Easing.OutCubic
            }
        }

        // Bar content inside MouseArea (clicks pass through to children)
        Item {
            id: bar

            // roadie: drawn only once the chrome enter has begun.
            visible: ShellTransitions.chromeProgress > 0

            anchors {
                top: (root.barPosition === "top" || root.orientation === "vertical") ? parent.top : undefined
                bottom: (root.barPosition === "bottom" || root.orientation === "vertical") ? parent.bottom : undefined
                left: (root.barPosition === "left" || root.orientation === "horizontal") ? parent.left : undefined
                right: (root.barPosition === "right" || root.orientation === "horizontal") ? parent.right : undefined

                topMargin: (root.barPosition === "top" || root.orientation === "vertical") ? (root.frameOffset + root.topOuterMargin) : 0
                bottomMargin: (root.barPosition === "bottom" || root.orientation === "vertical") ? (root.frameOffset + root.bottomOuterMargin) : 0
                leftMargin: (root.barPosition === "left" || root.orientation === "horizontal") ? (root.frameOffset + root.leftOuterMargin) : 0
                rightMargin: (root.barPosition === "right" || root.orientation === "horizontal") ? (root.frameOffset + root.rightOuterMargin) : 0
            }


            // layer.enabled: true
            // layer.effect: Shadow {}

            // Opacity animation. The deliberate fullscreen slide carries the
            // bar off the screen on its own, so it travels at full opacity;
            // the quick hide on the covered screen fades as it goes.
            opacity: (root.reveal || root.fsEngaged) ? 1 : 0
            Behavior on opacity {
                enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
                NumberAnimation {
                    duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                    easing.type: Easing.OutCubic
                }
            }

            // Slide animation
            transform: [Translate { x: root.enterX; y: root.enterY }, Translate {
                x: {
                    if (!root.shouldAutoHide)
                        return 0;
                    if (root.fsEngaged)
                        return root.fsX;
                    if (root.barPosition === "left")
                        return root.reveal ? 0 : -bar.width - (root.frameOffset + root.leftOuterMargin);
                    if (root.barPosition === "right")
                        return root.reveal ? 0 : bar.width + (root.frameOffset + root.rightOuterMargin);
                    return 0;
                }
                y: {
                    if (!root.shouldAutoHide)
                        return 0;
                    if (root.fsEngaged)
                        return root.fsY;
                    if (root.barPosition === "top")
                        return root.reveal ? 0 : -bar.height - (root.frameOffset + root.topOuterMargin);
                    if (root.barPosition === "bottom")
                        return root.reveal ? 0 : bar.height + (root.frameOffset + root.bottomOuterMargin);
                    return 0;
                }
                Behavior on x {
                    enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0 && !root.fsEngaged
                    NumberAnimation {
                        duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on y {
                    enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0 && !root.fsEngaged
                    NumberAnimation {
                        duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                        easing.type: Easing.OutCubic
                    }
                }
            }]

            states: [
                State {
                    name: "top"
                    when: root.barPosition === "top"
                    PropertyChanges {
                        target: bar
                        height: root.barTargetHeight
                    }
                },
                State {
                    name: "bottom"
                    when: root.barPosition === "bottom"
                    PropertyChanges {
                        target: bar
                        height: root.barTargetHeight
                    }
                },
                State {
                    name: "left"
                    when: root.barPosition === "left"
                    PropertyChanges {
                        target: bar
                        width: root.barTargetWidth
                    }
                },
                State {
                    name: "right"
                    when: root.barPosition === "right"
                    PropertyChanges {
                        target: bar
                        width: root.barTargetWidth
                    }
                }
            ]

            BarBg {
                id: barBg
                anchors.fill: parent
                position: root.barPosition

                Loader {
                    id: horizontalLoader
                    active: root.orientation === "horizontal"
                    anchors.fill: parent
                    sourceComponent: RowLayout {
                        spacing: 4

                        // Obtener referencia al notch de esta pantalla
                        readonly property var notchContainer: Visibilities.getNotchForScreen(root.screen?.name ?? "")

                        LauncherButton {
                            id: launcherButton
                            startRadius: root.outerRadius
                            endRadius: root.innerRadius
                            enableShadow: root.shadowsEnabled
                        }

                        Workspaces {
                            orientation: root.orientation
                            bar: QtObject {
                                property var screen: root.screen
                            }
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        LayoutSelectorButton {
                            id: layoutSelectorButton
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: (root.pinButtonVisible) ? root.innerRadius : (root.dockAtStart ? root.innerRadius : root.outerRadius)
                        }

                        // Pin button (horizontal)
                        Loader {
                            active: (Config.bar && Config.bar.showPinButton !== undefined ? Config.bar.showPinButton : true)
                            visible: active
                            Layout.alignment: Qt.AlignVCenter

                            sourceComponent: Button {
                                id: pinButton
                                implicitWidth: 36
                                implicitHeight: 36

                                background: StyledRect {
                                    id: pinButtonBg
                                    variant: root.pinned ? "primary" : "bg"
                                    enableShadow: root.shadowsEnabled
                                    
                                    // PinButton is typically last in group 1 (unless IntegratedDock follows at start)
                                    property real startRadius: root.innerRadius
                                    property real endRadius: root.dockAtStart ? root.innerRadius : root.outerRadius
                                    
                                    topLeftRadius: startRadius
                                    bottomLeftRadius: startRadius
                                    topRightRadius: endRadius
                                    bottomRightRadius: endRadius

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Styling.srItem("overprimary")
                                        opacity: root.pinned ? 0 : (pinButton.pressed ? 0.5 : (pinButton.hovered ? 0.25 : 0))
                                        radius: (parent.radius !== undefined ? parent.radius : 0)

                                        Behavior on opacity {
                                            enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
                                            NumberAnimation {
                                                duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                                            }
                                        }
                                    }
                                }

                                contentItem: Text {
                                    text: Icons.pin
                                    font.family: Icons.font
                                    font.pixelSize: 18
                                    color: root.pinned ? pinButtonBg.item : (pinButton.pressed ? Colors.background : (Styling.srItem("overprimary") || Colors.foreground))
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter

                                    rotation: root.pinned ? 0 : 45
                                    Behavior on rotation {
                                        enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
                                        NumberAnimation {
                                            duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                                        }
                                    }

                                    Behavior on color {
                                        enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
                                        ColorAnimation {
                                            duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                                        }
                                    }
                                }

                                onClicked: root.pinned = !root.pinned

                                StyledToolTip {
                                    show: pinButton.hovered
                                    tooltipText: root.pinned ? I18n.t("bar.tooltip.unpin_bar") : I18n.t("bar.tooltip.pin_bar")
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: root.orientation === "horizontal" && integratedDockEnabled

                            Bar.IntegratedDock {
                                bar: root
                                orientation: root.orientation
                                anchors.verticalCenter: parent.verticalCenter
                                enableShadow: root.shadowsEnabled

                                // Connect to left/right groups if at start/end
                                startRadius: root.dockAtStart ? root.innerRadius : root.outerRadius
                                endRadius: root.dockAtEnd ? root.innerRadius : root.outerRadius

                                // Calculate target position based on config
                                property real targetX: {
                                    if (integratedDockPosition === "start")
                                        return 0;
                                    if (integratedDockPosition === "end")
                                        return parent.width - width;

                                    // Center logic (reactive using parent.x + margin offset)
                                    // RowLayout has anchors.margins: 4, so offset is 4
                                    return (bar.width - width) / 2 - (parent.x + 4);
                                }

                                // Clamp the x position so it never leaves the container (preventing overlap)
                                x: Math.max(0, Math.min(parent.width - width, targetX))

                                width: Math.min(implicitWidth, parent.width)
                                height: implicitHeight
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            visible: !(root.orientation === "horizontal" && integratedDockEnabled)
                        }

                        PresetsButton {
                            id: presetsButton
                            startRadius: root.dockAtEnd ? root.innerRadius : root.outerRadius
                            endRadius: root.innerRadius
                            enableShadow: root.shadowsEnabled
                        }

                        ToolsButton {
                            id: toolsButton
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                            enableShadow: root.shadowsEnabled
                        }

                        SysTray {
                            bar: root
                            enableShadow: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        Bar.BluetoothIndicator {
                            id: bluetoothIndicator
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        Bar.BluetoothBatteryIndicator {
                            id: btBatteryIndicator
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        ControlsButton {
                            id: controlsButton
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        Bar.BatteryIndicator {
                            id: batteryIndicator
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        Clock {
                            id: clockComponent
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        PowerButton {
                            id: powerButton
                            startRadius: root.innerRadius
                            endRadius: root.outerRadius
                            enableShadow: root.shadowsEnabled
                        }
                    }
                }

                Loader {
                    id: verticalLoader
                    active: root.orientation === "vertical"
                    anchors.fill: parent
                    sourceComponent: ColumnLayout {
                        spacing: 4

                        LauncherButton {
                            id: launcherButtonVert
                            Layout.preferredHeight: 36
                            startRadius: root.outerRadius
                            endRadius: root.innerRadius
                            vertical: true
                            enableShadow: root.shadowsEnabled
                        }

                        SysTray {
                            bar: root
                            enableShadow: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        Bar.BluetoothIndicator {
                            id: bluetoothIndicatorVert
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        ToolsButton {
                            id: toolsButtonVert
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                            vertical: true
                            enableShadow: root.shadowsEnabled
                        }

                        PresetsButton {
                            id: presetsButtonVert
                            startRadius: root.innerRadius
                            endRadius: root.outerRadius
                            vertical: true
                            enableShadow: root.shadowsEnabled
                        }

                        // Center Group Container
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            ColumnLayout {
                                anchors.horizontalCenter: parent.horizontalCenter

                                // Calculate target position to be absolutely centered in the bar (vertically)
                                property real targetY: {
                                    if (!parent || !bar)
                                        return 0;

                                    // Force re-evaluation when parent moves
                                    var _trigger = parent.y;

                                    var parentPos = parent.mapToItem(bar, 0, 0);
                                    return (bar.height - height) / 2 - parentPos.y;
                                }

                                // Clamp y position
                                y: Math.max(0, Math.min(parent.height - height, targetY))

                                height: Math.min(parent.height, implicitHeight)
                                width: parent.width
                                spacing: 4

                                LayoutSelectorButton {
                                    id: layoutSelectorButtonVert
                                    bar: root
                                    layerEnabled: root.shadowsEnabled
                                    Layout.alignment: Qt.AlignHCenter
                                    startRadius: root.outerRadius
                                    endRadius: root.innerRadius
                                    vertical: true
                                }

                                Workspaces {
                                    id: workspacesVert
                                    orientation: root.orientation
                                    bar: QtObject {
                                        property var screen: root.screen
                                    }
                                    Layout.alignment: Qt.AlignHCenter
                                    startRadius: root.innerRadius
                                    endRadius: root.innerRadius
                                }

                                // Pin button (vertical)
                                Loader {
                                    active: (Config.bar && Config.bar.showPinButton !== undefined ? Config.bar.showPinButton : true)
                                    visible: active
                                    Layout.alignment: Qt.AlignHCenter
                            
                                    sourceComponent: Button {
                                        id: pinButtonV
                                        implicitWidth: 36
                                        implicitHeight: 36
                            
                                        background: StyledRect {
                                            id: pinButtonVBg
                                            variant: root.pinned ? "primary" : "bg"
                                            enableShadow: root.shadowsEnabled
                                        
                                            property real startRadius: root.innerRadius
                                            // In vertical, dock is always appended to this group if enabled
                                            property real endRadius: root.integratedDockEnabled ? root.innerRadius : root.outerRadius
                                        
                                            topLeftRadius: startRadius
                                            topRightRadius: startRadius
                                            bottomLeftRadius: endRadius
                                            bottomRightRadius: endRadius

                                            Rectangle {
                                                anchors.fill: parent
                                                color: Styling.srItem("overprimary")
                                                opacity: root.pinned ? 0 : (pinButtonV.pressed ? 0.5 : (pinButtonV.hovered ? 0.25 : 0))
                                                radius: (parent.radius !== undefined ? parent.radius : 0)

                                                Behavior on opacity {
                                                    enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
                                                    NumberAnimation {
                                                        duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                                                    }
                                                }
                                            }
                                        }

                                        contentItem: Text {
                                            text: Icons.pin
                                            font.family: Icons.font
                                            font.pixelSize: 18
                                            color: root.pinned ? pinButtonVBg.item : (pinButtonV.pressed ? Colors.background : (Styling.srItem("overprimary") || Colors.foreground))
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter

                                            rotation: root.pinned ? 0 : 45
                                            Behavior on rotation {
                                                enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
                                                NumberAnimation {
                                                    duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                                                }
                                            }

                                            Behavior on color {
                                                enabled: (Config.animDuration !== undefined ? Config.animDuration : 0) > 0
                                                ColorAnimation {
                                                    duration: (Config.animDuration !== undefined ? Config.animDuration : 0) / 2
                                                }
                                            }
                                        }

                                        onClicked: root.pinned = !root.pinned

                                        StyledToolTip {
                                            show: pinButtonV.hovered
                                            tooltipText: root.pinned ? I18n.t("bar.tooltip.unpin_bar") : I18n.t("bar.tooltip.pin_bar")
                                        }
                                    }
                                }
                            }

                            Bar.IntegratedDock {
                                bar: root
                                orientation: root.orientation
                                visible: integratedDockEnabled
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                enableShadow: root.shadowsEnabled
                                
                                startRadius: root.innerRadius
                                endRadius: root.outerRadius
                            }
                        }

                        Bar.BluetoothBatteryIndicator {
                            id: btBatteryIndicatorVert
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.outerRadius
                            endRadius: root.innerRadius
                        }

                        ControlsButton {
                            id: controlsButtonVert
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            // Heads the bottom group only while the Bluetooth
                            // battery readout above it is hidden.
                            startRadius: btBatteryIndicatorVert.visible ? root.innerRadius : root.outerRadius
                            endRadius: root.innerRadius
                        }

                        Bar.BatteryIndicator {
                            id: batteryIndicatorVert
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        Clock {
                            id: clockComponentVert
                            bar: root
                            layerEnabled: root.shadowsEnabled
                            startRadius: root.innerRadius
                            endRadius: root.innerRadius
                        }

                        PowerButton {
                            id: powerButtonVert
                            Layout.preferredHeight: 36
                            startRadius: root.innerRadius
                            endRadius: root.outerRadius
                            vertical: true
                            enableShadow: root.shadowsEnabled
                        }
                    }
                }
            }
        }
    }
}
