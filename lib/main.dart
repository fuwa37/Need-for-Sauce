import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:need_for_sauce/pages/editors/image_editor.dart';
import 'package:extended_image/extended_image.dart';
import 'package:need_for_sauce/models/models.dart';
import 'package:need_for_sauce/pages/sauce.dart';
import 'package:need_for_sauce/pages/editors/video_capture.dart';
import 'package:need_for_sauce/common/shared_preferences_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:need_for_sauce/pages/about.dart';
import 'package:path/path.dart' as path;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:dio/dio.dart';
import 'package:need_for_sauce/common/http_request.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mime/mime.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_expanded_tile/tileController.dart';
import 'package:permission_handler/permission_handler.dart';

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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  StreamSubscription _intentDataStreamSubscription;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _urlController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PanelController _panelController = PanelController();
  ExpandedTileController _expandedTileController = ExpandedTileController();
  dynamic _image;
  CancelToken token;
  AnimationController _addBAnimationController;
  Animation<double> _addBAnimation;
  AnimationController _closeBAnimationController;
  Animation<double> _closeBAnimation;
  bool _isImageLoaded = false;
  bool _isLoadingHead;
  bool _isAllDB = true;
  SearchOption _searchOption;
  bool _getAddInfo;
  SplayTreeMap<String, String> _sauceNaoDBMask;
  bool _addBOpen = false;

  Future _getMedia({File videoIntent}) async {
    print(await Permission.mediaLibrary.request());
    print(await Permission.storage.request());

    File media = videoIntent ?? await FilePicker.getFile(type: FileType.media);
    if (media == null && videoIntent == null) return;
    var fileType = lookupMimeType(media.path).split('/');

    if (fileType[0] == 'image') {
      setState(() {
        _closeBAnimationController.forward();
        _image = media;
      });
    } else if (fileType[0] == 'video') {
      Uint8List result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoCapture(media ?? videoIntent);
      }));
      if (result == null && videoIntent == null) _getMedia();

      setState(() {
        _closeBAnimationController.forward();
        _image = result;
      });
    } else {
      return;
    }
  }

  Future _editImage() async {
    Uint8List result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditor(_image);
    }));
    if (result == null) return;

    if (result != null) {
      setState(() {
        _image = result;
      });
    }
  }

  _checkURLContentType(url) async {
    Response r;

    setState(() {
      _isLoadingHead = true;
    });
    try {
      r = await Dio()
          .head(url, options: Options(sendTimeout: 1000, receiveTimeout: 1000));
    } on DioError catch (e) {
      print(e);
      setState(() {
        _isLoadingHead = false;
      });
      return;
    }
    Headers headers = r.headers;
    String _type = headers['content-type'][0];
    if (_type.split('/')[0] == 'image') {
      setState(() {
        _closeBAnimationController.forward();
        _isLoadingHead = false;
        _image = url;
      });
    } else if (_type.split('/')[0] == 'video') {
      Uint8List result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoCapture(url);
      }));
      setState(() {
        _closeBAnimationController.forward();
        _isLoadingHead = false;
        _image = result;
      });
    } else {
      print("Not image/video");
      setState(() {
        _isLoadingHead = false;
      });
      return;
    }
  }

  _pickURL() {
    showDialog(
        context: context,
        builder: (context) {
          Clipboard.getData('text/plain').then((value) {
            if (value != null) {
              try {
                var uri = Uri.parse(value.text);
                if (uri.scheme == 'https' && uri.hasAuthority) {
                  _urlController.text = value.text;
                  _urlController.selection = TextSelection(
                      baseOffset: 0, extentOffset: value.text.length);
                }
              } on FormatException catch (e) {
                print(e);
                print("Not URI");
              }
            }
          });
          return AlertDialog(
            content: Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,
                controller: _urlController,
                decoration: InputDecoration(
                    labelText: "URL",
                    hintText: 'https://www.example.com/1234.jpg'),
                validator: (text) {
                  if (text.isEmpty) {
                    return "Enter URL";
                  }
                  var uri = Uri.parse(text);
                  if (uri.scheme != 'https' && !uri.hasAuthority) {
                    return "Use HTTPS";
                  } else {
                    return null;
                  }
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  _urlController.clear();
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Navigator.pop(context);
                    _checkURLContentType(_urlController.text);
                    _urlController.clear();
                  }
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        });
  }

/*  Widget _sauce(image) {
    return InkWell(
      onLongPress: () {
        _panelController.close();
        _getSauce(image, useForce: true);
      },
      child: Container(
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            _panelController.close();
            _getSauce(image, useForce: false);
          },
          child: Icon(Icons.search),
        ),
      ),
    );
  }*/

  Future _uploadedType(image) async {
    if (image is File)
      return await MultipartFile.fromFile(image.path,
          filename: path.basename(image.path));
    else if (image is List<int>)
      return MultipartFile.fromBytes(image, filename: "temp");
    else
      return image;
  }

/*  Future<Response> _uploadImage(image, {bool useTrace, bool useForce}) async {
    String sign = await GetSignature.appSignature;

    FormData formData = FormData.fromMap({
      "url": (image is String) ? image : null,
      "force": (useForce) ? 1 : null,
      "trace": (useTrace) ? 1 : null,
      "signature": sign,
      "file": !(image is String) ? await _uploadedType(image) : null,
    });
    try {
      token = CancelToken();
      return await Sauce.sauceBot()
          .post("uploader", data: formData, cancelToken: token);
    } on DioError catch (e) {
      throw e;
    }
  }*/

  Future<Response> _sauceNaoConn() async {
    var dbmask = sauceNaoDBMask(_sauceNaoDBMask);
    print(dbmask);

    if (_image is String) {
      try {
        token = CancelToken();
        return await Sauce.sauceNao(dbmask)
            .get("&url=" + Uri.encodeComponent(_image), cancelToken: token);
      } on DioError catch (e) {
        throw e;
      }
    } else {
      FormData formData = FormData.fromMap({
        "file": await _uploadedType(_image),
      });

      try {
        token = CancelToken();
        return await Sauce.sauceNao(dbmask)
            .post("", data: formData, cancelToken: token);
      } on DioError catch (e) {
        throw e;
      }
    }
  }

  Future<Response> _traceConn() async {
    if (_image is String) {
      try {
        token = CancelToken();
        return await Sauce.trace()
            .get("?url=" + Uri.encodeComponent(_image), cancelToken: token);
      } on DioError catch (e) {
        throw e;
      }
    } else {
      FormData formData = FormData.fromMap({
        "image": (_image is File)
            ? base64Encode(_image.readAsBytesSync())
            : (_image is List<int>) ? base64Encode(_image) : null,
      });

      try {
        token = CancelToken();
        return await Sauce.trace().post("", data: formData, cancelToken: token);
      } on DioError catch (e) {
        throw e;
      }
    }
  }

/*
  _getSauce(image, {bool useTrace, bool useForce}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: WillPopScope(
          onWillPop: () async {
            try {
              token.cancel("Back Button");
            } on Exception catch (e) {
              print(e);
            }
            return true;
          },
          child: FutureBuilder(
            future: _uploadImage(image, useTrace: useTrace, useForce: useForce),
            builder: (context, AsyncSnapshot<Response> snapshot) {
              if (snapshot.hasError &&
                  !snapshot.error.toString().contains('CANCEL')) {
                print(snapshot.error);
                return AlertDialog(
                  content: Text("Can't connect to internet"),
                );
              }
              if (snapshot.hasData) {}
              return Container(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
*/
  void _search() async {
    switch (_searchOption) {
      case SearchOption.SauceNao:
        {
          if (_isAllDB != false) {
            print("Use Sauce Nao");
            try {
              var r = await _sauceNaoConn();
              if (r?.data != null) {
                var sauces = SauceNaoObject.fromJson(r.data);
                if (sauces.results != null) {
                  var sauce = sauces.results[0];
                  var data = sauce.toSauceNaoData();
                  if (data is SauceNaoH18 && _getAddInfo) {
                    try {
                      sauce.data = await data.withInfo();
                    } on NoInfoException catch (e) {
                      print(e);
                    } finally {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SauceDesc(
                            SauceObject.fromSauceNao(sauce.header, sauce.data));
                      }));
                    }
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SauceDesc(
                          SauceObject.fromSauceNao(sauce.header, sauce.data));
                    }));
                  }
                } else {
                  print("No Sauce");
                  print(
                      "Status: ${sauces.header.status}\nMessage: ${sauces.header.message}");
                }
              } else {
                throw Exception("Response null");
              }
            } on Exception catch (e) {
              print(e);
            }
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Select at least one database"),
              behavior: SnackBarBehavior.floating,
            ));
            _panelController.open();
            _expandedTileController.expand();
          }
          break;
        }
      case SearchOption.Trace:
        {
          print("Use Trace");
          try {
            var r = await _traceConn();
            if (r?.data != null) {
              var sauces = TraceObject.fromJson(r.data);
              if (sauces.docs != null) {
                var sauce = sauces.docs[0];
                if (_getAddInfo) {
                  sauce = await sauce.withInfo();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SauceDesc(SauceObject.fromTrace(sauce));
                  }));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SauceDesc(SauceObject.fromTrace(sauce));
                  }));
                }
              } else {
                print("No Sauce");
              }
            } else {
              throw Exception("Response null");
            }
          } on Exception catch (e) {
            print(e);
          }
          break;
        }

      case SearchOption.SauceBot:
        {
          // TODO Not implemented yet
          break;
        }
    }
  }

  Widget _imageLoad() {
    _isImageLoaded = false;
    var _eImage = ExtendedImage(
      image: imageProvider(_image),
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      mode: ExtendedImageMode.none,
      enableLoadState: true,
    );

    _eImage.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, call) {
          setState(() {
            _isImageLoaded = true;
          });
        },
      ),
    );

    return _eImage;
  }

  Widget _imageViewer() {
    return (_image == null)
        ? (_isLoadingHead ?? false)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Text(
                  'No media selected',
                ),
              )
        : _imageLoad();
  }

  Widget _menuButtons() {
    return FloatingActionButton(
      heroTag: null,
      child: (_isImageLoaded) ? Icon(Icons.search) : Icon(Icons.add),
      onPressed: (_isImageLoaded)
          ? () {
              _panelController.close();
              _search();
            }
          : () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Wrap(
                      children: [
                        ListTile(
                          leading: Icon(Icons.perm_media),
                          title: Text("Open Gallery"),
                          onTap: () {
                            Navigator.pop(context);
                            _panelController.close();
                            _getMedia();
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.insert_link),
                          title: Text("Pick URL"),
                          onTap: () {
                            Navigator.pop(context);
                            _panelController.close();
                            _pickURL();
                          },
                        )
                      ],
                    );
                  });
            },
    );
  }

  Widget _mainBody() {
    return SlidingUpPanel(
      body: Padding(
        padding:
            EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 48),
        child: GestureDetector(
          onTap: () {
            if (_addBAnimationController.isCompleted) {
              _addBAnimationController.reverse();
            }
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _imageViewer(),
          ),
        ),
      ),
      backdropEnabled: true,
      controller: _panelController,
      onPanelClosed: () {
        try {
          _expandedTileController?.collapse();
        } on Exception catch (e) {
          print(e);
        }
      },
      minHeight: 0,
      maxHeight: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top,
      snapPoint: 0.5,
      onPanelSlide: (val) {
        if (val == 0.5) {
          if (_addBOpen) {
            _addBAnimationController.reverse();
          }
        }
        if (val >= 0.5) {
          _closeBAnimationController.reverse();
        } else if (val <= 0.45) {
          _closeBAnimationController.forward();
        }
      },
      header: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListTile(
                  title: Text(
                    "Options",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              ),
              MaterialButton(
                shape: CircleBorder(),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AboutPage();
                  }));
                },
                child: Icon(Icons.info_outline),
              ),
            ],
          )),
      renderPanelSheet: true,
      panel: Padding(
        padding: EdgeInsets.fromLTRB(0, 48, 0, 48),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  child: SwitchListTile(
                value: _getAddInfo ?? false,
                onChanged: (val) {
                  setState(() {
                    _getAddInfo = val;
                    SharedPreferencesUtils.setAddInfo(val);
                  });
                },
                title: Text(
                  "Get Additional Info",
                  style: TextStyle(),
                ),
              )),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ListTile(
                        title: Text("Sauce API"),
                      ),
                    ),
                    Flexible(
                      child: DropdownButton<SearchOption>(
                        underline: Container(
                          height: 2,
                          color: Colors.blue,
                        ),
                        value: _searchOption,
                        onChanged: (val) {
                          SharedPreferencesUtils.setSourceOption(val);
                          setState(() {
                            _searchOption = val;
                            if (val == SearchOption.SauceNao) {
                              _expandedTileController =
                                  ExpandedTileController();
                              _expandedTileController
                                  .addListener(_expansionTileListener);
                            } else {
                              _expandedTileController = null;
                            }
                          });
                        },
                        items: [
                          DropdownMenuItem<SearchOption>(
                            value: SearchOption.SauceNao,
                            child: Text(
                                "${searchOptionValues.reverse[SearchOption.SauceNao]}"),
                          ),
                          DropdownMenuItem<SearchOption>(
                            value: SearchOption.Trace,
                            child: Text(
                                "${searchOptionValues.reverse[SearchOption.Trace]}"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              (_searchOption != SearchOption.SauceNao)
                  ? SizedBox()
                  : ExpandedTile(
                      leading: Checkbox(
                        tristate: true,
                        onChanged: (val) {
                          setState(() {
                            if (_isAllDB == null || (val ?? false)) {
                              _isAllDB = true;
                              _sauceNaoDBMask.updateAll((key, value) => '1');
                            } else {
                              _isAllDB = false;
                              _sauceNaoDBMask.updateAll((key, value) => '0');
                              //_expandedTileController.expand();
                            }
                          });
                        },
                        value: _isAllDB,
                      ),
                      controller: _expandedTileController,
                      title: Text("SauceNAO Databases"),
                      content: Wrap(
                        children: _sauceNaoDBMask.entries.map((e) {
                          var _widthConstraint =
                              (ScreenUtil.screenWidth - 32) / 3;
                          if (_widthConstraint < 125)
                            _widthConstraint =
                                (ScreenUtil.screenWidth - 32) / 2;
                          return Container(
                            constraints: BoxConstraints(
                              maxWidth: _widthConstraint,
                            ),
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            child: CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text("${e.key}"),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: (e.value == '1') ? true : false,
                                onChanged: (val) {
                                  SharedPreferencesUtils.setSNDBMask(
                                      e.key, (val) ? '1' : '0');
                                  setState(() {
                                    _sauceNaoDBMask[e.key] = (val) ? '1' : '0';
                                    if (_sauceNaoDBMask.values.contains('0')) {
                                      _isAllDB = null;
                                    } else {
                                      _isAllDB = true;
                                    }
                                  });
                                }),
                          );
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bab() {
    return BottomAppBar(
      notchMargin: 12,
      shape: CircularNotchedRectangle(),
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FlatButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (_panelController.isPanelClosed) {
                _panelController.animatePanelToSnapPoint();
              } else {
                _panelController.close();
              }
            },
            child: Container(
              child: Center(
                child: Text(
                  "Options",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              height: 48,
              width: MediaQuery.of(context).size.width / 2 - 42,
            ),
          ),
          SizedBox(
            width: 84,
          ),
          Container(
            height: 48,
            width: MediaQuery.of(context).size.width / 2 - 42,
            child: (_isImageLoaded)
                ? Row(
                    children: [
                      Flexible(
                        child: FlatButton(
                          child: Container(
                            height: 48,
                            child: Icon(Icons.close, color: Colors.red,),
                          ),
                          onPressed: () {
                            _closeBAnimationController.reverse();
                            setState(() {
                              _image = null;
                              _isImageLoaded = false;
                            });
                          },
                        ),
                      ),
                      Flexible(
                        child: FlatButton(
                          child: Container(
                            height: 48,
                            child: Icon(Icons.edit, color: Colors.white,),
                          ),
                          onPressed: () {
                            _editImage();
                          },
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          )
        ],
      ),
    );
  }

  _expansionTileListener() {
    if (_expandedTileController.isExpanded) {
      _panelController.open();
    }

    /*if (!_expandedTileController.isExpanded && !(_isAllDB ?? true)) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Must select one"),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "Select All",
          onPressed: () {
            setState(() {
              SharedPreferencesUtils.setAllDB(true);
              _isAllDB = true;
              _sauceNaoDBMask.updateAll((key, value) => '1');
            });
          },
        ),
      ));
      _expandedTileController.expand();
    }*/
  }

  bool _isAllDBBox() {
    return (_sauceNaoDBMask.values.contains('0')
        ? ((_sauceNaoDBMask.values.every((element) => element == '0'))
            ? false
            : null)
        : true);
  }

  void _initOptions() async {
    _searchOption = await SharedPreferencesUtils.getSourceOption();
    _getAddInfo = await SharedPreferencesUtils.getAddInfo();
    _sauceNaoDBMask =
        SplayTreeMap.from(await SharedPreferencesUtils.getSNDBMask());
    _isAllDB = _isAllDBBox();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ScreenUtil.init();

    _addBAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this, value: 0);
    _addBAnimation =
        CurvedAnimation(parent: _addBAnimationController, curve: Curves.linear);
    _closeBAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this, value: 0);
    _closeBAnimation = CurvedAnimation(
        parent: _closeBAnimationController, curve: Curves.linear);

    _expandedTileController.addListener(_expansionTileListener);

    _initOptions();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value?.isNotEmpty ?? false) {
        if (value[0].type == SharedMediaType.IMAGE) {
          setState(() {
            _image = File(value[0].path);
          });
        } else if (value[0].type == SharedMediaType.VIDEO) {
          _getMedia(videoIntent: File(value[0].path));
        }
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value?.isNotEmpty ?? false) {
        if (value[0].type == SharedMediaType.IMAGE) {
          setState(() {
            _image = File(value[0].path);
          });
        } else if (value[0].type == SharedMediaType.VIDEO) {
          _getMedia(videoIntent: File(value[0].path));
        }
      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      if (value?.isNotEmpty ?? false) {
        _checkURLContentType(value);
      }
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      if (value?.isNotEmpty ?? false) {
        _checkURLContentType(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!_panelController.isPanelClosed) {
          _panelController.close();
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: _mainBody(),
        bottomNavigationBar: _bab(),
        floatingActionButton: _menuButtons(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        extendBody: true,
      ),
    );
  }

  @override
  dispose() {
    _addBAnimationController.dispose();
    _closeBAnimationController.dispose();
    _intentDataStreamSubscription.cancel();
    _urlController.dispose();
    _expandedTileController.dispose();
    super.dispose();
  }
}
