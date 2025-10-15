import 'package:freezed_annotation/freezed_annotation.dart';

part 'multi.freezed.dart';
part 'multi.g.dart';

@freezed
abstract class Multi with _$Multi {
  const factory Multi({
    required bool adult,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    required int id,
    String? title,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'original_language') String? originalLanguage,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'original_title') String? originalTitle,
    String? overview, // Changed: Made nullable
    // ignore: invalid_annotation_target
    @JsonKey(name: 'poster_path') String? posterPath,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'media_type') String? mediaType,
    // ignore: invalid_annotation_target
    @Default(<int>[]) @JsonKey(name: 'genre_ids') List<int> genreIds,
    @Default(0.0) double popularity,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'release_date') String? releaseDate,
    bool? video,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'vote_average') double? voteAverage,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'vote_count') int? voteCount,
  }) = _Multi;

  factory Multi.fromJson(Map<String, dynamic> json) => _$MultiFromJson(json);
}
