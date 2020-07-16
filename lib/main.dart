import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/style.dart';
import 'package:need_for_sauce/pages/editors/image_editor.dart';
import 'package:extended_image/extended_image.dart';
import 'package:need_for_sauce/models/models.dart';
import 'package:need_for_sauce/pages/sauce.dart';
import 'package:need_for_sauce/pages/editors/video_capture.dart';
import 'package:need_for_sauce/common/shared_preferences_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:need_for_sauce/pages/editors/gif_capture.dart';
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
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

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
  StreamSubscription _intentDataStreamSubscription;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _urlController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PanelController _panelController = PanelController();
  ScrollController _helpController = ScrollController();
  ExpandedTileController _expandedTileController = ExpandedTileController();
  dynamic _image;
  CancelToken token;
  bool _isAllDB = true;
  SearchOption _searchOption;
  bool _getAddInfo;
  SplayTreeMap<String, String> _sauceNaoDBMask;
  bool _showBanner = false;
  Widget _bannerMessage = SizedBox();
  Widget _bannerAction;
  ValueNotifier<bool> _isFailedtoLoad = ValueNotifier(false);
  BuildContext _dialogContext;

  _getMedia({File videoIntent}) async {
    print(await Permission.mediaLibrary.request());
    print(await Permission.storage.request());

    File media = videoIntent ?? await FilePicker.getFile(type: FileType.media);
    if (media == null && videoIntent == null) return;
    var fileType = lookupMimeType(media.path).split('/');

    if (fileType[0] == 'image') {
      Uint8List result;
      if (fileType[1] == 'gif') {
        result =
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GifCapture(media);
        }));

        if (result == null) _getMedia();
        setState(() {
          _image = result;
        });
      } else {
        setState(() {
          _image = media;
        });
      }
    } else if (fileType[0] == 'video') {
      Uint8List result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoCapture(media ?? videoIntent);
      }));
      if (result == null && videoIntent == null) _getMedia();

      setState(() {
        _image = result;
      });
    } else {
      return;
    }
  }

  _editImage() async {
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
    _loadingDialog();
    try {
      token = CancelToken();
      r = await Dio().head(url,
          options: Options(sendTimeout: 1000, receiveTimeout: 1000),
          cancelToken: token);
    } on DioError catch (e) {
      print(e);
      Navigator.pop(_dialogContext);
      _dialogContext = null;
      return;
    }
    Headers headers = r.headers;
    String _type = headers['content-type'][0];
    if (_dialogContext != null) {
      Navigator.pop(_dialogContext);
      _dialogContext = null;
    }
    if (_type.split('/')[0] == 'image') {
      Uint8List result;
      if (_type.split('/')[1] == 'gif') {
        result =
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GifCapture(url);
        }));

        if (result == null) _getMedia();
        setState(() {
          _image = result;
        });
      } else {
        setState(() {
          _image = url;
        });
      }
    } else if (_type.split('/')[0] == 'video') {
      Uint8List result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoCapture(url);
      }));
      if (_dialogContext != null) {
        Navigator.pop(_dialogContext);
        _dialogContext = null;
      }
      setState(() {
        _image = result;
      });
    } else {
      print("Not image/video");
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
        if (e?.response?.statusCode == 429 ?? false) {
          throw TooManyRequestException(e.response);
        }
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

  _loadingDialog() {
    return showDialog(
      context: _scaffoldKey.currentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _dialogContext = context;
        return WillPopScope(
          onWillPop: () {
            try {
              token.cancel("Back Button");
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

  void _search() async {
    switch (_searchOption) {
      case SearchOption.SauceNao:
        {
          if (_isAllDB != false) {
            try {
              var r = await _sauceNaoConn();
              if (r?.data != null) {
                var sauces = SauceNaoObject.fromJson(r.data);
                if (sauces?.results != null) {
                  var sauce = sauces.results[0];
                  var data = sauce.toSauceNaoData();
                  if (data is SauceNaoH18 && _getAddInfo) {
                    try {
                      sauce.data = await data.withInfo();
                      Navigator.pop(_dialogContext);
                      _dialogContext = null;
                      _hideBanner();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SauceDesc(
                            SauceObject.fromSauceNao(sauce.header, sauce.data));
                      }));
                    } on NoInfoException catch (e) {
                      print(e);
                      Navigator.pop(_dialogContext);
                      _dialogContext = null;
                      setState(() {
                        _showBanner = true;
                        _bannerMessage = Text(
                          "$e",
                          textAlign: TextAlign.start,
                        );
                        _bannerAction = FlatButton(
                          child: Text("CONTINUE"),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return SauceDesc(SauceObject.fromSauceNao(
                                  sauce.header, sauce.data));
                            }));
                            _hideBanner();
                          },
                        );
                      });
                    }
                  } else {
                    Navigator.pop(_dialogContext);
                    _dialogContext = null;
                    _hideBanner();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SauceDesc(
                          SauceObject.fromSauceNao(sauce.header, sauce.data));
                    }));
                  }
                } else {
                  print("No Sauce");
                  print(
                      "Status: ${sauces?.header?.status}\nMessage: ${sauces?.header?.message}");
                  throw NoResultException("No Sauce");
                }
              } else {
                throw Exception("No response");
              }
            } on TooManyRequestException catch (e) {
              var sauces = SauceNaoObject.fromJson(e.res.data);
              Future.delayed(Duration(milliseconds: 50)).then((value) {
                if (_dialogContext != null) {
                  Navigator.pop(_dialogContext);
                  _dialogContext = null;
                  setState(() {
                    _showBanner = true;
                    _bannerMessage = MediaQuery(
                        data: MediaQueryData(textScaleFactor: 1),
                        child: Html(
                          shrinkWrap: true,
                          data: """${sauces.header.message}
                              <hr>
                              </br></br>Use of SauceNAO account or API key is not implemented.
                              </br><a href="https://www.saucenao.com">SauceNAO Website</a>
                              """,
                          onLinkTap: (url) {
                            if (Uri.parse(url).hasAuthority) {
                              launch(url);
                            } else {
                              url = "https://www.saucenao.com/$url";
                              launch(url);
                            }
                          },
                          style: {
                            'p': Style(
                                fontSize: FontSize(14 *
                                    MediaQuery.of(context).textScaleFactor))
                          },
                        ));
                    _bannerAction = null;
                  });
                }
              });
            } on DioError catch (e) {
              switch (e.type) {
                case DioErrorType.CANCEL:
                  break;
                case DioErrorType.RECEIVE_TIMEOUT:
                case DioErrorType.SEND_TIMEOUT:
                case DioErrorType.CONNECT_TIMEOUT:
                case DioErrorType.RESPONSE:
                case DioErrorType.DEFAULT:
                  {
                    Future.delayed(Duration(milliseconds: 50)).then((value) {
                      if (_dialogContext != null) {
                        Navigator.pop(_dialogContext);
                        _dialogContext = null;
                      }
                      setState(() {
                        _showBanner = true;
                        _bannerAction = null;
                        _bannerMessage = Text(
                            "${e.error}\n\nPlease check your internet connection");
                      });
                    });
                  }
              }
              print(e);
            } on NoResultException catch (e) {
              Future.delayed(Duration(milliseconds: 50)).then((value) {
                if (_dialogContext != null) {
                  Navigator.pop(_dialogContext);
                  _dialogContext = null;
                }
                setState(() {
                  _showBanner = true;
                  _bannerAction = FlatButton(
                    child: Text("HELP"),
                    onPressed: () {
                      properImageHelp(context, _helpController);
                    },
                  );
                  _bannerMessage = Text("${e.message}");
                });
              });
              print(e);
            } on Exception catch (e) {
              Future.delayed(Duration(milliseconds: 50)).then((value) {
                if (_dialogContext != null) {
                  Navigator.pop(_dialogContext);
                  _dialogContext = null;
                }
                setState(() {
                  _showBanner = true;
                  _bannerAction = null;
                  _bannerMessage = Text("$e");
                });
              });
              print(e);
            }
          } else {
            _showSnackBar("Select at least one index",
                act: SnackBarAction(
                  label: "DISMISS",
                  onPressed: () {
                    _scaffoldKey.currentState.removeCurrentSnackBar();
                  },
                ));
            _panelController.open();
            _expandedTileController.expand();
          }
          break;
        }
      case SearchOption.Trace:
        {
          try {
            var r = await _traceConn();
            if (r?.data != null) {
              var sauces = TraceObject.fromJson(r.data);
              if (sauces.docs != null) {
                var sauce = sauces.docs[0];
                if (_getAddInfo) {
                  sauce = await sauce.withInfo();
                  Navigator.pop(_dialogContext);
                  _dialogContext = null;
                  _hideBanner();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SauceDesc(SauceObject.fromTrace(sauce));
                  }));
                } else {
                  Navigator.pop(_dialogContext);
                  _dialogContext = null;
                  _hideBanner();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SauceDesc(SauceObject.fromTrace(sauce));
                  }));
                }
              } else {
                print("No Sauce");
                throw NoResultException("No Sauce");
              }
            } else {
              throw Exception("No Response");
            }
          } on DioError catch (e) {
            switch (e.type) {
              case DioErrorType.CANCEL:
                break;
              case DioErrorType.RECEIVE_TIMEOUT:
              case DioErrorType.SEND_TIMEOUT:
              case DioErrorType.CONNECT_TIMEOUT:
              case DioErrorType.RESPONSE:
              case DioErrorType.DEFAULT:
                {
                  Future.delayed(Duration(milliseconds: 50)).then((value) {
                    if (_dialogContext != null) {
                      Navigator.pop(_dialogContext);
                      _dialogContext = null;
                    }
                    setState(() {
                      _showBanner = true;
                      _bannerAction = null;
                      _bannerMessage = Text(
                          "${e.error}\n\nPlease check your internet connection");
                    });
                  });
                }
            }
            print(e);
          } on NoResultException catch (e) {
            Future.delayed(Duration(milliseconds: 50)).then((value) {
              if (_dialogContext != null) {
                Navigator.pop(_dialogContext);
                _dialogContext = null;
              }
              setState(() {
                _showBanner = true;
                _bannerAction = FlatButton(
                  child: Text("HELP"),
                  onPressed: () {
                    properImageHelp(context, _helpController);
                  },
                );
                _bannerMessage = Text("${e.message}");
              });
            });
            print(e);
          } on Exception catch (e) {
            Future.delayed(Duration(milliseconds: 250)).then((value) {
              if (_dialogContext != null) {
                Navigator.pop(_dialogContext);
                _dialogContext = null;
              }
            });
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

  _loadFailed(bool val) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (_dialogContext != null) {
      Navigator.pop(_dialogContext);
      _dialogContext = null;
    }
    _isFailedtoLoad.value = val;
  }

  Widget _imageLoad() {
    var _eImage = ExtendedImage(
      image: imageProvider(_image),
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      mode: ExtendedImageMode.none,
      enableLoadState: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            {
              return Center(child: CircularProgressIndicator());
            }
          case LoadState.completed:
            {
              _loadFailed(false);
              return ExtendedRawImage(
                image: state.extendedImageInfo?.image,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              );
            }
          case LoadState.failed:
            {
              print("failed");
              _loadFailed(true);
              return Center(
                child: Text("Failed to load image"),
              );
            }
          default:
            {
              return Text("Failed");
            }
        }
      },
    );

    return _eImage;
  }

  Widget _imageViewer() {
    return (_image == null)
        ? Center(
            child: Text(
              'No media selected',
            ),
          )
        : _imageLoad();
  }

  Widget _menuButtons() {
    return ValueListenableBuilder(
      valueListenable: _isFailedtoLoad,
      builder: (context, isFailed, child) {
        return FloatingActionButton(
          tooltip: (_image != null && !isFailed) ? "Search" : "Pick",
          heroTag: null,
          child: (_image != null && !isFailed)
              ? Icon(Icons.search)
              : Icon(Icons.add),
          onPressed: (_image != null && !isFailed)
              ? () {
                  _panelController.close();
                  _loadingDialog();
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
                              title: Text("Pick Media (Image/Video)"),
                              onTap: () {
                                Navigator.pop(context);
                                _panelController.close();
                                if (_isFailedtoLoad.value) {
                                  setState(() {
                                    _image = null;
                                  });
                                }
                                _getMedia();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.insert_link),
                              title: Text("Pick from URL (Image/Video)"),
                              onTap: () {
                                Navigator.pop(context);
                                _panelController.close();
                                if (_isFailedtoLoad.value) {
                                  setState(() {
                                    _image = null;
                                  });
                                }
                                _pickURL();
                              },
                            )
                          ],
                        );
                      });
                },
        );
      },
    );
  }

  //Flutter MaterialBanner
  Widget _banner() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  start: 16.0, top: 24.0, end: 16.0, bottom: 4.0),
              child: _bannerMessage,
            ),
          ),
          ButtonBar(alignment: MainAxisAlignment.spaceBetween, children: [
            FlatButton(
              child: Text("DISMISS"),
              onPressed: _hideBanner,
            ),
            Row(
              children: [
                FlatButton(
                  child: Text("RETRY"),
                  onPressed: () {
                    _loadingDialog();
                    Future.delayed(Duration(milliseconds: 50))
                        .then((value) => _search());
                  },
                ),
                (_bannerAction != null) ? _bannerAction : SizedBox()
              ],
            ),
          ])
        ],
      ),
    );
  }

  _addInfoHelp() {
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
                        <p>If switched on, will return available additional information based on search result type (e.g. Anime airing info and description, H-Manga tags).</p>
                        <p>Not each type of search result has additional information
                        </br>It will be gradually added in future updates.</p>
                        """,
                        onLinkTap: (url) {
                          print(url);
                          launch(url);
                        },
                        style: {
                          'p': Style(
                              fontSize: FontSize(
                                  14 * MediaQuery.of(context).textScaleFactor))
                        },
                      )),
                ),
              ),
            ),
            actions: [
              FlatButton(
                child: Text("CLOSE"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _searchEngineHelp() {
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
                        <p><a href='https://www.saucenao.com'><b>SauceNAO</b></a>: search engine for manga, artwork, movie/tv series, anime, and many more. Pick SauceNAO and refer to index option for what this app provides.
                        <p>Uncheck box to filter out search result or to have more precise source (i.e. Danbooru/Gelbooru).
                        <p>Refer to <a href='https://saucenao.com/status.html'>Indexing Status</a> for why some indexes have not option in this app.</p>
                        <p>For more information: <a href='https://saucenao.com/about.html'>About SauceNAO</a></p>
                        <hr>
                        <p><a href='https://trace.moe/'><b>Trace</b></a>: Trace or WAIT(What Anime Is This?) is search engine for anime. Performs relatively better for searching anime and will return short video.
                        <p>For more information: <a href='https://trace.moe/about'>About Trace(WAIT)</a></p>
                        """,
                        onLinkTap: (url) {
                          print(url);
                          launch(url);
                        },
                        style: {
                          'p': Style(
                              fontSize: FontSize(
                                  14 * MediaQuery.of(context).textScaleFactor))
                        },
                      )),
                ),
              ),
            ),
            actions: [
              FlatButton(
                child: Text("CLOSE"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Widget _mainBody() {
    return SlidingUpPanel(
      body: Padding(
          padding:
              EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 48),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _imageViewer(),
              ),
              (_showBanner) ? _banner() : SizedBox(),
            ],
          )),
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
              // MaterialButton(
              //   shape: CircleBorder(),
              //   onPressed: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) {
              //       return AboutPage();
              //     }));
              //   },
              //   child: Icon(Icons.info_outline),
              // ),
            ],
          )),
      renderPanelSheet: true,
      panel: Padding(
        padding: EdgeInsets.fromLTRB(0, 48, 0, 48),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Get Additional Information",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      Flexible(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                            child: IconButton(
                              color: Colors.black45,
                              icon: Icon(Icons.info),
                              onPressed: () {
                                _addInfoHelp();
                              },
                            ),
                          ),
                          Switch(
                            value: _getAddInfo ?? false,
                            onChanged: (val) {
                              setState(() {
                                _getAddInfo = val;
                                SharedPreferencesUtils.setAddInfo(val);
                              });
                            },
                          )
                        ]),
                      ),
                    ],
                  )),
              Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Search Engine",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    Flexible(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Flexible(
                          child: IconButton(
                            color: Colors.black45,
                            icon: Icon(Icons.info),
                            onPressed: () {
                              _searchEngineHelp();
                            },
                          ),
                        ),
                        DropdownButton<SearchOption>(
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
                      ]),
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
                              SharedPreferencesUtils.setAllDB(true);
                              _isAllDB = true;
                              _sauceNaoDBMask.updateAll((key, value) => '1');
                            } else {
                              SharedPreferencesUtils.setAllDB(false);
                              _isAllDB = false;
                              _sauceNaoDBMask.updateAll((key, value) => '0');
                              //_expandedTileController.expand();
                            }
                          });
                        },
                        value: _isAllDB,
                      ),
                      controller: _expandedTileController,
                      title: Text("SauceNAO Indexes"),
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
            child: ValueListenableBuilder(
                valueListenable: _isFailedtoLoad,
                child: Row(
                  children: [
                    Flexible(
                      child: FlatButton(
                        child: Container(
                          height: 48,
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () {
                          _loadFailed(false);
                          setState(() {
                            _image = null;
                          });
                        },
                      ),
                    ),
                    Flexible(
                      child: FlatButton(
                        child: Container(
                          height: 48,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          _editImage();
                        },
                      ),
                    ),
                  ],
                ),
                builder: (context, isFailed, child) {
                  return (_image == null || isFailed) ? SizedBox() : child;
                }),
          )
        ],
      ),
    );
  }

  _expansionTileListener() {
    if (_expandedTileController.isExpanded) {
      _panelController.open();
    }
  }

  _showSnackBar(String msg,
      {SnackBarAction act, Duration dur = const Duration(seconds: 2)}) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("$msg"),
      behavior: SnackBarBehavior.floating,
      action: act,
      duration: dur,
    ));
  }

  bool _isAllDBBox() {
    return (_sauceNaoDBMask.values.contains('0')
        ? ((_sauceNaoDBMask.values.every((element) => element == '0'))
            ? false
            : null)
        : true);
  }

  _hideBanner() {
    setState(() {
      _showBanner = false;
    });
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
    ScreenUtil.init();

    _expandedTileController.addListener(_expansionTileListener);

    _initOptions();
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
    _intentDataStreamSubscription.cancel();
    _urlController.dispose();
    _expandedTileController.dispose();
    super.dispose();
  }
}
