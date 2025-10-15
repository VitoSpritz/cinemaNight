import 'dart:typed_data';

import '../model/media_with_poster.dart';
import '../model/movie.dart';
import '../model/multi.dart';
import '../model/tv_show.dart';

abstract class TmdbStorage {
  Future<List<Movie>> getMovieByName({
    required String name,
    required String language,
  });
  Future<List<TvShow>> getTvShowByName({required String name});
  Future<List<Multi>> getMultiMediaByName({
    required String name,
    required String language,
  });
  Future<Uint8List> getMediaPoster({required String posterPath});
  Future<List<MediaWithPoster>> getMultiMediaWithPosters({
    required String name,
    required String language,
  });
}
