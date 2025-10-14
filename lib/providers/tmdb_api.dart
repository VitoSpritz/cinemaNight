import 'dart:convert';

import 'package:http/http.dart' as http;

import '../env/env.dart';
import '../interface/tmdb_storage.dart';
import '../model/http_status.dart';
import '../model/movie.dart';
import '../model/tvShow.dart';

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

    if (response.statusCode == HttpStatus.ok.code) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> results = data['results'] ?? <dynamic>[];

      return Movie.parseList(results);
    } else {
      throw Exception('Failed to load movies ${response.statusCode}');
    }
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

    if (response.statusCode == HttpStatus.ok.code) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> results = data['results'] ?? <dynamic>[];

      return TvShow.parseList(results);
    } else {
      throw Exception('Failed to load tv shows ${response.statusCode}');
    }
  }
}
