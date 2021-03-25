// https://github.com/fluttercandies/extended_image/blob/ab9f1686223e99fbc1b85e7b1a7385651a34abec/example/lib/common/common_widget.dart
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:need_for_sauce/common/notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

class TextButtonWithIcon extends TextButton with MaterialButtonWithIconMixin {
  TextButtonWithIcon({
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
          clipBehavior: clipBehavior,
          focusNode: focusNode,
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
    return ExtendedNetworkImageProvider(image,
        cache: true, retries: 3, timeLimit: Duration(seconds: 15));
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

    final List<Offset> p = [];

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
      )
      ..quadraticBezierTo(
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
    return "Sauce found but couldn't get additional info : $message\nYou can continue or try again";
  }
}

class TooManyRequestException implements Exception {
  Response res;

  TooManyRequestException([this.res]);

  String toString() {
    if (res == null) return "Exception";
    return "${res.statusMessage}";
  }
}

class NoPermissionException implements Exception {
  Response res;

  NoPermissionException([this.res]);

  String toString() {
    if (res == null) return "Exception";
    return "${res.statusMessage}";
  }
}

class NoResultException implements Exception {
  String message;

  NoResultException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "Couldn't get result : $message";
  }
}

class NoSupportedApkException implements Exception {
  String message;

  NoSupportedApkException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "$message";
  }
}

properImageHelp(BuildContext context, ScrollController _helpController) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Scrollbar(
            isAlwaysShown: true,
            controller: _helpController,
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              child: SingleChildScrollView(
                controller: _helpController,
                child: MediaQuery(
                    data: MediaQueryData(textScaleFactor: 1),
                    child: Html(
                      shrinkWrap: true,
                      data: """
                        <p>Please use original/un-cropped media(or crop it if consist of multiple images/need to be cropped) for better result.
                        </br>Use editing tools provided by this app or external editing app to edit the image.</p>
                        <p>For general idea of a proper image, regardless of search engine, please refer to <a href='https://trace.moe/faq'>Trace FAQ</a>
                        (Why I can't find the search result?) and adjust accordingly.</p>
                        """,
                      onLinkTap: (url, _, __, ___) {
                        print(url);
                        launch(url);
                      },
                      style: {
                        'p': Style(
                            fontSize: FontSize(
                                16 * MediaQuery.of(context).textScaleFactor))
                      },
                    )),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("CLOSE"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      });
}

loadingDialog({@required BuildContext scaffoldContext, CancelToken token}) {
  print("Loading");
  showDialog(
    context: scaffoldContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      var loadingNotifier = Provider.of<LoadingNotifier>(context);
      Future.microtask(() => loadingNotifier.setDialogContext(context));
      return WillPopScope(
        onWillPop: () {
          try {
            token?.cancel("Back Button");
          } on Exception catch (e) {
            print(e);
          }
          return Future.value(true);
        },
        child: AlertDialog(
          title: ListTile(
              leading: CircularProgressIndicator(),
              title: Text("Loading..."),
              subtitle: Text("Press BACK to cancel")),
        ),
      );
    },
  );
}

showSnackBar(
    {@required String msg,
    @required ScaffoldMessengerState state,
    SnackBarAction act,
    Duration dur = const Duration(seconds: 4)}) {
  state?.removeCurrentSnackBar();
  state?.showSnackBar(SnackBar(
    content: Text("$msg"),
    behavior: SnackBarBehavior.floating,
    action: act,
    duration: dur,
  ));
}

double mapRange(
    {@required double input,
    @required double x1,
    @required double y1,
    @required double x2,
    @required double y2}) {
  return (input - x1) / (y1 - x1) * (y2 - x2) + x2;
}

void deleteObsoleteApk() async {
  Directory temp = await getTemporaryDirectory();

  temp.listSync().forEach((element) {
    var fileType = lookupMimeType(element.path);
    if (fileType?.contains("application") ?? false) {
      print("Delete ${element.path}");
      File(element.path).delete();
    }
  });
}

enum SearchOption { SauceBot, Trace, SauceNao }

final searchOptionValues = EnumValues({
  "SauceNAO": SearchOption.SauceNao,
  "Trace": SearchOption.Trace,
  "Sauce Bot": SearchOption.SauceBot
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

String returnTime(Duration time) {
  return "${(time.inHours > 0) ? (time.inHours.toString().padLeft(2, '0') + ':') : ""}${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${time.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}

String bbCodetoHtml(String input) {
  var map = {
    "[b]": "<b>",
    "[/b]": "</b>",
    "[u]": "<u>",
    "[/u]": "</u>",
    "[spoiler]": "<spoiler>",
    "[/spoiler]": "</spoiler>",
    "[hr]": "<hr>",
  };

  var url = RegExp(r'''\[url(?:\=("|\'|)?(.*)?\1)?\](.*)\[\/url\]''');

  input = input.replaceAllMapped(url, (match) {
    return "<a href='${match.group(2)}'>${match.group(3)}</a>";
  });

  var li = RegExp(r'\[\*\](.*?)(\n|\r\n?)');

  input = input.replaceAllMapped(li, (match) {
    return "<li>${match.group(1)}</li>";
  });

  var tag = RegExp(r'(\[(.*?)\])');

  return input.replaceAllMapped(tag, (match) {
    var temp = map[match[0]];
    if (temp != null) {
      return "$temp";
    } else {
      return "";
    }
  });
}

extension CustomTextStyles on TextTheme {
  TextStyle get error {
    return TextStyle(
        fontSize: 12,
        color: Colors.redAccent,
        wordSpacing: 0.1,
        fontWeight: FontWeight.w500);
  }
}

extension Extension on Object {
  bool isNullOrEmpty() => this == null || this == '';

  bool isNullEmptyOrFalse() => this == null || this == '' || !this;

  bool isNullEmptyZeroOrFalse() =>
      this == null || this == '' || !this || this == 0;
}
