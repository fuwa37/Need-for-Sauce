// https://github.com/fluttercandies/extended_image/blob/ab9f1686223e99fbc1b85e7b1a7385651a34abec/example/lib/common/common_widget.dart

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;

class FlatButtonWithIcon extends FlatButton with MaterialButtonWithIconMixin {
  FlatButtonWithIcon({
    Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color focusColor,
    Color hoverColor,
    Color highlightColor,
    Color splashColor,
    Brightness colorBrightness,
    EdgeInsetsGeometry padding,
    ShapeBorder shape,
    Clip clipBehavior = Clip.none,
    FocusNode focusNode,
    MaterialTapTargetSize materialTapTargetSize,
    @required Widget icon,
    @required Widget label,
  })  : assert(icon != null),
        assert(label != null),
        super(
          key: key,
          onPressed: onPressed,
          onHighlightChanged: onHighlightChanged,
          textTheme: textTheme,
          textColor: textColor,
          disabledTextColor: disabledTextColor,
          color: color,
          disabledColor: disabledColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          colorBrightness: colorBrightness,
          padding: padding,
          shape: shape,
          clipBehavior: clipBehavior,
          focusNode: focusNode,
          materialTapTargetSize: materialTapTargetSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              const SizedBox(height: 5.0),
              label,
            ],
          ),
        );
}

class AspectRatioItem {
  final String text;
  final double value;

  AspectRatioItem({this.value, this.text});
}

class AspectRatioWidget extends StatelessWidget {
  final String aspectRatioS;
  final double aspectRatio;
  final bool isSelected;

  AspectRatioWidget(
      {this.aspectRatioS, this.aspectRatio, this.isSelected: false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(100, 100),
      painter: AspectRatioPainter(
          aspectRatio: aspectRatio,
          aspectRatioS: aspectRatioS,
          isSelected: isSelected),
    );
  }
}

class AspectRatioPainter extends CustomPainter {
  final String aspectRatioS;
  final double aspectRatio;
  final bool isSelected;

  AspectRatioPainter(
      {this.aspectRatioS, this.aspectRatio, this.isSelected: false});

  @override
  void paint(Canvas canvas, Size size) {
    final Color color = isSelected ? Colors.blue : Colors.grey;
    var rect = (Offset.zero & size);
    //https://github.com/flutter/flutter/issues/49328
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double aspectRatioResult =
        (aspectRatio != null && aspectRatio > 0.0) ? aspectRatio : 1.0;
    canvas.drawRect(
        getDestinationRect(
            rect: EdgeInsets.all(10.0).deflateRect(rect),
            inputSize: Size(aspectRatioResult * 100, 100.0),
            fit: BoxFit.contain),
        paint);

    TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: aspectRatioS,
            style: TextStyle(
              color: (color.computeLuminance() < 0.5
                  ? Colors.white
                  : Colors.black),
              fontSize: 16.0,
            )),
        textDirection: TextDirection.ltr,
        maxLines: 1);
    textPainter.layout(maxWidth: rect.width);

    textPainter.paint(
        canvas,
        rect.center -
            Offset(textPainter.width / 2.0, textPainter.height / 2.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    var oldOne = oldDelegate as AspectRatioPainter;
    return oldOne.isSelected != isSelected ||
        oldOne.aspectRatioS != aspectRatioS ||
        oldOne.aspectRatio != aspectRatio;
  }
}

//

imageProvider(image) {
  if (image is File) {
    return ExtendedFileImageProvider(image);
  } else if (image is String) {
    return ExtendedNetworkImageProvider(image, cache: true);
  } else if (image is List<int>) {
    return ExtendedMemoryImageProvider(image);
  }
}

class EmptyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text("Empty"),
    );
  }
}

class InverseNotched extends CustomClipper<Path> {
  Rect host;
  Rect guest;
  double height = 0;

  InverseNotched(this.host, this.guest, {this.height});

  Path _getOuterPath(Rect host, Rect guest) {
    if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);

    // The guest's shape is a circle bounded by the guest rectangle.
    // So the guest's radius is half the guest width.
    final double notchRadius = guest.width / 2.0;

    // We build a path for the notch from 3 segments:
    // Segment A - a Bezier curve from the host's top edge to segment B.
    // Segment B - an arc with radius notchRadius.
    // Segment C - a Bezier curve from segment B back to the host's top edge.
    //
    // A detailed explanation and the derivation of the formulas below is
    // available at: https://goo.gl/Ufzrqn

    const double s1 = 15.0;
    const double s2 = 1.0;

    final double r = notchRadius;
    final double a = -1.0 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final List<Offset> p = List<Offset>(6);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2].dx, p[2].dy);
    p[4] = Offset(-1.0 * p[1].dx, p[1].dy);
    p[5] = Offset(-1.0 * p[0].dx, p[0].dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) p[i] += guest.center;

    return Path()
      ..moveTo(p[0].dx, p[0].dy + this.height)
      ..quadraticBezierTo(
          p[1].dx, p[1].dy + this.height, p[2].dx, -p[2].dy + this.height)
      ..arcToPoint(
        Offset(p[3].dx, -p[3].dy + this.height),
        radius: Radius.circular(notchRadius),
        clockwise: true,
      )
      ..quadraticBezierTo(
          p[4].dx, -p[4].dy + this.height, p[5].dx, p[5].dy + this.height)
      ..quadraticBezierTo(
          p[4].dx, p[4].dy + this.height, p[5].dx, p[5].dy + this.height)
      ..arcToPoint(
        Offset(p[3].dx, p[3].dy + this.height),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )..quadraticBezierTo(
          p[1].dx, p[1].dy + this.height, p[2].dx, p[2].dy + this.height)
      ..close();
  }

  @override
  Path getClip(Size size) {
    return _getOuterPath(this.host, this.guest);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class NoInfoException implements Exception {
  String message;
  
  NoInfoException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "Couldn't get additional info: $message";
  }
}
