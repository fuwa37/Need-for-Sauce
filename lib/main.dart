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
import 'package:need_for_sauce/widgets/main/bab_row.dart';
import 'package:need_for_sauce/widgets/main/main_button.dart';
import 'package:need_for_sauce/widgets/main/image_viewer.dart';
import 'package:need_for_sauce/widgets/main/banner.dart';
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
import 'package:expandable/expandable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:need_for_sauce/common/notifier.dart';

void main() => runApp(ChangeNotifierProvider(
    create: (context) => LoadingNotifier(), child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: "Need for Sauce",
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ImageNotifier()),
          ChangeNotifierProvider(create: (context) => ErrorBannerNotifier()),
          ChangeNotifierProvider(create: (context) => SearchOptionNotifier())
        ],
        child: HomePage(),
      ),
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
  ExpandableController _expandableController = ExpandableController();

  _getMedia({File videoIntent}) async {
    print(await Permission.mediaLibrary.request());
    print(await Permission.storage.request());

    ImageNotifier _imageNotifier =
        Provider.of<ImageNotifier>(context, listen: false);

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
        _imageNotifier.setImage(result);
      } else {
        _imageNotifier.setImage(media);
      }
    } else if (fileType[0] == 'video') {
      Uint8List result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoCapture(media ?? videoIntent);
      }));
      if (result == null && videoIntent == null) _getMedia();

      _imageNotifier.setImage(result);
    } else {
      return;
    }
  }

  _editImage() async {
    ImageNotifier _imageNotifier =
        Provider.of<ImageNotifier>(context, listen: false);
    Uint8List result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditor(_imageNotifier.image);
    }));
    if (result == null) return;

    if (result != null) {
      _imageNotifier.setImage(result);
    }
  }

  _checkURLContentType(url) async {
    Response r;
    ImageNotifier _imageNotifier =
        Provider.of<ImageNotifier>(context, listen: false);
    LoadingNotifier _loadingNotifier = context.read<LoadingNotifier>();
    try {
      var token = CancelToken();
      loadingDialog(scaffoldContext: _scaffoldKey.currentContext, token: token);
      r = await Dio().head(url,
          options: Options(sendTimeout: 1000, receiveTimeout: 1000),
          cancelToken: token);
    } on DioError catch (e) {
      print(e);
      _loadingNotifier.popDialog();
      return;
    }
    Headers headers = r.headers;
    String _type = headers['content-type'][0];
    if (_type.split('/')[0] == 'image') {
      Uint8List result;
      if (_type.split('/')[1] == 'gif') {
        result =
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GifCapture(url);
        }));
        if (result == null) _getMedia();
        _imageNotifier.setImage(result);
        _loadingNotifier.popDialog();
      } else {
        _imageNotifier.setImage(url);
      }
      _loadingNotifier.popDialog();
      return;
    } else if (_type.split('/')[0] == 'video') {
      Uint8List result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoCapture(url);
      }));
      _imageNotifier.setImage(result);
      _loadingNotifier.popDialog();
      return;
    } else {
      print("Not image/video");
      _loadingNotifier.popDialog();
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
    var mask =
        sauceNaoDBMask(context.read<SearchOptionNotifier>().sauceNaoMask);
    var image = context.read<ImageNotifier>().image;
    var token = CancelToken();
    loadingDialog(scaffoldContext: _scaffoldKey.currentContext, token: token);

    if (image is String) {
      try {
        return await Sauce.sauceNao(mask)
            .get("&url=" + Uri.encodeComponent(image), cancelToken: token);
      } on DioError catch (e) {
        throw e;
      }
    } else {
      FormData formData = FormData.fromMap({
        "file": await _uploadedType(image),
      });

      try {
        return await Sauce.sauceNao(mask)
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
    var image = context.read<ImageNotifier>().image;
    var token = CancelToken();
    loadingDialog(scaffoldContext: _scaffoldKey.currentContext, token: token);
    if (image is String) {
      try {
        return await Sauce.trace()
            .get("?url=" + Uri.encodeComponent(image), cancelToken: token);
      } on DioError catch (e) {
        throw e;
      }
    } else {
      FormData formData = FormData.fromMap({
        "image": (image is File)
            ? base64Encode(image.readAsBytesSync())
            : (image is List<int>) ? base64Encode(image) : null,
      });

      try {
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
    ErrorBannerNotifier _errorBannerNotifier =
        context.read<ErrorBannerNotifier>();
    LoadingNotifier _loadingNotifier = context.read<LoadingNotifier>();
    SearchOptionNotifier _searchOptionNotifier =
        context.read<SearchOptionNotifier>();
    switch (_searchOptionNotifier.searchOption) {
      case SearchOption.SauceNao:
        {
          if (_searchOptionNotifier.isAllIndexes != false) {
            try {
              var r = await _sauceNaoConn();
              if (r?.data != null) {
                var sauces = SauceNaoObject.fromJson(r.data);
                if (sauces?.results != null) {
                  var sauce = sauces.results[0];
                  var data = sauce.toSauceNaoData();
                  if (data is SauceNaoH18 && _searchOptionNotifier.getAddInfo) {
                    try {
                      sauce.data = await data.withInfo();
                      _loadingNotifier.popDialog();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SauceDesc(
                            SauceObject.fromSauceNao(sauce.header, sauce.data));
                      }));
                    } on NoInfoException catch (e) {
                      print(e);
                      _loadingNotifier.popDialog();
                      _errorBannerNotifier.setPop(true);
                      _errorBannerNotifier.setUpBanner(
                          message: Text(
                            "$e",
                            textAlign: TextAlign.start,
                          ),
                          action: FlatButton(
                            child: Text("CONTINUE"),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SauceDesc(SauceObject.fromSauceNao(
                                    sauce.header, sauce.data));
                              }));
                              _errorBannerNotifier.setPop(false);
                            },
                          ));
                    }
                  } else {
                    _loadingNotifier.popDialog();
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
              _loadingNotifier.popDialog();
              _errorBannerNotifier.setPop(true);
              _errorBannerNotifier.setUpBanner(
                  message: MediaQuery(
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
                              fontSize: FontSize(
                                  14 * MediaQuery.of(context).textScaleFactor))
                        },
                      )),
                  action: null);
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
                    _loadingNotifier.popDialog();
                    _errorBannerNotifier.setPop(true);
                    _errorBannerNotifier.setUpBanner(
                        message: Text(
                            "${e.error}\n\nPlease check your internet connection"),
                        action: null);
                  }
              }
              print(e);
            } on NoResultException catch (e) {
              _loadingNotifier.popDialog();
              _errorBannerNotifier.setPop(true);
              _errorBannerNotifier.setUpBanner(
                  message: Text("${e.message}"),
                  action: FlatButton(
                    child: Text("HELP"),
                    onPressed: () {
                      properImageHelp(context, _helpController);
                    },
                  ));
              print(e);
            } on Exception catch (e) {
              _loadingNotifier.popDialog();
              _errorBannerNotifier.setPop(true);
              _errorBannerNotifier.setUpBanner(
                  message: Text("$e"), action: null);
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
            _expandableController.expanded = true;
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
                if (_searchOptionNotifier.getAddInfo) {
                  sauce = await sauce.withInfo();
                  _loadingNotifier.popDialog();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SauceDesc(SauceObject.fromTrace(sauce));
                  }));
                } else {
                  _loadingNotifier.popDialog();
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
                  _loadingNotifier.popDialog();
                  _errorBannerNotifier.setPop(true);
                  _errorBannerNotifier.setUpBanner(
                      message: Text(
                          "${e.error}\n\nPlease check your internet connection"),
                      action: null);
                }
            }
            print(e);
          } on NoResultException catch (e) {
            _loadingNotifier.popDialog();
            _errorBannerNotifier.setPop(true);
            _errorBannerNotifier.setUpBanner(
                message: Text("${e.message}"),
                action: FlatButton(
                  child: Text("HELP"),
                  onPressed: () {
                    properImageHelp(context, _helpController);
                  },
                ));

            print(e);
          } on Exception catch (e) {
            _loadingNotifier.popDialog();
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

  Widget _mainBody(BuildContext context) {
    return SlidingUpPanel(
      body: Padding(
          padding:
              EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 48),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ImageViewer(),
              ),
              ErrorBanner(
                search: _search,
              )
            ],
          )),
      backdropEnabled: true,
      controller: _panelController,
      onPanelClosed: () {
        try {
          _expandableController?.expanded = false;
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
          height: 56,
          color: Colors.blue,
          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListTile(
                  onTap: () {
                    if (_panelController.isPanelOpen) {
                      _panelController.close();
                    } else {
                      _panelController.open();
                    }
                  },
                  title: Text(
                    "Options",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
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
      panel: Consumer<SearchOptionNotifier>(
          builder: (context, searchOptionNotifier, child) {
        var _widthConstraint = (ScreenUtil.screenWidth - 32) / 3;
        if (_widthConstraint < 125)
          _widthConstraint = (ScreenUtil.screenWidth - 32) / 2;
        return Padding(
          padding: EdgeInsets.fromLTRB(0, 56, 0, 0),
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
                                icon: const Icon(Icons.info),
                                onPressed: () {
                                  _addInfoHelp();
                                },
                              ),
                            ),
                            Switch(
                              value: searchOptionNotifier.getAddInfo ?? false,
                              onChanged: (val) {
                                searchOptionNotifier.setGetAddInfo(val);
                                SharedPreferencesUtils.setAddInfo(val);
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
                            value: searchOptionNotifier.searchOption,
                            onChanged: (val) {
                              SharedPreferencesUtils.setSourceOption(val);
                              searchOptionNotifier.setSearchOption(val);
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
                (searchOptionNotifier.searchOption != SearchOption.SauceNao)
                    ? SizedBox()
                    : ExpandablePanel(
                        theme: ExpandableThemeData(
                            animationDuration: Duration(milliseconds: 150),
                            useInkWell: true),
                        controller: _expandableController,
                        header: ListTile(
                          leading: Checkbox(
                            tristate: true,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              if (searchOptionNotifier.isAllIndexes == null ||
                                  (val ?? false)) {
                                SharedPreferencesUtils.setAllIndexes(true);
                                searchOptionNotifier.isAllIndexes = true;
                                searchOptionNotifier.setAllSauceNaoMask('1');
                              } else {
                                SharedPreferencesUtils.setAllIndexes(false);
                                searchOptionNotifier.isAllIndexes = false;
                                searchOptionNotifier.setAllSauceNaoMask('0');
                              }
                            },
                            value: searchOptionNotifier.isAllIndexes,
                          ),
                          title: Text("SauceNAO Indexes"),
                        ),
                        expanded: Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Wrap(
                            children: searchOptionNotifier.sauceNaoMask.entries
                                .map((e) {
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
                                      SharedPreferencesUtils.setSauceNaoMask(
                                          e.key, (val) ? '1' : '0');
                                      searchOptionNotifier.setSauceNaoMask(
                                          e.key, (val) ? '1' : '0');
                                    }),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                SizedBox(
                  height: (_expandableController.expanded) ? 76 : 0,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _bab(BuildContext context) {
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
            child: ImageControlBar(
              editImage: _editImage,
            ),
          )
        ],
      ),
    );
  }

  _expandableListener() {
    if (_expandableController.expanded) {
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

  @override
  void initState() {
    super.initState();
    ImageNotifier _imageNotifier =
        Provider.of<ImageNotifier>(context, listen: false);

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value?.isNotEmpty ?? false) {
        if (value[0].type == SharedMediaType.IMAGE) {
          _imageNotifier.setImage(File(value[0].path));
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
          _imageNotifier.setImage(File(value[0].path));
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

    _expandableController.addListener(_expandableListener);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
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
        body: _mainBody(context),
        bottomNavigationBar: _bab(context),
        floatingActionButton: MainButton(
          getMedia: _getMedia,
          pickUrl: _pickURL,
          panelController: _panelController,
          search: _search,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        extendBodyBehindAppBar: true,
      ),
    );
  }

  @override
  dispose() {
    _intentDataStreamSubscription.cancel();
    _urlController.dispose();
    _expandableController.dispose();
    super.dispose();
  }
}
