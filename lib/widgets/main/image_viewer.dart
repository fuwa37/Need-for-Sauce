import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:need_for_sauce/common/common.dart'
    show imageProvider;
import 'package:provider/provider.dart';
import 'package:need_for_sauce/common/notifier.dart' show ImageNotifier;

class ImageViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageNotifier>(
      builder: (context, imageNotifier, child) {
        return (imageNotifier.image == null)
            ? Center(
                child: Text("No Media Selected"),
              )
            : ExtendedImage(
                image: imageProvider(imageNotifier.image),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                mode: ExtendedImageMode.none,
                enableLoadState: true,
                loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      {
                        Future.microtask(() => imageNotifier.setLoaded(false));
                        return Center(child: CircularProgressIndicator());
                      }
                    case LoadState.completed:
                      {
                        Future.microtask(() => imageNotifier.setLoaded(true));
                        return ExtendedRawImage(
                          image: state.extendedImageInfo?.image,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      }
                    case LoadState.failed:
                      {
                        Future.microtask(() => imageNotifier.setLoaded(false));
                        return Center(
                          child: Text("Failed to load image"),
                        );
                      }
                    default:
                      {
                        Future.microtask(() => imageNotifier.setLoaded(false));
                        return Text("Failed");
                      }
                  }
                },
              );
      },
    );
  }
}
