import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../env/env.dart';
import '../interface/tmdb_storage.dart';
import '../model/http_status.dart';
import '../model/media_with_poster.dart';
import '../model/movie.dart';
import '../model/multi.dart';
import '../model/tv_show.dart';

class TmdbApi implements TmdbStorage {
  @override
  Future<List<Movie>> getMovieByName({
    required String name,
    required String language,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'query': name,
      'include_adult': 'true',
      'language': language,
      'api_key': Env.apiKey,
    };

    final Uri url = Uri.parse(
      '${Env.baseUrl}/3/search/movie',
    ).replace(queryParameters: queryParams);

    final http.Response response = await http.get(url);

    if (response.statusCode != HttpStatus.ok.code) {
      throw Exception('Failed to load movies ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (!data.containsKey('results')) {
      throw Exception('No results fetched');
    }

    final List<dynamic> results = data['results'];
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  @override
  Future<List<TvShow>> getTvShowByName({required String name}) async {
    final Map<String, String> queryParams = <String, String>{
      'query': name,
      'include_adult': 'true',
      'api_key': Env.apiKey,
    };

    final Uri url = Uri.parse(
      '${Env.baseUrl}/3/search/tv',
    ).replace(queryParameters: queryParams);

    final http.Response response = await http.get(url);

    if (response.statusCode != HttpStatus.ok.code) {
      throw Exception('Failed to load tv shows ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (!data.containsKey('results')) {
      throw Exception('No results fetched');
    }

    final List<dynamic> results = data['results'];
    return results.map((json) => TvShow.fromJson(json)).toList();
  }

  @override
  Future<List<Multi>> getMultiMediaByName({
    required String name,
    required String language,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'query': name,
      'include_adult': 'true',
      'language': language,
      'api_key': Env.apiKey,
    };

    final Uri url = Uri.parse(
      '${Env.baseUrl}/3/search/multi',
    ).replace(queryParameters: queryParams);

    final http.Response response = await http.get(url);

    if (response.statusCode != HttpStatus.ok.code) {
      throw Exception('Failed to load tv show ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (!data.containsKey('results')) {
      throw Exception('No results fetched');
    }
    final List<dynamic> results = data['results'];

    return results.map((json) => Multi.fromJson(json)).toList();
  }

  @override
  Future<Uint8List> getMediaPoster({required String posterPath}) async {
    final Uri url = Uri.parse('https://image.tmdb.org/t/p/w500$posterPath');

    final http.Response response = await http.get(
      url,
      headers: <String, String>{'Authorization': 'Bearer ${Env.token}'},
    );

    if (response.statusCode != HttpStatus.ok.code) {
      throw Exception('Failed to load poster ${response.statusCode}');
    }

    return response.bodyBytes;
  }

  @override
  Future<List<MediaWithPoster>> getMultiMediaWithPosters({
    required String name,
    required String language,
  }) async {
    final List<Multi> mediaList = await getMultiMediaByName(
      name: name,
      language: language,
    );

    final List<MediaWithPoster> result = <MediaWithPoster>[];

    for (final Multi media in mediaList) {
      Uint8List? posterBytes;

      if (media.posterPath != null && media.posterPath!.isNotEmpty) {
        try {
          posterBytes = await getMediaPoster(posterPath: media.posterPath!);
        } catch (e) {
          // ignore: avoid_print
          print('Failed to load poster for ${media.title}: $e');
          posterBytes = null;
        }
      }

      result.add(MediaWithPoster(media: media, posterBytes: posterBytes));
    }

    return result;
  }
}
