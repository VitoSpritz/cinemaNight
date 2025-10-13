import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/providers/future_provider.dart';

import '../model/movie_model.dart';
import 'tmdb_api.dart';

final Provider<TmdbApi> tmdbApiServiceProvider = Provider<TmdbApi>((Ref ref) {
  return TmdbApi();
});

final FutureProviderFamily<List<Movie>, String> movieByNameProvider =
    FutureProvider.family<List<Movie>, String>((Ref ref, String query) async {
      final TmdbApi apiService = ref.read(tmdbApiServiceProvider);
      return apiService.getMovieByName(query);
    });
