import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';
part 'movie.g.dart';

@freezed
abstract class Movie with _$Movie {
  const factory Movie({
    required int id,
    required String title,
    required String overview,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'poster_path') String? posterPath,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'vote_average') required double voteAverage,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'vote_count') required int voteCount,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'release_date') String? releaseDate,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'original_language') String? originalLanguage,
    // ignore: invalid_annotation_target
    @Default(<int>[]) @JsonKey(name: 'genre_ids') List<int> genreIds,
    required bool adult,
    required bool video,
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
