import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageHelper {
  static Future<String> fileToBase64(File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  static Uint8List base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }

  static Future<String> fileToBase64Compressed(
    File imageFile, {
    int quality = 85,
  }) async {
    final Uint8List? compressedBytes =
        await FlutterImageCompress.compressWithFile(
          imageFile.absolute.path,
          quality: quality,
          minWidth: 400,
          minHeight: 400,
        );

    return base64Encode(compressedBytes!);
  }
}
