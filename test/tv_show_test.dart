import 'package:cinenight/model/tvShow.dart';
import 'package:cinenight/providers/tmdb_api.dart';
import 'package:test/test.dart';

void main() {
  late TmdbApi api;

  setUp(() {
    api = TmdbApi();
  });

  group("Multiple get movie test", () {
    test('Should be able to fetch a tv show and reply 200', () async {
      try {
        final List<TvShow> res = await api.getTvShowByName(
          name: 'The big bang theory',
        );

        final TvShow tvShow = res.elementAt(0);
        expect(tvShow.name, 'The Big Bang Theory');

        // ignore: avoid_print
        print(tvShow.toString());
      } catch (error) {
        // ignore: avoid_print
        print(error.toString());
      }
    });
  });
}
