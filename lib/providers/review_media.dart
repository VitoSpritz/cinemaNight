import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/media.dart';
import '../model/media_with_poster.dart';
import '../model/movie.dart';
import '../model/review.dart';
import '../model/tv_show.dart';
import '../services/review_service.dart';
import 'tmdb_api.dart';

part 'review_media.g.dart';

@riverpod
Future<MediaWithPoster> reviewMedia(
  Ref ref,
  String reviewId,
  String language,
) async {
  final ReviewService service = ReviewService();
  final TmdbApi api = TmdbApi();
  final Review review = await service.getReviewById(reviewId);

  final Media media = switch (review.type) {
    ReviewItemType.movie => Media.movie(
      await api.getMovieById(id: review.filmId, language: language),
    ),
    ReviewItemType.tvSeries => Media.tvSeries(
      await api.getTvSeriesById(id: review.filmId, language: language),
    ),
  };

  final Uint8List poster = await api.getMediaPoster(
    posterPath: media.when(
      movie: (Movie movie) => movie.posterPath,
      tvSeries: (TvShow tvSeries) => tvSeries.posterPath,
    )!,
  );

  return MediaWithPoster(media: media, poster: poster);
}
