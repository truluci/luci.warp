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
    width: parent.width * 1.3
    height: parent.height * 1.3
    anchors.centerIn: parent
    antialiasing: true

    SequentialAnimation on opacity {
      running: root.pulsing
      loops: Animation.Infinite
      alwaysRunToEnd: true
      NumberAnimation { to: 0.35; duration: 620; easing.type: Easing.InOutQuad }
      NumberAnimation { to: 1.0; duration: 620; easing.type: Easing.InOutQuad }
      onRunningChanged: if (!running) canvas.opacity = 1.0
    }

    function drawCloudflare(ctx, s) {
      ctx.beginPath();
      ctx.moveTo(s * 0.6879, s * 0.7019);
      ctx.bezierCurveTo(s * 0.6940, s * 0.6807, s * 0.6917, s * 0.6614, s * 0.6814, s * 0.6471);
      ctx.bezierCurveTo(s * 0.6720, s * 0.6339, s * 0.6562, s * 0.6263, s * 0.6372, s * 0.6254);
      ctx.lineTo(s * 0.2764, s * 0.6207);
      ctx.lineTo(s * 0.2708, s * 0.6177);
      ctx.bezierCurveTo(s * 0.2696, s * 0.6160, s * 0.2693, s * 0.6136, s * 0.2699, s * 0.6112);
      ctx.bezierCurveTo(s * 0.2711, s * 0.6077, s * 0.2746, s * 0.6051, s * 0.2784, s * 0.6047);
      ctx.lineTo(s * 0.6424, s * 0.6001);
      ctx.bezierCurveTo(s * 0.6855, s * 0.5980, s * 0.7324, s * 0.5631, s * 0.7488, s * 0.5203);
      ctx.lineTo(s * 0.7696, s * 0.4661);
      ctx.bezierCurveTo(s * 0.7705, s * 0.4638, s * 0.7708, s * 0.4614, s * 0.7702, s * 0.4591);
      ctx.bezierCurveTo(s * 0.7468, s * 0.3530, s * 0.6521, s * 0.2739, s * 0.5390, s * 0.2739);
      ctx.bezierCurveTo(s * 0.4346, s * 0.2739, s * 0.3461, s * 0.3413, s * 0.3145, s * 0.4348);
      ctx.bezierCurveTo(s * 0.2940, s * 0.4195, s * 0.2679, s * 0.4113, s * 0.2397, s * 0.4140);
      ctx.bezierCurveTo(s * 0.1896, s * 0.4189, s * 0.1495, s * 0.4591, s * 0.1445, s * 0.5092);
      ctx.bezierCurveTo(s * 0.1433, s * 0.5221, s * 0.1442, s * 0.5347, s * 0.1471, s * 0.5465);
      ctx.bezierCurveTo(s * 0.0653, s * 0.5488, s * 0.0000, s * 0.6156, s * 0.0000, s * 0.6980);
      ctx.bezierCurveTo(s * 0.0000, s * 0.7053, s * 0.0006, s * 0.7126, s * 0.0015, s * 0.7200);
      ctx.bezierCurveTo(s * 0.0021, s * 0.7234, s * 0.0050, s * 0.7261, s * 0.0085, s * 0.7261);
      ctx.lineTo(s * 0.6744, s * 0.7261);
      ctx.bezierCurveTo(s * 0.6782, s * 0.7261, s * 0.6817, s * 0.7234, s * 0.6829, s * 0.7196);
      ctx.lineTo(s * 0.6879, s * 0.7019);
      ctx.closePath();
      
      ctx.moveTo(s * 0.8027, s * 0.4701);
      ctx.bezierCurveTo(s * 0.7995, s * 0.4701, s * 0.7960, s * 0.4701, s * 0.7928, s * 0.4705);
      ctx.bezierCurveTo(s * 0.7904, s * 0.4705, s * 0.7884, s * 0.4723, s * 0.7875, s * 0.4746);
      ctx.lineTo(s * 0.7734, s * 0.5235);
      ctx.bezierCurveTo(s * 0.7673, s * 0.5446, s * 0.7696, s * 0.5640, s * 0.7799, s * 0.5784);
      ctx.bezierCurveTo(s * 0.7893, s * 0.5916, s * 0.8051, s * 0.5991, s * 0.8241, s * 0.6000);
      ctx.lineTo(s * 0.9010, s * 0.6047);
      ctx.bezierCurveTo(s * 0.9033, s * 0.6047, s * 0.9054, s * 0.6058, s * 0.9065, s * 0.6077);
      ctx.bezierCurveTo(s * 0.9077, s * 0.6095, s * 0.9080, s * 0.6121, s * 0.9074, s * 0.6142);
      ctx.bezierCurveTo(s * 0.9062, s * 0.6177, s * 0.9027, s * 0.6204, s * 0.8989, s * 0.6206);
      ctx.lineTo(s * 0.8188, s * 0.6253);
      ctx.bezierCurveTo(s * 0.7755, s * 0.6274, s * 0.7289, s * 0.6623, s * 0.7125, s * 0.7051);
      ctx.lineTo(s * 0.7066, s * 0.7200);
      ctx.bezierCurveTo(s * 0.7054, s * 0.7230, s * 0.7075, s * 0.7259, s * 0.7107, s * 0.7259);
      ctx.lineTo(s * 0.9856, s * 0.7259);
      ctx.bezierCurveTo(s * 0.9888, s * 0.7259, s * 0.9918, s * 0.7239, s * 0.9927, s * 0.7207);
      ctx.bezierCurveTo(s * 0.9974, s * 0.7037, s * 1.0000, s * 0.6858, s * 1.0000, s * 0.6673);
      ctx.bezierCurveTo(s * 1.0000, s * 0.5589, s * 0.9115, s * 0.4704, s * 0.8027, s * 0.4704);
      ctx.closePath();
    }

    onPaint: {
      var ctx = getContext("2d")
      var s = Math.min(width, height)
      ctx.reset()
      ctx.clearRect(0, 0, width, height)

      ctx.fillStyle = root.color
      drawCloudflare(ctx, s)
      ctx.fill()

      if (!root.crossed) return

      // Punch a gap, then lay the slash inside it so the bar stays readable
      // whatever shows through the transparent background.
      ctx.lineCap = "round"
      ctx.globalCompositeOperation = "destination-out"
      ctx.strokeStyle = "#000000"
      ctx.lineWidth = Math.max(2, s * 0.15)
      ctx.beginPath()
      ctx.moveTo(s * 0.16, s * 0.84)
      ctx.lineTo(s * 0.78, s * 0.22)
      ctx.stroke()

      ctx.globalCompositeOperation = "source-over"
      ctx.strokeStyle = root.color
      ctx.lineWidth = Math.max(1, s * 0.07)
      ctx.beginPath()
      ctx.moveTo(s * 0.16, s * 0.84)
      ctx.lineTo(s * 0.78, s * 0.22)
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
