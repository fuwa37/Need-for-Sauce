import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info/device_info.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:need_for_sauce/common/notifier.dart';
import 'package:provider/provider.dart';
import 'package:markdown/markdown.dart' show markdownToHtml;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class UpdateDialog extends StatefulWidget {
  final String oldV;
  final String newV;
  final String url;
  final String path;

  UpdateDialog(
      {@required this.oldV,
      @required this.newV,
      @required this.url,
      @required this.path});

  @override
  State<StatefulWidget> createState() {
    return _UpdateDialogState();
  }
}

class _UpdateDialogState extends State<UpdateDialog> {
  int _fileSize = 0;
  int _received = 0;
  CancelToken token;
  double value = 0;
  Future _future;

  Future _download() async {
    Directory temp = await getTemporaryDirectory();
    String filePath = temp.path + '/need_for_sauce-' + widget.newV + '.apk';

    try {
      token = CancelToken();
      await Dio().download(widget.url, filePath, cancelToken: token,
          onReceiveProgress: (received, total) {
        setState(() {
          value = (received / total);
          _fileSize = total;
          _received = received;
        });
      });
      Navigator.pop(context);
    } on DioError catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  void initState() {
    _future = _download();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          token.cancel("Back Button");
        } on Exception catch (e) {
          print(e);
        }
        return true;
      },
      child: AlertDialog(
        title: Text("Download Progress"),
        content: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        path.basename(widget.url),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    LinearProgressIndicator(
                      value: (value >= 0 && value <= 1) ? value : null,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text((_received / 1024).truncate().toString()),
                              Text("/"),
                              (_fileSize > 0)
                                  ? Text(
                                      (_fileSize / 1024).truncate().toString())
                                  : Text("~"),
                              Text(" KB")
                            ],
                          ),
                        ),
                        (value >= 0 && value <= 1)
                            ? Text((value * 100).truncate().toString() + "%")
                            : Container(),
                      ],
                    )
                  ],
                ),
              );
            }
            return Container(
              width: ScreenUtil().setWidth(200),
              height: ScreenUtil().setHeight(50),
            );
          },
        ),
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              try {
                token.cancel("Cancel");
              } on Exception catch (e) {
                print(e);
              }
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          )
        ],
      ),
    );
  }
}

class UpdatePage extends StatefulWidget {
  final String oldV;
  final String newV;
  final String url;
  final String size;
  final String changelog;

  UpdatePage(this.oldV, this.newV, this.url, this.size, this.changelog);

  @override
  State<StatefulWidget> createState() {
    return _UpdatePageState();
  }
}

class _UpdatePageState extends State<UpdatePage> {
  String _newFilePath;

  Future<bool> _checkFile() async {
    Directory temp = await getTemporaryDirectory();
    _newFilePath = "${temp.path}/need_for_sauce-${widget.newV}.apk";

    return File(_newFilePath).exists();
  }

  Widget _newFileExist() {
    return FutureBuilder(
      future: _checkFile(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return ListTile(
            dense: true,
            subtitle: Text("Newer version has been downloaded"),
            title: MaterialButton(
              color: Colors.blue,
              child: Text(
                "Install new version",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                OpenFile.open(_newFilePath);
              },
            ),
          );
        }
        return ListTile(
          dense: true,
          subtitle: Text(widget.size + " KB"),
          title: MaterialButton(
            color: Colors.blue,
            child: Text(
              "Download",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => UpdateDialog(
                        oldV: widget.oldV,
                        newV: widget.newV,
                        url: widget.url,
                        path: _newFilePath,
                      )).then((v) {
                OpenFile.open(_newFilePath);
                setState(() {});
              });
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Version"),
      ),
      body: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            ListTile(
              title: Text('Current Version'),
              subtitle: Text(widget.oldV),
            ),
            Divider(),
            ListTile(
              title: Text('New Version'),
              subtitle: Text(widget.newV),
              trailing: FlatButton(
                child: Text("CHANGELOG"),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: MediaQuery(
                                data: MediaQueryData(textScaleFactor: 1),
                                child: Html(
                                  shrinkWrap: true,
                                  data: markdownToHtml(widget.changelog),
                                  style: {
                                    'li': Style(
                                        fontSize: FontSize(14 *
                                            MediaQuery.of(context)
                                                .textScaleFactor))
                                  },
                                )),
                          ),
                        );
                      });
                },
              ),
            ),
            Divider(),
            _newFileExist(),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutPageState();
  }
}

class _AboutPageState extends State<AboutPage> {
  String appName;
  String packageName;
  String version;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String repo = "https://github.com/irs37/Need-for-Sauce";

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  bool _isNewerVersion(String current, String tag) {
    List<String> v1 = current.split('.');
    List<String> v2 = tag.split('.');

    for (int i = 0; i < v1.length; i++) {
      if (int.parse(v2[i]) > int.parse(v1[i])) {
        return true;
      }
    }
    return false;
  }

