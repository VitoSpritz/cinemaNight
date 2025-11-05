import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';
part 'movie.g.dart';

@freezed
abstract class Movie with _$Movie {
  const factory Movie({
    required int id,
    required String title,
    @Default('') String overview,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'poster_path') String? posterPath,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'vote_average') @Default(0.0) double voteAverage,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'vote_count') @Default(0) int voteCount,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'release_date') String? releaseDate,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'original_language') String? originalLanguage,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'original_title') String? originalTitle,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'media_type', readValue: _readMediaType)
    @Default('movie')
    String mediaType,
    @Default(<int>[]) @JsonKey(name: 'genre_ids') List<int> genreIds,
    @Default(false) bool adult,
    @Default(false) bool video,
    @Default(0.0) double popularity,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  static List<Movie> parseListString(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((json) => Movie.fromJson(json)).toList();
  }

  static List<Movie> parseList(List<dynamic> jsonList) {
    return jsonList.map((json) => Movie.fromJson(json)).toList();
  }
}

Object? _readMediaType(Map json, String key) {
  return json['media_type'] ?? json['type'] ?? 'movie';
}
