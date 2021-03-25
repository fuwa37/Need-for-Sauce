import 'package:flutter/material.dart';
import 'package:need_for_sauce/common/notifier.dart'
    show ErrorBannerNotifier, LoadingNotifier;
import 'package:provider/provider.dart';

class ErrorBanner extends StatelessWidget {
  final Function search;

  ErrorBanner({@required this.search});

  @override
  Widget build(BuildContext context) {
    LoadingNotifier loadingNotifier = Provider.of<LoadingNotifier>(context);
    return Consumer<ErrorBannerNotifier>(
      builder: (context, errorBannerNotifier, child) {
        return (errorBannerNotifier.isPopUp)
            ? Card(
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
                        child: errorBannerNotifier.bannerMessage,
                      ),
                    ),
                    ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Text("DISMISS"),
                            onPressed: () {
                              errorBannerNotifier.setPop(false);
                            },
                          ),
                          Row(
                            children: [
                              TextButton(
                                child: Text("RETRY"),
                                onPressed: () {
                                  errorBannerNotifier.setPop(false);
                                  loadingNotifier.setLoad(true);
                                  search();
                                },
                              ),
                              (errorBannerNotifier.bannerAction != null)
                                  ? errorBannerNotifier.bannerAction
                                  : SizedBox()
                            ],
                          ),
                        ])
                  ],
                ),
              )
            : SizedBox();
      },
    );
  }
}
