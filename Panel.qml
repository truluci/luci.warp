import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "luci.warp"
  ipcTarget: "luci.warp"
  manageIpc: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color barIconColor: warp.active ? barForeground : Qt.darker(barForeground, 1.55)
  readonly property color iconColor: warp.active ? foreground : dim

  onOpenedChanged: if (opened) {
    warp.refresh()
    warp.refreshSettings()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  Service {
    id: warp
    settings: root.settings
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function connect(): string { warp.connect(); return "ok" }
    function disconnect(): string { warp.disconnect(); return "ok" }
    function toggleWarp(): string { warp.toggleWarp(); return "ok" }
    function refresh(): string { warp.refresh(); return "ok" }
    function status(): string { return warp.statusText }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    tooltipText: "Cloudflare WARP — " + warp.statusText
    iconComponent: Component {
      Item {
        WarpIcon {
          anchors.centerIn: parent
          iconSize: Style.space(11)
          color: root.barIconColor
          badgeColor: root.urgent
          crossed: !warp.active && warp.installed && !warp.pending
          warning: warp.checkedInstall && !warp.installed
          pulsing: warp.pending
        }
      }
    }
    // Left click toggles the connection outright — that is the whole point of
    // the widget. Details live behind the right click.
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.toggle()
      else if (buttonCode === Qt.MiddleButton) warp.refresh()
      else warp.toggleWarp()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(320))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(420))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onActivateRequested: warp.toggleWarp()
      onTextKey: function(t) {
        if (t === "t" || t === "T") warp.toggleWarp()
        else if (t === "r" || t === "R") { warp.refresh(); warp.refreshSettings() }
      }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(12)

        PanelHero {
          id: hero
          width: parent.width
          title: "Cloudflare WARP"
          meta: warp.statusText
          foreground: root.foreground
          fontFamily: root.fontFamily
          iconOpacity: warp.active ? 1.0 : 0.5
          iconComponent: Component {
            WarpIcon {
              iconSize: Style.font.display
              color: root.iconColor
              badgeColor: root.urgent
              crossed: !warp.active && warp.installed && !warp.pending
              warning: warp.checkedInstall && !warp.installed
              pulsing: warp.pending
            }
          }
          trailingControl: Component {
            ToggleSwitch {
              checked: warp.active
              busy: warp.busy
              interactive: warp.installed && !warp.switchLocked
              foreground: root.foreground
              accent: Color.accent
              onToggled: warp.toggleWarp()
            }
          }
        }

        PanelSeparator {
          width: parent.width
          foreground: root.foreground
          visible: warp.installed
        }

        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: warp.installed

          InfoRow { label: "Mode"; value: warp.modeLabel }
          InfoRow { label: "Always on"; value: warp.alwaysOn ? "Yes" : "No" }
          InfoRow {
            label: "Locked by policy"
            value: "Yes"
            visible: warp.switchLocked
          }
        }

        Text {
          width: parent.width
          text: warp.installed
            ? "t toggle · r refresh · esc close"
            : "Install the cloudflare-warp package to use this widget."
          color: Qt.darker(root.foreground, 1.5)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          wrapMode: Text.WordWrap
        }
      }
    }
  }

  component InfoRow: Item {
    property string label: ""
    property string value: ""
    width: column.width
    implicitHeight: Math.max(labelText.implicitHeight, valueText.implicitHeight)

    Text {
      id: labelText
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: label
      color: Qt.darker(root.foreground, 1.4)
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }

    Text {
      id: valueText
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: value
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }
  }
}
