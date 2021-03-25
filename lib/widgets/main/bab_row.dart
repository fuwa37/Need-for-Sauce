import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:need_for_sauce/common/notifier.dart'
    show ImageNotifier, ErrorBannerNotifier;

class ImageControlBar extends StatelessWidget {
  final Function() editImage;

  ImageControlBar({@required this.editImage});

  @override
  Widget build(BuildContext context) {
    final ErrorBannerNotifier _errorBannerNotifier =
        Provider.of<ErrorBannerNotifier>(context);
    return Consumer<ImageNotifier>(
      builder: (context, imageNotifier, child) {
        return AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            child: (imageNotifier.isImageLoaded)
                ? Row(
                    children: [
                      Flexible(
                        child: TextButton(
                          child: Container(
                            height: 48,
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                          onPressed: () {
                            imageNotifier.setImage(null);
                            imageNotifier.setLoaded(false);
                            _errorBannerNotifier.setPop(false);
                          },
                        ),
                      ),
                      Flexible(
                        child: TextButton(
                          child: Container(
                            height: 48,
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            editImage();
                          },
                        ),
                      ),
                    ],
                  )
                : SizedBox());
      },
    );
  }
}
