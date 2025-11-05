import 'package:freezed_annotation/freezed_annotation.dart';

import 'movie.dart';
import 'tv_show.dart';

part 'media.freezed.dart';

@freezed
abstract class Media with _$Media {
  const Media._();

  const factory Media.movie(Movie movie) = MovieMedia;
  const factory Media.tvSeries(TvShow tvShow) = TvSeriesMedia;

  factory Media.fromJson(Map<String, dynamic> json) {
    final String? mediaType = json['media_type'] as String?;

    if (mediaType == 'movie') {
      return Media.movie(Movie.fromJson(json));
    } else if (mediaType == 'tv') {
      return Media.tvSeries(TvShow.fromJson(json));
    }

    throw ArgumentError('Unknown or missing media_type: $mediaType');
  }

  Map<String, dynamic> toJson() => when(
    movie: (Movie movie) => movie.toJson(),
    tvSeries: (TvShow tvShow) => tvShow.toJson(),
  );
}