  _getLatestVersion() async {
    String abi = androidInfo.supportedAbis[0];

    Response response;

    loadingDialog(scaffoldContext: _scaffoldKey.currentContext);

    try {
      response = await Dio().get(
          "https://api.github.com/repos/irs37/Need-for-Sauce/releases/latest");
    } on DioError catch (e) {
      context.read<LoadingNotifier>().popDialog();
      print(e);
      showSnackBar(
        msg:
            "Couldn't check new version. Please check your internet connection.",
        state: _scaffoldKey.currentState,
      );
      return;
    }

    var release = response.data;
    String tag = release['tag_name'].replaceAll('v', '');
    List assets = release['assets'];
    String changelog = release["body"].replaceAll(RegExp(r'\Info:[^]*$'), '');

    if (_isNewerVersion(version, tag) && assets.isNotEmpty) {
      String apkURL;
      String apkSize;

      var defaultAPKAsset;

      try {
        for (Map<String, dynamic> i in assets) {
          if (i['name'].contains(abi)) {
            apkURL = i['browser_download_url'];
            apkSize = (i['size'] / 1024).truncate().toString();
            break;
          } else {
            if (i['name'] == "app-release.apk") {
              defaultAPKAsset = i;
            }
          }
        }

        if (apkURL == null) {
          if (defaultAPKAsset == null) {
            throw NoSupportedApkException("No supported APK");
          }
          apkURL = defaultAPKAsset['browser_download_url'];
          apkSize = (defaultAPKAsset['size'] / 1024).truncate().toString();
        }

        context.read<LoadingNotifier>().popDialog();

        // showSnackBar(
        //     msg: "Newer version available. Please download from here.",
        //     state: _scaffoldKey.currentState,
        //     dur: Duration(seconds: 15),
        //     act: SnackBarAction(
        //       label: "DOWNLOAD",
        //       onPressed: () {
        //         String url = apkURL;
        //         canLaunch(url).then((value) {
        //           if (value) {
        //             // Some chrome versions can't open direct link to apk
        //             launch(url);
        //           }
        //         });
        //       },
        //     ));

        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return AlertDialog(
        //         title: Text(
        //           "New version available",
        //           style: TextStyle(fontSize: 16),
        //         ),
        //         content: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             ListTile(
        //               title: Text("Current version :"),
        //               subtitle: Text("$version"),
        //             ),
        //             ListTile(
        //               title: Text("New version :"),
        //               subtitle: Text("$tag"),
        //             ),
        //           ],
        //         ),
        //         actions: [
        //           FlatButton(
        //             child: Text("CHANGELOG"),
        //             onPressed: () {},
        //           ),
        //           FlatButton(
        //             child: Text("DOWNLOAD"),
        //             onPressed: () {
        //               Navigator.pop(context, true);
        //             },
        //           ),
        //         ],
        //       );
        //     }).then((value) {
        //   if (value != null && value) {}
        // });

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return UpdatePage(version, tag, apkURL, apkSize, changelog);
        }));
      } on NoSupportedApkException catch (e) {
        context.read<LoadingNotifier>().popDialog();
        print(e);
        showSnackBar(
            msg: "$e. Check download page and download manually.",
            state: _scaffoldKey.currentState,
            dur: Duration(seconds: 15),
            act: SnackBarAction(
              label: "OPEN PAGE",
              onPressed: () {
                String url = "$repo/releases/latest";
                canLaunch(url).then((value) {
                  if (value) {
                    launch(url);
                  }
                });
              },
            ));
      } on Exception catch (e) {
        context.read<LoadingNotifier>().popDialog();
        print(e);
        showSnackBar(
            msg: "$e. Check download page.",
            state: _scaffoldKey.currentState,
            dur: Duration(seconds: 15),
            act: SnackBarAction(
              label: "OPEN PAGE",
              onPressed: () {
                String url = "$repo/releases/latest";
                canLaunch(url).then((value) {
                  if (value) {
                    launch(url);
                  }
                });
              },
            ));
      }
    } else {
      context.read<LoadingNotifier>().popDialog();
      showSnackBar(
        msg: "No newer version available.",
        state: _scaffoldKey.currentState,
      );
    }
  }

  initPlatformState() async {
    AppInfo packageInfo = context.read<AppInfo>();
    androidInfo = await deviceInfo.androidInfo;

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            ListTile(
              title: Text('Device Info'),
              subtitle: Text(
                  "Android ${androidInfo?.version?.release ?? ''}, ${(androidInfo == null) ? null : androidInfo?.supportedAbis[0]}"),
            ),
            Divider(),
            ListTile(
              title: Text('App Name'),
              subtitle: Text(appName ?? ''),
            ),
            Divider(),
            ListTile(
              title: Text('App ID'),
              subtitle: Text(packageName ?? ''),
            ),
            Divider(),
            ListTile(
              title: Text('Version'),
              subtitle: Text(version ?? ''),
            ),
            Divider(),
            ListTile(
              title: Text('Repository'),
              subtitle: Text(repo),
              trailing: Icon(Icons.open_in_browser),
              onTap: () {
                canLaunch(repo).then((value) {
                  if (value) launch(repo);
                });
              },
            ),
            Divider(),
            ListTile(
              title: Text('Licenses'),
              trailing: Icon(Icons.open_in_new),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationIcon: Padding(
                    padding: EdgeInsets.all(16),
                    child: Image.asset(
                      "assets/app_icon_circle.png",
                      width: 150,
                      height: 150,
                    ),
                  ),
                  applicationVersion: '$version',
                );
              },
            ),
            Divider(),
            ListTile(
              title: MaterialButton(
                color: Colors.blue,
                child: Text(
                  "Check new version",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _getLatestVersion();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
