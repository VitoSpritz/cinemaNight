import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie_model.freezed.dart';
part 'movie_model.g.dart';

@freezed
class Movie with _$Movie {
  const factory Movie({
    required int id,
    required String title,
    String? overview,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'vote_average') required double voteAverage,
    @JsonKey(name: 'vote_count') required int voteCount,
    @JsonKey(name: 'release_date') String? releaseDate,
    @JsonKey(name: 'original_language') String? originalLanguage,
    @Default(<dynamic>[]) @JsonKey(name: 'genre_ids') List<int> genreIds,
    required bool adult,
    required bool video,
    @Default(0.0) double popularity,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  @override
  // TODO: implement adult
  bool get adult => throw UnimplementedError();

  @override
  // TODO: implement backdropPath
  String? get backdropPath => throw UnimplementedError();

  @override
  // TODO: implement genreIds
  List<int> get genreIds => throw UnimplementedError();

  @override
  // TODO: implement id
  int get id => throw UnimplementedError();

  @override
  // TODO: implement originalLanguage
  String? get originalLanguage => throw UnimplementedError();

  @override
  // TODO: implement overview
  String? get overview => throw UnimplementedError();

  @override
  // TODO: implement popularity
  double get popularity => throw UnimplementedError();

  @override
  // TODO: implement posterPath
  String? get posterPath => throw UnimplementedError();

  @override
  // TODO: implement releaseDate
  String? get releaseDate => throw UnimplementedError();

  @override
  // TODO: implement title
  String get title => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement video
  bool get video => throw UnimplementedError();

  @override
  // TODO: implement voteAverage
  double get voteAverage => throw UnimplementedError();

  @override
  // TODO: implement voteCount
  int get voteCount => throw UnimplementedError();
}
