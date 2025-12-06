import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/media_converter.dart';
import '../model/media.dart';
import 'tmdb_api.dart';

part 'film_poster.g.dart';

@riverpod
Future<Uint8List?> getFilmDataGivenName(
  Ref ref,
  String filmName,
  String language,
) async {
  final TmdbApi tmdbApi = TmdbApi();

  final List<Media> mediaList = await tmdbApi.getMultiMediaByName(
    name: filmName,
    language: language,
  );

  if (mediaList.isEmpty) {
    return null;
  }

  final String? posterPath = MediaConverter.getValue(
    media: mediaList.first,
    field: MediaField.poster,
  );

  if (posterPath == null || posterPath.isEmpty) {
    return null;
  }

  return await tmdbApi.getMediaPoster(posterPath: posterPath);
}
