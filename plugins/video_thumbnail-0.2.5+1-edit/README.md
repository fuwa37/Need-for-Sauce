# video_thumbnail

This plugin generates thumbnail from video file or URL.  It returns image in memory or writes into a file.  It offers rich options to control the image format, resolution and quality.  Supports iOS and Android.

  [![pub ver](https://img.shields.io/badge/pub-v0.2.5+1--orange)](https://pub.dev/packages/video_thumbnail)
  [![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/justsoft/)

![video-file](https://github.com/justsoft/video_thumbnail/blob/master/video_file.png?raw=true) ![video-url](https://github.com/justsoft/video_thumbnail/blob/master/video_url.png?raw=true)

## Methods
|function|parameter|description|return|
|--|--|--|--|
|thumbnailData|String `[video]`, ImageFormat `[imageFormat]`(JPEG/PNG/WEBP), int `[maxHeight]`(0: for the original resolution of the video, or scaled by the source aspect ratio), [maxWidth]`(0: for the original resolution of the video, or scaled by the source aspect ratio), int `[timeMs]` generates the thumbnail from the frame around the specified millisecond, int `[quality]`(0-100)|generates thumbnail from `[video]`|`[Future<Uint8List>]`|
|thumbnailFile|String `[video]`, String `[thumbnailPath]`(folder or full path where to store the thumbnail file, null to save to same folder as the video file), ImageFormat `[imageFormat]`(JPEG/PNG/WEBP), int `[maxHeight]`(0: for the original resolution of the video, or scaled by the source aspect ratio), int `[maxWidth]`(0: for the original resolution of the video, or scaled by the source aspect ratio), int `[timeMs]` generates the thumbnail from the frame around the specified millisecond, int `[quality]`(0-100)|creates a file of the thumbnail from the `[video]` |`[Future<String>]`|

Warning:
> Giving both the `maxHeight` and `maxWidth` has different result on Android platform, it actually scales the thumbnail to the specified maxHeight and maxWidth.
> To generate the thumbnail from a network resource, the `video` must be properly URL encoded.

## Usage

**Installing**
add [video_thumbnail](https://pub.dev/packages/video_thumbnail) as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  video_thumbnail: ^0.2.5+1
```
**import**
```dart
import 'package:video_thumbnail/video_thumbnail.dart';
```
**Generate a thumbnail in memory from video file**
```dart
final uint8list = await VideoThumbnail.thumbnailData(
  video: videofile.path,
  imageFormat: ImageFormat.JPEG,
  maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
  quality: 25,
);
```

**Generate a thumbnail file from video URL**
```dart
final uint8list = await VideoThumbnail.thumbnailFile(
  video: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
  thumbnailPath: (await getTemporaryDirectory()).path,
  imageFormat: ImageFormat.WEBP,
  maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
  quality: 75,
);
```

## Notes
Fork or pull requests are always welcome. Currently it seems have a little performance issue while generating WebP thumbnail by using libwebp under iOS.
