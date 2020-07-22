import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:need_for_sauce/common/shared_preferences_helper.dart';
import 'package:need_for_sauce/common/common.dart';

class ImageNotifier extends ChangeNotifier {
  dynamic image;
  bool isImageLoaded = false;

  void setLoaded(bool isLoaded){
    isImageLoaded = isLoaded;
    notifyListeners();
  }

  void setImage(dynamic set) {
    image = set;
    notifyListeners();
  }
}

class LoadingNotifier extends ChangeNotifier {
  bool isLoading = false;
  BuildContext dialogContext;

  void setLoad(bool isLoad) {
    isLoading = isLoad;
    notifyListeners();
  }

  void setDialogContext(BuildContext context) {
    dialogContext = context;
    notifyListeners();
  }

  void popDialog() {
    if (dialogContext != null) {
      Navigator.pop(dialogContext);
      dialogContext = null;
    }
    notifyListeners();
  }
}

class ErrorBannerNotifier extends ChangeNotifier {
  bool isPopUp = false;
  Widget bannerMessage;
  Widget bannerAction;

  void setUpBanner({@required Widget message, Widget action}) {
    bannerMessage = message;
    bannerAction = action;
    notifyListeners();
  }

  void setPop(bool isPop) {
    if (!isPop) {
      bannerMessage = null;
      bannerAction = null;
    }
    isPopUp = isPop;
    notifyListeners();
  }
}

class SearchOptionNotifier extends ChangeNotifier {
  SearchOption searchOption;
  bool getAddInfo;
  SplayTreeMap<String, String> sauceNaoMask;
  bool isAllIndexes;

  SearchOptionNotifier() {
    _initOptions();
  }

  void setGetAddInfo(bool val) {
    getAddInfo = val;
    notifyListeners();
  }

  void setSearchOption(SearchOption val) {
    searchOption = val;
    notifyListeners();
  }

  void setAllSauceNaoMask(String val) {
    sauceNaoMask.updateAll((key, value) => val);
    notifyListeners();
  }

  void setSauceNaoMask(String key, String val) {
    sauceNaoMask[key] = val;
    if (sauceNaoMask.values.contains('0')) {
      if (sauceNaoMask.values.contains('1')) {
        isAllIndexes = null;
      } else {
        isAllIndexes = false;
      }
    } else {
      isAllIndexes = true;
    }
    notifyListeners();
  }

  bool _isAllIndexes() {
    return (sauceNaoMask.values.contains('0')
        ? ((sauceNaoMask.values.every((element) => element == '0'))
            ? false
            : null)
        : true);
  }

  void _initOptions() async {
    searchOption = await SharedPreferencesUtils.getSourceOption();
    getAddInfo = await SharedPreferencesUtils.getAddInfo();
    sauceNaoMask =
        SplayTreeMap.from(await SharedPreferencesUtils.getSauceNaoMask());
    isAllIndexes = _isAllIndexes();
    notifyListeners();
  }
}

class GifNotifier extends ChangeNotifier {
  int imageIdx = 0;
  bool isRepeated = false;

  void setImageIdx(int idx) {
    if (imageIdx == idx) return;
    imageIdx = idx;
    notifyListeners();
  }

  void setRepeated(bool val) {
    if (isRepeated == val) return;
    isRepeated = val;
    notifyListeners();
  }
}