import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';

class UpdateDialog extends StatefulWidget {
  final String oldV;
  final String newV;
  final String url;

  UpdateDialog(this.oldV, this.newV, this.url);

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
    String filePath = temp.path + '/need_for_sauce' + widget.newV + '.apk';

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
                width: ScreenUtil().setWidth(200),
                height: ScreenUtil().setHeight(100),
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

  UpdatePage(this.oldV, this.newV, this.url, this.size);

  @override
  State<StatefulWidget> createState() {
    return _UpdatePageState();
  }
}

class _UpdatePageState extends State<UpdatePage> {
  String _newFilePath;

  Future<bool> _checkFile() async {
    Directory temp = await getTemporaryDirectory();
    _newFilePath = temp.path + '/need_for_sauce' + widget.newV + '.apk';

    return File(_newFilePath).exists();
  }

  Widget _newFileExist() {
    return FutureBuilder(
      future: _checkFile(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return ListTile(
            dense: true,
            subtitle: Text("New version has been downloaded"),
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
                        widget.oldV,
                        widget.newV,
                        widget.url,
                      )).then((v) {
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
  String appName = '';
  String packageName = '';
  String version = '';

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

  getLatestVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    print(androidInfo.isPhysicalDevice);

    String abi = androidInfo.supportedAbis[0];

    var response;

    try {
      response = await http.get(
          "https://api.github.com/repos/irs37/Need-for-Sauce/releases/latest");
    } on Exception catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Can't check new version"),
            );
          });
      return;
    }

    if (version == null) {
      return;
    }

    var release = jsonDecode(response.body);
    var tag = release['tag_name'];
    List assets = release['assets'];

    if (_isNewerVersion(version, tag) && assets.isNotEmpty) {
      String apkURL;
      String apkSize;

      var defaultAPKAsset;

      for (Map<String, dynamic> i in assets) {
        if (i['name'].contains(abi)) {
          apkURL = i['browser_download_url'];
          apkSize = (i['size']/1024).truncate().toString();
          break;
        } else {
          if (i['name'] == "app-release.apk") {
            defaultAPKAsset = i;
          }
        }
      }

      if (apkURL == null) {
        apkURL = defaultAPKAsset['browser_download_url'];
        apkSize = (defaultAPKAsset['size']/1024).truncate().toString();
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return UpdatePage(version, tag, apkURL, apkSize);
      }));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("No new version"),
            );
          });
    }
  }

  initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('About'),
        ),
        body: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Name'),
                subtitle: Text(appName),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Version'),
                subtitle: Text(version),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('App ID'),
                subtitle: Text(packageName),
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
                    getLatestVersion();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
