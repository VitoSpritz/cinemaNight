import 'package:cinenight/firebase_options.dart';
import 'package:cinenight/model/movie.dart';
import 'package:cinenight/model/review.dart';
import 'package:cinenight/model/user_profile.dart';
import 'package:cinenight/providers/tmdb_api.dart';
import 'package:cinenight/repositories/review_repository.dart';
import 'package:cinenight/repositories/user_profile_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late UserProfileRepository userProfileRepository;
  late ReviewRepository reviewRepository;
  const Uuid idGen = Uuid();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    userProfileRepository = UserProfileRepository();
    reviewRepository = ReviewRepository();
  });

  group('Integration tests with realtime db for Reviews', () {
    testWidgets('Should create a review for a user', (
      WidgetTester tester,
    ) async {
      final String userId = 'test_${idGen.v4()}';

      final UserProfile newUser = UserProfile(
        age: 24,
        firstLastName: 'Andrea Rossi',
        userId: userId,
      );

      await userProfileRepository.createUser(newUser);

      final String reviewId = 'test_${idGen.v4()}';

      final Review newReveiw = Review(
        userId: userId,
        reviewId: reviewId,
        type: ReviewItemType.movie,
        filmId: "1234",
        description: "Description for test review",
        rating: 4,
        filmName: "Mock film name",
        lowercaseName: "mock film name",
      );

      await reviewRepository.createReview(newReveiw);

      final Review? fetchedReview = await reviewRepository.getReviewById(
        reviewId,
      );

      expect(fetchedReview, isNotNull);
      expect(fetchedReview?.reviewId, reviewId);

      await userProfileRepository.deleteUserProfile(userId);
      await reviewRepository.deleteReview(reviewId);
    });
    testWidgets('Should list reviews for a user and then cancell them all', (
      WidgetTester tester,
    ) async {
      final String userId = 'test_${idGen.v4()}';

      final UserProfile newUser = UserProfile(
        age: 24,
        firstLastName: 'Andrea Rossi',
        userId: userId,
      );

      await userProfileRepository.createUser(newUser);

      final String reviewId = 'test_${idGen.v4()}';

      final Review newReveiw = Review(
        userId: userId,
        reviewId: reviewId,
        filmId: "1234",
        type: ReviewItemType.movie,
        description: "Description for test review",
        rating: 4,
        filmName: "Mock film name",
        lowercaseName: "mock film name",
      );

      await reviewRepository.createReview(newReveiw);

      final String review2Id = 'test_${idGen.v4()}';

      final Review newReveiw2 = Review(
        userId: userId,
        reviewId: review2Id,
        filmId: "234",
        type: ReviewItemType.movie,
        description: "Description for test review 2",
        rating: 7,
        filmName: "Mock film name",
        lowercaseName: "mock film name",
      );

      await reviewRepository.createReview(newReveiw2);

      final List<Review> listedReviews = await reviewRepository.listReviews(
        userId,
      );

      expect(listedReviews.length, 2);

      await userProfileRepository.deleteUserProfile(userId);
      await reviewRepository.deleteReview(reviewId);
      await reviewRepository.deleteReview(review2Id);
    });
  });

  testWidgets(
    'Should be able to fetch a film and its poster given a db review',
    (WidgetTester tester) async {
      final String userId = 'test_${idGen.v4()}';
      final TmdbApi tmdb = TmdbApi();

      final UserProfile newUser = UserProfile(
        age: 24,
        firstLastName: 'Andrea Rossi',
        userId: userId,
      );

      await userProfileRepository.createUser(newUser);

      final String reviewId = 'test_${idGen.v4()}';

      final Review newReveiw = Review(
        userId: userId,
        reviewId: reviewId,
        filmId: "11631",
        type: ReviewItemType.movie,
        description: "Description for test review",
        rating: 4,
        filmName: "Mock film name",
        lowercaseName: "mock film name",
      );

      await reviewRepository.createReview(newReveiw);

      final Review? createdReview = await reviewRepository.getReviewById(
        reviewId,
      );

      final Movie film = await tmdb.getMovieById(
        id: createdReview!.filmId,
        language: "it-ITA",
      );

      expect(film, isNotNull);

      await userProfileRepository.deleteUserProfile(userId);
      await reviewRepository.deleteReview(reviewId);
    },
  );
}
