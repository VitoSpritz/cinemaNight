import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'media.dart';

part 'multi_with_poster.freezed.dart';

@freezed
abstract class MultiWithPoster with _$MultiWithPoster {
  const factory MultiWithPoster({
    required Media media,
    Uint8List? posterBytes,
  }) = _MultiWithPoster;
}
