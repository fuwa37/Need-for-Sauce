import 'package:flutter/material.dart';
import 'package:need_for_sauce/common/notifier.dart'
    show ImageNotifier, LoadingNotifier;
import 'package:sliding_up_panel/sliding_up_panel.dart' show PanelController;
import 'package:provider/provider.dart';

class _SearchButton extends StatelessWidget {
  final Function() search;
  final PanelController panelController;

  _SearchButton({@required this.search, @required this.panelController});

  @override
  Widget build(BuildContext context) {
    LoadingNotifier loadingNotifier = Provider.of<LoadingNotifier>(context);
    return FloatingActionButton(
      key: ValueKey<bool>(false),
      tooltip: "Search",
      heroTag: null,
      child: Icon(Icons.search),
      onPressed: () {
        panelController.close();
        loadingNotifier.setLoad(true);
        search();
      },
    );
  }
}

class _PickButton extends StatelessWidget {
  final Function() getMedia;
  final Function() pickUrl;
  final PanelController panelController;

  _PickButton(
      {@required this.getMedia,
      @required this.pickUrl,
      @required this.panelController});

  @override
  Widget build(BuildContext context) {
    ImageNotifier imageNotifier = Provider.of<ImageNotifier>(context);
    return FloatingActionButton(
      key: ValueKey<bool>(true),
      tooltip: "Pick",
      heroTag: null,
      child: Icon(Icons.add),
      onPressed: () {
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
                      panelController.close();
                      if (!imageNotifier.isImageLoaded) {
                        imageNotifier.setImage(null);
                      }
                      getMedia();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.insert_link),
                    title: Text("Pick from URL (Image/Video)"),
                    onTap: () {
                      Navigator.pop(context);
                      panelController.close();
                      if (!imageNotifier.isImageLoaded) {
                        imageNotifier.setImage(null);
                      }
                      pickUrl();
                    },
                  )
                ],
              );
            });
      },
    );
  }
}

class MainButton extends StatelessWidget {
  final Function() getMedia;
  final Function() pickUrl;
  final PanelController panelController;
  final Function() search;

  MainButton({
    @required this.getMedia,
    @required this.pickUrl,
    @required this.panelController,
    @required this.search,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageNotifier>(
      builder: (context, imageNotifier, child) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: (imageNotifier.isImageLoaded)
              ? _SearchButton(search: search, panelController: panelController)
              : _PickButton(
                  getMedia: getMedia,
                  pickUrl: pickUrl,
                  panelController: panelController),
        );
      },
    );
  }
}
