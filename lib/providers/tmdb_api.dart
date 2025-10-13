import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/movie_model.dart';

class TmdbApi {
  static const String baseUrl = 'https://api.themoviedb.org/3/search';

  Future<List<Movie>> getMovieByName(String name) async {
    const String languageParam = "it-ITA";

    final Uri url = Uri.parse(
      '$baseUrl/search/movie?query=$name&include_adult=true&language=$languageParam&page=1',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];

      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
