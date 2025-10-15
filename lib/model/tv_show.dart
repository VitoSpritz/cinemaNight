import 'package:freezed_annotation/freezed_annotation.dart';

part 'tv_show.freezed.dart';
part 'tv_show.g.dart';

@freezed
abstract class TvShow with _$TvShow {
  const factory TvShow({
    required int id,
    // ignore: invalid_annotation_target
    @JsonKey(name: "original_name") required String originalName,
    required String name,
    required String overview,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'poster_path') String? posterPath,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'first_air_date') String? firstAirDate,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'vote_count') required int voteCount,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'original_language') String? originalLanguage,
    @Default(<String>[])
    // ignore: invalid_annotation_target
    @JsonKey(name: 'origin_country')
    List<String> originCountry,
    // ignore: invalid_annotation_target
    @Default(<int>[]) @JsonKey(name: 'genre_ids') List<int> genreIds,
    required bool adult,
    @Default(0.0) double popularity,
  }) = _TvShow;

  factory TvShow.fromJson(Map<String, dynamic> json) => _$TvShowFromJson(json);

  static List<TvShow> parseList(List<dynamic> jsonList) {
    return jsonList.map((json) => TvShow.fromJson(json)).toList();
  }
}
