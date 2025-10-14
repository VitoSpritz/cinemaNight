import '../model/movie.dart';
import '../model/tvShow.dart';

abstract class TmdbStorage {
  Future<List<Movie>> getMovieByName({
    required String name,
    required String language,
  });
  Future<List<TvShow>> getTvShowByName({required String name});
}
