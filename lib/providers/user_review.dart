import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/review.dart';
import '../services/review_service.dart';
import 'auth.dart';

part 'user_review.g.dart';

@riverpod
class UserReview extends _$UserReview {
  final ReviewService service = ReviewService();

  @override
  Future<List<Review>> build() async {
    final User? user = ref.watch(authProvider);
    return await service.listReviews(user!.uid);
  }

  Future<void> createReview({
    required String userId,
    required String filmId,
    required ReviewItemType type,
    required String filmName,
    required String lowercaseName,
    String? description,
    double? rating,
  }) async {
    await service.createReview(
      userId: userId,
      filmId: filmId,
      type: type,
      filmName: filmName,
      lowercaseName: lowercaseName,
      description: description,
      rating: rating,
    );

    ref.invalidateSelf();
  }

  Future<void> updateReview({
    required String reviewId,
    required String userId,
    required String filmId,
    required ReviewItemType type,
    required String filmName,
    required String lowercaseName,
    double? rating,
    String? description,
    List<String>? likes,
  }) async {
    await service.updateReview(
      reviewId: reviewId,
      userId: userId,
      filmName: filmName,
      type: type,
      filmId: filmId,
      lowercaseName: lowercaseName,
      description: description,
      rating: rating,
      likes: likes,
    );

    ref.invalidateSelf();
  }

  Future<void> deleteReview(String reviewId) async {
    await service.deleteReveiwById(reviewId);
  }
}

@riverpod
Future<Review> getReviewById(Ref ref, String reviewId) async {
  final UserReview userReviewNotifier = ref.read(userReviewProvider.notifier);
  return await userReviewNotifier.service.getReviewById(reviewId);
}

@riverpod
Future<Review> getReviewByName(Ref ref, String name) async {
  final UserReview userReviewNotifier = ref.read(userReviewProvider.notifier);
  return await userReviewNotifier.service.getReviewByName(name);
}
