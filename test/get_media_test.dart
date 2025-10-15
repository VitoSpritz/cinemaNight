import 'dart:typed_data';

import 'package:cinenight/l10n/app_localizations_it.dart';
import 'package:cinenight/model/media_with_poster.dart';
import 'package:cinenight/model/movie.dart';
import 'package:cinenight/model/multi.dart';
import 'package:cinenight/model/tv_show.dart';
import 'package:cinenight/providers/tmdb_api.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  late TmdbApi api;

  setUp(() {
    api = TmdbApi();
  });

  group('Get media from API tests', () {
    test('Should be able to fetch a tv show and reply 200', () async {
      final List<TvShow> res = await api.getTvShowByName(
        name: 'The big bang theory',
      );

      final TvShow tvShow = res.elementAt(0);
      expect(tvShow.name, 'The Big Bang Theory');

      debugPrint(tvShow.toString());
    });
  });

  test('Should be able to fetch a film and reply 200', () async {
    final List<Movie> res = await api.getMovieByName(
      name: 'Interstellar',
      language: AppLocalizationsIt().requestApiLanguage,
    );

    final Movie movie = res.elementAt(0);
    expect(movie.title, 'Interstellar');
    expect(movie.originalLanguage, "en");

    debugPrint(movie.toString());
  });

  test('Should be able to fetch a media given its name', () async {
    final List<Multi> res = await api.getMultiMediaByName(
      name: 'Django Unchained',
      language: AppLocalizationsIt().requestApiLanguage,
    );

    final Multi media = res.elementAt(0);
    expect(media.title, 'Django Unchained');

    debugPrint(media.toString());
  });

  test('Should be able to fetch a poster', () async {
    final Uint8List res = await api.getMediaPoster(
      posterPath: '/3Q41QdROiYoEMY0qXhfRMT5DbPd.jpg',
    );

    expect(res, isA<Uint8List>());
    debugPrint('Poster fetched successfulyl');
  });

  test('Should be able to fetch a media with its poster', () async {
    final List<MediaWithPoster> res = await api.getMultiMediaWithPosters(
      name: 'Django Unchained',
      language: AppLocalizationsIt().requestApiLanguage,
    );

    final MediaWithPoster media = res.elementAt(0);
    expect(media.media.title, 'Django Unchained');
    expect(media.posterBytes, isA<Uint8List>());
    debugPrint('Poster fetched successfulyl');
  });
}
