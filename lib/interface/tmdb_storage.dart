import 'dart:typed_data';

import '../model/media.dart';
import '../model/movie.dart';
import '../model/multi_with_poster.dart';
import '../model/tv_show.dart';

abstract class TmdbStorage {
  Future<List<Movie>> getMovieByName({
    required String name,
    required String language,
  });
  Future<Movie> getMovieById({required String id, required String language});
  Future<List<TvShow>> getTvShowByName({required String name});
  Future<TvShow> getTvSeriesById({
    required String id,
    required String language,
  });
  Future<List<Media>> getMultiMediaByName({
    required String name,
    required String language,
  });
  Future<Uint8List> getMediaPoster({required String posterPath});
  Future<List<MultiWithPoster>> getMultiMediaWithPosters({
    required String name,
    required String language,
  });
}
