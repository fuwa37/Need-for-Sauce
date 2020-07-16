// https://github.com/fluttercandies/extended_image/blob/7bd4ef0ccda369e8526357f4797bb4acaa198e10/example/lib/common/crop_editor_helper.dart

import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart';
import 'package:image_editor/image_editor.dart';

Future<Uint8List> cropImageDataWithNativeLibrary(
    {ExtendedImageEditorState state}) async {
  final cropRect = state.getCropRect();
  final action = state.editAction;

  final rotateAngle = action.rotateAngle.toInt();
  final flipHorizontal = action.flipY;
  final flipVertical = action.flipX;
  final img = state.rawImageData;

  ImageEditorOption option = ImageEditorOption();

  if (action.needCrop) option.addOption(ClipOption.fromRect(cropRect));

  if (action.needFlip)
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));

  if (action.hasRotateAngle) option.addOption(RotateOption(rotateAngle));

  if (PngDecoder().isValidFile(img)) option.outputFormat = OutputFormat.png();

  final result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );

  return result;
}
