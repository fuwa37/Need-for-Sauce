import "dart:math";
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: "Need for Sauce",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _counterNotifier = ValueNotifier<int>(0);
  final _imageNotifier = ValueNotifier<int>(0);

  final _random = Random();

  final List<String> _randImage = [
    "https://miro.medium.com/max/480/1*uK0nbOs4RVeioaRMiC1P2Q.png",
    "https://jw-webmagazine.com/wp-content/uploads/2020/03/Kimetsu-no-YaibaDemon-Slayer.jpg",
    "https://miro.medium.com/max/875/1*CwpNhIEqMaO2vSBRteVmZQ.png",
    "https://miro.medium.com/max/700/1*sXYA1WJXZDCNTCLX9H3bsA.png",
    "",
    null
  ];

  void _onPressed1() {
    _counterNotifier.value++;
  }

  void _onPressed2() {
    _imageNotifier.value = _random.nextInt(_randImage.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _onPressed1,
            child: Icon(Icons.colorize),
          ),
          FloatingActionButton(
            onPressed: _onPressed2,
            child: Icon(Icons.colorize),
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _imageNotifier,
            builder: (context, int, child) {
              return Flexible(
                child: ImageViewer(image: _randImage[_imageNotifier.value]),
              );
            },
          ),
          Text("asdasdadadasdasdasdd"),
          ValueListenableBuilder(
            valueListenable: _counterNotifier,
            builder: (context, int, child) {
              return Text(_counterNotifier.value.toString());
            },
          )
        ],
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final dynamic image;

  ImageViewer({@required this.image});

  @override
  Widget build(BuildContext context) {
    return (image != null)
        ? ExtendedImage(
            image: imageProvider(image),
            height: 200,
            width: 200,
            mode: ExtendedImageMode.none,
            enableLoadState: true,
          )
        : Center(
            child: Text("No Media Selected"),
          );
  }
}
