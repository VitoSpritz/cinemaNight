import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../env/env.dart';
import '../interface/tmdb_storage.dart';
import '../model/http_status.dart';
import '../model/media.dart';
import '../model/movie.dart';
import '../model/multi_with_poster.dart';
import '../model/tv_show.dart';

class TmdbApi implements TmdbStorage {
  @override
  Future<List<Movie>> getMovieByName({
    required String name,
    required String language,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'query': name,
      'include_adult': 'false',
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
  Future<Movie> getMovieById({
    required String id,
    required String language,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'language': language,
      'api_key': Env.apiKey,
    };

    final Uri url = Uri.parse(
      '${Env.baseUrl}/3/movie/$id',
    ).replace(queryParameters: queryParams);

    final http.Response response = await http.get(
      url,
      headers: <String, String>{'accept': 'application/json'},
    );

    if (response.statusCode != HttpStatus.ok.code) {
      throw Exception('Failed to load movie: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return Movie.fromJson(data);
  }

  @override
  Future<List<TvShow>> getTvShowByName({required String name}) async {
    final Map<String, String> queryParams = <String, String>{
      'query': name,
      'include_adult': 'false',
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
  Future<TvShow> getTvSeriesById({
    required String id,
    required String language,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'language': language,
      'api_key': Env.apiKey,
    };

    final Uri url = Uri.parse(
      '${Env.baseUrl}/3/tv/$id',
    ).replace(queryParameters: queryParams);

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer ${Env.apiKey}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode != HttpStatus.ok.code) {
      throw Exception('Failed to load TV series (${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return TvShow.fromJson(data);
  }

  @override
  Future<List<Media>> getMultiMediaByName({
    required String name,
    required String language,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'query': name,
      'include_adult': 'false',
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

    return results.map((json) => Media.fromJson(json)).toList();
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
  Future<List<MultiWithPoster>> getMultiMediaWithPosters({
    required String name,
    required String language,
  }) async {
    final List<Media> mediaList = await getMultiMediaByName(
      name: name,
      language: language,
    );

    final List<MultiWithPoster> result = <MultiWithPoster>[];

    for (final Media media in mediaList) {
      Uint8List? posterBytes;

      final String? poster = media.when(
        movie: (Movie movie) => movie.posterPath,
        tvSeries: (TvShow tvSeries) => tvSeries.posterPath,
      );

      if (poster != null && poster.isNotEmpty) {
        try {
          posterBytes = await getMediaPoster(posterPath: poster);
        } catch (e) {
          posterBytes = null;
        }
      }

      result.add(MultiWithPoster(media: media, posterBytes: posterBytes));
    }

    return result;
  }
}
