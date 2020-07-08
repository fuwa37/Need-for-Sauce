// https://github.com/fluttercandies/extended_image/blob/master/example/lib/pages/image_editor_demo.dart

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'package:need_for_sauce/common/common.dart';
import 'package:need_for_sauce/common/crop_editor_helper.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

///
///  create by zmtzawqlp on 2019/8/22
///  edited by irs37
///

class ImageEditor extends StatefulWidget {
  final _image;

  ImageEditor(this._image);

  @override
  _ImageEditorState createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  bool _cropItem = false;
  double _selectedCrop;
  bool _cropping = false;
  TextEditingController _textAspectRatioWController = TextEditingController();
  TextEditingController _textAspectRatioHController = TextEditingController();

  EditorConfig _editorConfig() {
    return EditorConfig(
        maxScale: 8.0,
        editorMaskColorHandler: (BuildContext context, bool pointerdown) {
          return Colors.black.withOpacity(pointerdown ? 0.75 : 0.5);
        },
        cropRectPadding: EdgeInsets.fromLTRB(
            45, MediaQuery.of(context).padding.top + 80, 45, 30),
        hitTestSize: 20.0,
        initCropRectType: InitCropRectType.imageRect,
        cropAspectRatio: _selectedCrop);
  }

  Widget _imageEditor() {
    return ExtendedImage(
      image: imageProvider(widget._image),
      fit: BoxFit.contain,
      mode: ExtendedImageMode.editor,
      enableLoadState: true,
      extendedImageEditorKey: editorKey,
      initEditorConfigHandler: (state) {
        return _editorConfig();
      },
    );
  }

  List<AspectRatioItem> _cropAspectRatios = [
    AspectRatioItem(text: "Free", value: null),
    AspectRatioItem(text: "Original", value: 0),
    AspectRatioItem(text: "1:1", value: 1),
    AspectRatioItem(text: "3:4", value: 3 / 4),
    AspectRatioItem(text: "16:9", value: 16 / 9),
  ];

  Widget _cropItems(AspectRatioItem aspectRatio) {
    return InkWell(
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onTap: () {
        if (_selectedCrop == aspectRatio.value &&
            (_selectedCrop != null &&
                _selectedCrop != 0 &&
                _selectedCrop != 1)) {
          setState(() {
            _selectedCrop = 1 / _selectedCrop;
          });

          return;
        }
        setState(() {
          _selectedCrop = aspectRatio.value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(5),
        height: 60,
        child: AspectRatio(
            aspectRatio: (aspectRatio.value == null || aspectRatio.value == 0)
                ? 1
                : aspectRatio.value,
            child: Container(
              decoration: BoxDecoration(
                  border: (_selectedCrop == aspectRatio.value ||
                          ((aspectRatio.value != null &&
                                  aspectRatio.value != 0 &&
                                  aspectRatio.value != 1)
                              ? (_selectedCrop == 1 / aspectRatio.value)
                              : false))
                      ? Border.all(color: Colors.white, width: 2)
                      : Border.all(color: Colors.grey)),
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        aspectRatio.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: (_selectedCrop == aspectRatio.value ||
                                  ((aspectRatio.value != null &&
                                          aspectRatio.value != 0 &&
                                          aspectRatio.value != 1)
                                      ? (_selectedCrop == 1 / aspectRatio.value)
                                      : false))
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                    ),
                    (aspectRatio.value != null &&
                            aspectRatio.value != 0 &&
                            aspectRatio.value != 1)
                        ? Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.crop_rotate,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget _customAspectRatios() {
    return InkWell(
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Container(
                  width: 100,
                  height: 160,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            "Custom Aspect Ratio",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 40,
                              child: TextField(
                                controller: _textAspectRatioWController,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            Container(
                              child: Text(
                                ':',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 40,
                              child: TextField(
                                controller: _textAspectRatioHController,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                              ),
                            )
                          ],
                        ),
                      ),
                      Flexible(
                        child: MaterialButton(
                          color: Colors.blue,
                          onPressed: () {
                            if (_textAspectRatioWController.text != '' &&
                                _textAspectRatioHController.text != '' &&
                                _textAspectRatioHController.text != '0')
                              setState(() {
                                _selectedCrop = double.tryParse(
                                        _textAspectRatioWController.text) /
                                    double.tryParse(
                                        _textAspectRatioHController.text);
                                print(_selectedCrop);
                                _textAspectRatioWController.clear();
                                _textAspectRatioHController.clear();
                              });
                            Navigator.pop(context);
                          },
                          child: Text(
                            "OK",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).then((s) {
          _textAspectRatioWController.clear();
          _textAspectRatioHController.clear();
        });
      },
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Icon(
          Icons.more_horiz,
          color: Colors.white,
        ),
      ),
    );
  }

  void _cropImage() async {
    if (_cropping) return;
    var msg = "";
    try {
      _cropping = true;

      Uint8List fileData =
          await cropImageDataWithNativeLibrary(state: editorKey.currentState);
      _cropping = false;

      Navigator.pop(context, fileData);
    } catch (e, stack) {
      msg = "$e\n $stack";
      print(msg);
    }
  }

  Widget _navigationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.check,
            color: Colors.white,
          ),
          onPressed: () {
            _cropImage();
          },
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          _imageEditor(),
          Padding(
            padding: EdgeInsets.fromLTRB(
                0, MediaQuery.of(context).padding.top, 0, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.black.withOpacity(0.25),
                        Colors.transparent
                      ])),
                  child: _navigationBar()),
            ),
          ),
          (!_cropItem)
              ? Container()
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Container(
                      height: 60,
                      child: Stack(
                        children: <Widget>[
                          Opacity(
                            opacity: 0.7,
                            child: Container(
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.from(_cropAspectRatios
                                .map((item) => _cropItems(item)))
                              ..add(_customAspectRatios()),
                          )
                        ],
                      ),
                    ),
                  ),
                )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        shape: CircularNotchedRectangle(),
        child: ButtonTheme(
          child: Container(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: FlatButtonWithIcon(
                    icon: Icon(
                      Icons.crop,
                    ),
                    label: Text(
                      "Crop",
                      style: TextStyle(fontSize: 10),
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        if (_cropItem) {
                          _cropItem = false;
                        } else {
                          _cropItem = true;
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: FlatButtonWithIcon(
                    icon: Icon(
                      Icons.flip,
                    ),
                    label: Text(
                      "Flip",
                      style: TextStyle(fontSize: 10),
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      editorKey.currentState.flip();
                    },
                  ),
                ),
                Expanded(
                  child: FlatButtonWithIcon(
                    icon: Icon(
                      Icons.rotate_left,
                    ),
                    label: Text(
                      "Rotate Left",
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      editorKey.currentState.rotate(right: false);
                    },
                  ),
                ),
                Expanded(
                  child: FlatButtonWithIcon(
                    icon: Icon(
                      Icons.rotate_right,
                    ),
                    label: Text(
                      "Rotate Right",
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      editorKey.currentState.rotate(right: true);
                    },
                  ),
                ),
                Expanded(
                  child: FlatButtonWithIcon(
                    icon: Icon(
                      Icons.restore,
                    ),
                    label: Text(
                      "Reset",
                      style: TextStyle(fontSize: 10),
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      editorKey.currentState.reset();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
