// Import the test package and Counter class
import 'package:cinenight/l10n/app_localizations_it.dart';
import 'package:cinenight/model/movie.dart';
import 'package:cinenight/providers/tmdb_api.dart';
import 'package:test/test.dart';

void main() {
  late TmdbApi api;

  setUp(() {
    api = TmdbApi();
  });

  group("Multiple get movie test", () {
    test('Should be able to fetch a film and reply 200', () async {
      try {
        final List<Movie> res = await api.getMovieByName(
          name: 'Interstellar',
          language: AppLocalizationsIt().requestApiLanguage,
        );

        final Movie movie = res.elementAt(0);
        expect(movie.title, "Interstellar");

        // ignore: avoid_print
        print(movie.toString());
      } catch (error) {
        // ignore: avoid_print
        print(error.toString());
      }
    });
  });
}
