import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'media.dart';

part 'media_with_poster.freezed.dart';

@freezed
abstract class MediaWithPoster with _$MediaWithPoster {
  const factory MediaWithPoster({required Media media, Uint8List? poster}) =
      _MediaWithPoster;
}
