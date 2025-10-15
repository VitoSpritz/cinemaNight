import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'multi.dart';

part 'media_with_poster.freezed.dart';

@freezed
abstract class MediaWithPoster with _$MediaWithPoster {
  const factory MediaWithPoster({
    required Multi media,
    Uint8List? posterBytes,
  }) = _MediaWithPoster;
}
