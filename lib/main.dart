import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mime/mime.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:need_for_sauce/common/http_request.dart';
import 'package:need_for_sauce/common/notifier.dart';
import 'package:need_for_sauce/common/shared_preferences_helper.dart';
import 'package:need_for_sauce/models/models.dart';
import 'package:need_for_sauce/pages/about.dart';
import 'package:need_for_sauce/pages/editors/gif_capture.dart';
import 'package:need_for_sauce/pages/editors/image_editor.dart';
import 'package:need_for_sauce/pages/editors/video_capture.dart';
import 'package:need_for_sauce/pages/sauce.dart';
import 'package:need_for_sauce/widgets/main/bab_row.dart';
import 'package:need_for_sauce/widgets/main/banner.dart';
import 'package:need_for_sauce/widgets/main/custom_alert_dialog.dart';
import 'package:need_for_sauce/widgets/main/image_viewer.dart';
import 'package:need_for_sauce/widgets/main/main_button.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LoadingNotifier()),
    ChangeNotifierProvider(create: (context) => AppInfo()),
  ], child: MyApp()));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ScreenUtilInit(
      builder: () => MaterialApp(
        title: "Need for Sauce",
        theme: ThemeData(
            brightness: Brightness.light,
            textTheme: TextTheme(
                headline5: TextStyle(color: Colors.white, fontSize: 18),
                headline6: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            primaryIconTheme: IconThemeData(color: Colors.white),
            iconTheme: IconThemeData(color: Colors.black),
            accentIconTheme: IconThemeData(color: Colors.grey),
            floatingActionButtonTheme: FloatingActionButtonThemeData(),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white, primary: Colors.blue))),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                onPrimary: Colors.blue, primary: Colors.red),
          ),
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ImageNotifier()),
            ChangeNotifierProvider(create: (context) => ErrorBannerNotifier()),
            ChangeNotifierProvider(create: (context) => SearchOptionNotifier()),
          ],
          child: HomePage(),
        ),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  StreamSubscription _intentDataStreamSubscription;
  GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  TextEditingController _urlController = TextEditingController();
  TextEditingController _snApiController = TextEditingController();
  GlobalKey<FormState> _urlFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _snApiformKey = GlobalKey<FormState>();
  PanelController _panelController = PanelController();
  ScrollController _helpController = ScrollController();
  ExpandableController _expandableController = ExpandableController();
  var _optionKey = RectGetter.createGlobalKey();
  ValueNotifier<double> _paddingOption = ValueNotifier(0);
  AnimationController _rotateAnimationController;
  ValueNotifier<String> _sauceNaoApi = ValueNotifier('');
  final String _sharedSnApi = SharedPreferencesUtils.getSharedSnApi();

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
      child: ScaffoldMessenger(
        key: _scaffoldKey,
        child: Scaffold(
          body: _mainBody(context),
          bottomNavigationBar: _bab(context),
          floatingActionButton: MainButton(
            getMedia: _getMedia,
            pickUrl: _pickURL,
            panelController: _panelController,
            search: _search,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          resizeToAvoidBottomInset: false,
          extendBody: true,
          extendBodyBehindAppBar: true,
        ),
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

  @override
  void initState() {
    super.initState();
    deleteObsoleteApk();

    SharedPreferencesUtils.getSnApi().then((api) {
      _sauceNaoApi.value = api;
    });

    _rotateAnimationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

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

  Widget _bab(BuildContext context) {
    return BottomAppBar(
      notchMargin: 12,
      shape: CircularNotchedRectangle(),
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () {
              if (_panelController.isPanelClosed) {
                _panelController.animatePanelToSnapPoint();
              } else {
                _panelController.close();
              }
            },
            onLongPress: () {
              if (_panelController.isPanelClosed) {
                _panelController.open();
                _expandableController.value = true;
              } else {
                _panelController.close();
              }
            },
            child: Container(
              child: Center(
                child: Text(
                  "Settings",
                  style: Theme.of(context).textTheme.headline5,
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

  _expandableListener() {
    if (_expandableController.expanded) {
      _panelController.open();
    } else {
      _paddingOption.value = 0;
    }
  }

  _getMedia({File videoIntent}) async {
    print(await Permission.mediaLibrary.request());
    print(await Permission.storage.request());
    FilePickerResult result;
    ImageNotifier _imageNotifier =
        Provider.of<ImageNotifier>(context, listen: false);

    if (videoIntent == null) result = await FilePicker.platform.pickFiles();
    if (result == null && videoIntent == null) return;

    File media = videoIntent ?? File(result.files.single.path);
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
      onPanelSlide: (val) {
        double h = RectGetter.getRectFromKey(_optionKey).height;
        double botpad = 76;
        if (_expandableController.expanded && val != 1.0) {
          _paddingOption.value = h - h / 2 + botpad;
        } else if (_expandableController.expanded && val >= 0.5) {
          _paddingOption.value = botpad;
        }
        if (val >= 0.5) {
          _rotateAnimationController.animateTo(
              mapRange(input: val, x1: 0.5, y1: 1.0, x2: 0.0, y2: 1.0),
              duration: Duration.zero);
        }
      },
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
          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListTile(
                  onTap: () {
                    if (_panelController.isPanelOpen) {
                      _panelController.animatePanelToSnapPoint();
                    } else {
                      _panelController.open();
                    }
                  },
                  title: Text(
                    "Settings",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  leading: RotationTransition(
                    turns: Tween<double>(begin: 0.0, end: 0.5)
                        .animate(_rotateAnimationController),
                    child: Icon(
                      Icons.arrow_drop_up,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  tooltip: "About",
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AboutPage();
                    }));
                  },
                  icon: Icon(
                    Icons.info_outline,
                    size: 26,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                ),
              ),
            ],
          )),
      renderPanelSheet: true,
      panel: Consumer<SearchOptionNotifier>(
          builder: (context, searchOptionNotifier, child) {
        var _widthConstraint = (ScreenUtil().screenWidth - 32) / 3;
        if (_widthConstraint < 125)
          _widthConstraint = (ScreenUtil().screenWidth - 32) / 2;
        return RectGetter(
            key: _optionKey,
            child: Padding(
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
                            child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Additional Information Confirmation",
                                  style: Theme.of(context).textTheme.subtitle1,
                                )),
                          ),
                          Flexible(
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Flexible(
                                child: IconButton(
                                  tooltip: "Help",
                                  icon: Icon(
                                    Icons.help,
                                    color:
                                        Theme.of(context).accentIconTheme.color,
                                  ),
                                  onPressed: () {
                                    _addInfoHelp();
                                  },
                                ),
                              ),
                              DropdownButton<int>(
                                underline: Container(
                                  height: 2,
                                  color:
                                      Theme.of(context).accentIconTheme.color,
                                ),
                                value: searchOptionNotifier.addInfoOption,
                                onChanged: (val) {
                                  SharedPreferencesUtils.setAddInfo(val);
                                  searchOptionNotifier.setAddInfo(val);
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: -1,
                                    child: Text("Always Ask"),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text("Always Yes"),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text("Always No"),
                                  ),
                                ],
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: ListTile(
                                title: Text(
                              "Search Engine",
                              style: Theme.of(context).textTheme.subtitle1,
                            )),
                          ),
                          Flexible(
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Flexible(
                                child: IconButton(
                                  tooltip: "Help",
                                  icon: Icon(
                                    Icons.help,
                                    color:
                                        Theme.of(context).accentIconTheme.color,
                                  ),
                                  onPressed: () {
                                    _searchEngineHelp();
                                  },
                                ),
                              ),
                              DropdownButton<SearchOption>(
                                underline: Container(
                                  height: 2,
                                  color:
                                      Theme.of(context).accentIconTheme.color,
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
                        : ValueListenableBuilder(
                            valueListenable: _sauceNaoApi,
                            builder: (context, String value, child) {
                              return Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: ListTile(
                                        title: Text(
                                          "SauceNAO API Key",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        subtitle: (value?.isEmpty ?? true)
                                            ? Text(
                                                "You are using shared key",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .error,
                                              )
                                            : Text(value),
                                      ),
                                    ),
                                    Flexible(
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: IconButton(
                                                tooltip: "API Key",
                                                icon: Icon(
                                                  Icons.help,
                                                  color: Theme.of(context)
                                                      .accentIconTheme
                                                      .color,
                                                ),
                                                onPressed: () {
                                                  _snApiHelp();
                                                },
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: _snApiDialog,
                                              child: Text(
                                                  ((value?.isEmpty ?? true)
                                                      ? "Set API Key"
                                                      : "API Key")),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                              );
                            }),
                    (searchOptionNotifier.searchOption != SearchOption.SauceNao)
                        ? SizedBox()
                        : ExpandablePanel(
                            theme: ExpandableThemeData(
                                animationDuration: Duration(milliseconds: 150),
                                useInkWell: true),
                            controller: _expandableController,
                            collapsed: null,
                            header: ListTile(
                              leading: Checkbox(
                                tristate: true,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (val) {
                                  if (searchOptionNotifier.isAllIndexes ==
                                          null ||
                                      (val ?? false)) {
                                    SharedPreferencesUtils.setAllIndexes(true);
                                    searchOptionNotifier.isAllIndexes = true;
                                    searchOptionNotifier
                                        .setAllSauceNaoMask('1');
                                  } else {
                                    SharedPreferencesUtils.setAllIndexes(false);
                                    searchOptionNotifier.isAllIndexes = false;
                                    searchOptionNotifier
                                        .setAllSauceNaoMask('0');
                                  }
                                },
                                value: searchOptionNotifier.isAllIndexes,
                              ),
                              title: Text("SauceNAO Indexes"),
                            ),
                            expanded: Container(
                              color: Theme.of(context).hoverColor,
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: Wrap(
                                children: searchOptionNotifier
                                    .sauceNaoMask.entries
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
                                          SharedPreferencesUtils
                                              .setSauceNaoMask(
                                                  e.key, (val) ? '1' : '0');
                                          searchOptionNotifier.setSauceNaoMask(
                                              e.key, (val) ? '1' : '0');
                                        }),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                    ValueListenableBuilder(
                        valueListenable: _paddingOption,
                        builder: (context, value, child) {
                          return SizedBox(
                            height: value,
                          );
                        }),
                  ],
                ),
              ),
            ));
      }),
    );
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
              key: _urlFormKey,
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
              TextButton(
                onPressed: () {
                  _urlController.clear();
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_urlFormKey.currentState.validate()) {
                    Navigator.pop(context);
                    _checkURLContentType(_urlController.text);
                    _urlController.clear();
                  }
                },
                child: Text(
                  "OK",
                ),
              ),
            ],
          );
        });
  }

  Future<Response> _sauceNaoConn() async {
    var mask =
        sauceNaoDBMask(context.read<SearchOptionNotifier>().sauceNaoMask);
    var image = context.read<ImageNotifier>().image;
    var token = CancelToken();
    loadingDialog(scaffoldContext: _scaffoldKey.currentContext, token: token);

    var api = (_sauceNaoApi?.value?.isNotEmpty ?? false)
        ? _sauceNaoApi.value
        : _sharedSnApi;

    if (image is String) {
      try {
        return await Sauce.sauceNao(mask, api)
            .get("&url=" + Uri.encodeComponent(image), cancelToken: token);
      } on DioError catch (e) {
        if (e?.response?.statusCode == 403 ?? false) {
          throw NoPermissionException(e.response);
        }
        if (e?.response?.statusCode == 429 ?? false) {
          throw TooManyRequestException(e.response);
        }
        throw e;
      }
    } else {
      FormData formData = FormData.fromMap({
        "file": await _uploadedType(image),
      });

      try {
        return await Sauce.sauceNao(mask, api)
            .post("", data: formData, cancelToken: token);
      } on DioError catch (e) {
        if (e?.response?.statusCode == 403 ?? false) {
          throw NoPermissionException(e.response);
        }
        if (e?.response?.statusCode == 429 ?? false) {
          throw TooManyRequestException(e.response);
        }
        throw e;
      }
    }
  }

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
                  _loadingNotifier.popDialog();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SaucePage(
                            sauces: sauces,
                            searchOptionNotifier: _searchOptionNotifier);
                      },
                    ),
                  );
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
                        data: (_sauceNaoApi?.value?.isNotEmpty ?? false)
                            ? "Error message: ${sauces.header.message}"
                            : """
                              Shared API key has been used above limit across all applications, please use your own API key.
                              </br>Please refer to Settings->SauceNAO API Key.
                              """,
                        onLinkTap: (url, _, __, ___) {
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
                                  16 * MediaQuery.of(context).textScaleFactor))
                        },
                      )),
                  action: null);
            } on NoPermissionException catch (e) {
              var sauces = SauceNaoObject.fromJson(e.res.data);
              _loadingNotifier.popDialog();
              _errorBannerNotifier.setPop(true);
              _errorBannerNotifier.setUpBanner(
                  message: MediaQuery(
                      data: MediaQueryData(textScaleFactor: 1),
                      child: Html(
                        shrinkWrap: true,
                        data: """
                              Error message: ${sauces.header.message}<hr>
                              </br>Please check your SauceNAO API key setting.
                              """,
                        onLinkTap: (url, _, __, ___) {
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
                                  16 * MediaQuery.of(context).textScaleFactor))
                        },
                      )),
                  action: null);
            } on DioError catch (e) {
              switch (e.type) {
                case DioErrorType.cancel:
                  break;
                case DioErrorType.receiveTimeout:
                case DioErrorType.sendTimeout:
                case DioErrorType.connectTimeout:
                case DioErrorType.response:
                case DioErrorType.other:
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
                  action: TextButton(
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
            showSnackBar(
                msg: "Select at least one index",
                state: _scaffoldKey.currentState,
                dur: Duration(seconds: 2));
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
                if (_searchOptionNotifier.addInfoOption == 1) {
                  try {
                    sauce = await sauce.withInfo();
                    _loadingNotifier.popDialog();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SauceDesc(SauceObject.fromTrace(sauce));
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
                        action: TextButton(
                          child: Text("CONTINUE"),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return SauceDesc(SauceObject.fromTrace(sauce));
                            }));
                            _errorBannerNotifier.setPop(false);
                          },
                        ));
                  }
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
              case DioErrorType.cancel:
                break;
              case DioErrorType.receiveTimeout:
              case DioErrorType.sendTimeout:
              case DioErrorType.connectTimeout:
              case DioErrorType.response:
              case DioErrorType.other:
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
                action: TextButton(
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
                        <p><a href='https://trace.moe/'><b>Trace</b></a>: Trace or WAIT(What Anime Is This?) is search engine for anime. Performs relatively better for searching anime and will return short video if available otherwise an image.
                        <p>For more information: <a href='https://trace.moe/about'>About Trace(WAIT)</a></p>
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

  _snApiDialog() {
    if (_sauceNaoApi?.value?.isNotEmpty ?? false)
      _snApiController.text = _sauceNaoApi.value;
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: Form(
            key: _snApiformKey,
            child: TextFormField(
              autofocus: true,
              controller: _snApiController,
              decoration: InputDecoration(
                labelText: "API Key",
              ),
              validator: (text) {
                if (text.isEmpty) {
                  return "Enter API Key";
                } else {
                  return null;
                }
              },
            ),
          ),
          buttonBarAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            ValueListenableBuilder(
              valueListenable: _sauceNaoApi,
              builder: (context, String value, child) {
                return (value?.isNotEmpty ?? false)
                    ? TextButton(
                        onPressed: () {
                          _snApiController.clear();
                          SharedPreferencesUtils.clearApi();
                          _sauceNaoApi.value = '';
                        },
                        child: Text("Clear",
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.error.color)),
                      )
                    : SizedBox();
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_snApiformKey.currentState.validate()) {
                      Navigator.pop(context);
                      SharedPreferencesUtils.setSnApi(_snApiController.text);
                      _sauceNaoApi.value = _snApiController.text;
                    }
                  },
                  child: Text(
                    "Set",
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _snApiHelp() {
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
                        <p>API key is needed to use SauceNAO API as a search engine.</p>
                        <p>If not set, you are using shared API key which is shared for all aplications and has very limited number of use, and will fail search attempt if has been used above limit.</p>
                        <p>You can get your API key by registering <a href='https://saucenao.com/user.php'>here (SauceNAO)</a>.</p>
                        <p>Go to your account page->settings->API.</p>
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
            : (image is List<int>)
                ? base64Encode(image)
                : null,
      });

      try {
        return await Sauce.trace().post("", data: formData, cancelToken: token);
      } on DioError catch (e) {
        throw e;
      }
    }
  }

  Future _uploadedType(image) async {
    if (image is File)
      return await MultipartFile.fromFile(image.path,
          filename: path.basename(image.path));
    else if (image is List<int>)
      return MultipartFile.fromBytes(image, filename: "temp");
    else
      return image;
  }
}
