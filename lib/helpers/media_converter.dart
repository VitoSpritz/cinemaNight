import '../model/media.dart';
import '../model/movie.dart';
import '../model/tv_show.dart';

class MediaConverter {
  static getValue({required Media media, required MediaField field}) {
    switch (field) {
      case MediaField.id:
        return media.when(
          movie: (Movie movie) => movie.id,
          tvSeries: (TvShow tvSeries) => tvSeries.id,
        );
      case MediaField.poster:
        return media.when(
          movie: (Movie movie) => movie.posterPath,
          tvSeries: (TvShow tvSeries) => tvSeries.posterPath,
        );
      case MediaField.releaseDate:
        return media.when(
          movie: (Movie movie) => movie.releaseDate,
          tvSeries: (TvShow tvSeries) => tvSeries.firstAirDate,
        );
      case MediaField.title:
        return media.when(
          movie: (Movie movie) => movie.title,
          tvSeries: (TvShow tvSeries) => tvSeries.name,
        );
      case MediaField.overview:
        return media.when(
          movie: (Movie movie) => movie.overview,
          tvSeries: (TvShow tvSeries) => tvSeries.overview,
        );
      case MediaField.mediaType:
        return media.when(
          movie: (Movie movie) => movie.mediaType,
          tvSeries: (TvShow tvSeries) => tvSeries.mediaType,
        );
      case MediaField.rating:
        return media.when(
          movie: (Movie movie) => movie.voteAverage,
          tvSeries: (TvShow tvSeries) => tvSeries.voteAverage,
        );
    }
  }
}
