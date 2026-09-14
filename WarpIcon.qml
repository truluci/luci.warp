import QtQuick
import qs.Commons
import qs.Ui

// The Cloudflare cloud mark, drawn from primitives rather than an SVG so it
// stays crisp in a tiny bar slot (same reasoning as TailscaleIcon). The
// disconnected slash is punched out of the cloud with destination-out
// compositing, so it stays legible over a solid shape on a transparent bar.
Item {
  id: root

  property real iconSize: Style.font.icon
  property color color: Color.foreground
  property color badgeColor: Color.urgent
  property bool crossed: false
  property bool warning: false
  property bool pulsing: false

  width: iconSize
  height: iconSize
  implicitWidth: iconSize
  implicitHeight: iconSize

  onColorChanged: canvas.requestPaint()
  onCrossedChanged: canvas.requestPaint()
  onIconSizeChanged: canvas.requestPaint()

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true

    SequentialAnimation on opacity {
      running: root.pulsing
      loops: Animation.Infinite
      alwaysRunToEnd: true
      NumberAnimation { to: 0.35; duration: 620; easing.type: Easing.InOutQuad }
      NumberAnimation { to: 1.0; duration: 620; easing.type: Easing.InOutQuad }
      onRunningChanged: if (!running) canvas.opacity = 1.0
    }

    function puff(ctx, cx, cy, r) {
      ctx.beginPath()
      ctx.arc(cx, cy, r, 0, Math.PI * 2)
      ctx.fill()
    }

    onPaint: {
      var ctx = getContext("2d")
      var s = Math.min(width, height)
      ctx.reset()
      ctx.clearRect(0, 0, width, height)

      // Union of three puffs over a flat base — the puffs round the ends.
      // Each shape is filled on its own path: chaining subpaths would join
      // them with stray lines and cancel overlaps under nonzero winding.
      ctx.fillStyle = root.color
      puff(ctx, s * 0.29, s * 0.56, s * 0.20)
      puff(ctx, s * 0.50, s * 0.46, s * 0.26)
      puff(ctx, s * 0.72, s * 0.58, s * 0.18)
      ctx.beginPath()
      ctx.rect(s * 0.09, s * 0.56, s * 0.82, s * 0.28)
      ctx.fill()

      if (!root.crossed) return

      // Punch a gap, then lay the slash inside it so the bar stays readable
      // whatever shows through the transparent background.
      ctx.lineCap = "round"
      ctx.globalCompositeOperation = "destination-out"
      ctx.strokeStyle = "#000000"
      ctx.lineWidth = Math.max(3, s * 0.22)
      ctx.beginPath()
      ctx.moveTo(s * 0.14, s * 0.86)
      ctx.lineTo(s * 0.86, s * 0.14)
      ctx.stroke()

      ctx.globalCompositeOperation = "source-over"
      ctx.strokeStyle = root.color
      ctx.lineWidth = Math.max(1.5, s * 0.11)
      ctx.beginPath()
      ctx.moveTo(s * 0.14, s * 0.86)
      ctx.lineTo(s * 0.86, s * 0.14)
      ctx.stroke()
    }
  }

  BorderSurface {
    visible: root.warning
    width: Math.max(7, parent.width * 0.42)
    height: width
    radius: width / 2
    color: root.badgeColor
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    borderSpec: Border.flat(Color.popups.background, 1)

    Text {
      anchors.centerIn: parent
      text: "!"
      color: Color.background
      font.family: Style.font.family
      font.pixelSize: Math.max(6, parent.height * 0.72)
      font.bold: true
    }
  }
}
