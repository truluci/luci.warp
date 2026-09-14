import QtQuick
import Quickshell
import Quickshell.Io

// warp-cli driver: polls connection status, exposes connect/disconnect, and
// keeps a short-lived optimistic state so the bar reacts on click rather than
// on the next poll.
Item {
  id: root

  property var settings: ({})

  property bool installed: false
  property bool checkedInstall: false
  property string status: "Unknown"   // Connected | Connecting | Disconnected | Unknown
  property string reason: ""
  property string mode: ""
  property bool alwaysOn: false
  property bool switchLocked: false
  property string lastError: ""

  // -1 while we simply follow the daemon; 0/1 while a toggle is still catching
  // up. Cleared by reconcile() as soon as the daemon agrees, or by _desiredGuard
  // if it never does.
  property int _desired: -1

  readonly property bool connected: status === "Connected"
  readonly property bool connecting: status === "Connecting"
  readonly property bool active: _desired === -1 ? (connected || connecting) : (_desired === 1)
  readonly property bool pending: _desired !== -1 || connecting
  readonly property bool busy: actionProcess.running || pending
  readonly property int refreshIntervalSec: intSetting("refreshIntervalSec", 15, 3, 3600)

  readonly property string statusText: {
    if (checkedInstall && !installed) return "warp-cli not found"
    if (lastError !== "") return lastError
    if (_desired === 1 && !connected) return "Connecting…"
    if (_desired === 0 && status !== "Disconnected") return "Disconnecting…"
    if (connecting) return reason !== "" ? "Connecting — " + humanize(reason) : "Connecting…"
    if (connected) return "Connected"
    if (status === "Disconnected") return reason !== "" ? "Disconnected — " + humanize(reason) : "Disconnected"
    return "Checking…"
  }

  readonly property string toggleHint: {
    if (checkedInstall && !installed) return "Install cloudflare-warp-bin to use this widget"
    if (switchLocked) return "WARP is locked by policy"
    return active ? "Disconnect WARP" : "Connect WARP"
  }

  readonly property string modeLabel: {
    if (mode === "") return "--"
    if (mode === "warp") return "WARP"
    if (mode === "doh") return "DNS over HTTPS"
    if (mode === "warp+doh") return "WARP + DoH"
    if (mode === "dot") return "DNS over TLS"
    if (mode === "warp+dot") return "WARP + DoT"
    if (mode === "proxy") return "Proxy"
    return mode
  }

  function setting(name, fallback) {
    var value = settings ? settings[name] : undefined
    return value === undefined || value === null ? fallback : value
  }

  function intSetting(name, fallback, min, max) {
    var value = parseInt(setting(name, fallback), 10)
    if (isNaN(value)) value = fallback
    return Math.max(min, Math.min(max, value))
  }

  // "CheckingNetwork" / "SettingsChanged" -> "checking network".
  function humanize(text) {
    return String(text || "").replace(/([a-z0-9])([A-Z])/g, "$1 $2").toLowerCase()
  }

  function refresh() {
    if (!checkedInstall) { checkInstall(); return }
    if (!installed || statusProcess.running) return
    statusProcess.command = ["warp-cli", "--no-ansi", "--no-paginate", "-j", "status"]
    statusProcess.running = true
  }

  function refreshSettings() {
    if (!installed || settingsProcess.running) return
    settingsProcess.command = ["warp-cli", "--no-ansi", "--no-paginate", "-j", "settings"]
    settingsProcess.running = true
  }

  function checkInstall() {
    if (whichProcess.running) return
    whichProcess.command = ["sh", "-c", "command -v warp-cli"]
    whichProcess.running = true
  }

  function connect() { runAction("connect", 1) }
  function disconnect() { runAction("disconnect", 0) }
  function toggleWarp() { active ? disconnect() : connect() }

  function runAction(verb, desired) {
    if (!installed || actionProcess.running) return
    lastError = ""
    _desired = desired
    _desiredGuard.restart()
    actionProcess.command = ["warp-cli", "--no-ansi", "--no-paginate", verb]
    actionProcess.running = true
  }

  // Drop the optimistic state as soon as the daemon reports what we asked for.
  function reconcile() {
    if (_desired === -1) return
    if (_desired === 1 && (connected || connecting)) clearDesired()
    else if (_desired === 0 && status === "Disconnected") clearDesired()
  }

  function clearDesired() {
    _desired = -1
    _desiredGuard.stop()
  }

  function parseStatus(text) {
    try {
      var data = JSON.parse(String(text || ""))
      status = String(data.status || "Unknown")
      reason = String(data.reason || "")
      lastError = ""
    } catch (e) {
      lastError = "Could not read WARP status"
    }
    reconcile()
  }

  function parseSettings(text) {
    try {
      var data = JSON.parse(String(text || ""))
      var s = data.settings || {}
      mode = String(s.operation_mode || "")
      alwaysOn = s.always_on === true
      switchLocked = s.switch_locked === true
    } catch (e) {
      // Settings are decoration only; a parse failure must not mask the status.
    }
  }

  function elide(text) {
    var line = String(text || "").split("\n")[0].trim()
    return line.length > 90 ? line.slice(0, 87) + "…" : line
  }

  onStatusChanged: reconcile()

  Component.onCompleted: checkInstall()

  Process {
    id: whichProcess
    running: false
    command: []
    onExited: function(exitCode) {
      root.installed = exitCode === 0
      root.checkedInstall = true
      if (root.installed) {
        root.refresh()
        root.refreshSettings()
      }
    }
  }

  Process {
    id: statusProcess
    running: false
    command: []
    stdout: StdioCollector { id: statusOut; waitForEnd: true }
    stderr: StdioCollector { id: statusErr; waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode === 0) root.parseStatus(statusOut.text)
      else root.lastError = root.elide(statusErr.text) || "warp-cli status failed"
    }
  }

  Process {
    id: settingsProcess
    running: false
    command: []
    stdout: StdioCollector { id: settingsOut; waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode === 0) root.parseSettings(settingsOut.text)
    }
  }

  Process {
    id: actionProcess
    running: false
    command: []
    stderr: StdioCollector { id: actionErr; waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.lastError = root.elide(actionErr.text) || "warp-cli command failed"
        root.clearDesired()
      }
      root.refresh()
      root.refreshSettings()
    }
  }

  // Steady-state poll.
  Timer {
    interval: root.refreshIntervalSec * 1000
    repeat: true
    running: root.installed
    onTriggered: root.refresh()
  }

  // Fast poll while a toggle or a Connecting state is still settling.
  Timer {
    interval: 700
    repeat: true
    running: root.installed && root.pending
    onTriggered: root.refresh()
  }

  // If the daemon never reaches the requested state, stop pretending it did.
  Timer {
    id: _desiredGuard
    interval: 12000
    repeat: false
    onTriggered: root._desired = -1
  }
}
