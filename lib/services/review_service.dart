import 'package:uuid/uuid.dart';

import '../model/review.dart';
import '../repositories/review_repository.dart';

class ReviewService {
  final ReviewRepository _reviewRepository = ReviewRepository();

  Future<Review> createReview({
    required String userId,
    required String filmId,
    required ReviewItemType type,
    required String filmName,
    double? rating,
    String? description,
  }) async {
    final String reviewId = const Uuid().v4();

    final Review newReview = Review(
      reviewId: reviewId,
      filmId: filmId,
      type: type,
      filmName: filmName,
      userId: userId,
      description: description,
      rating: rating,
    );

    await _reviewRepository.createReview(newReview);

    return await getReviewById(reviewId);
  }

  Future<Review> getReviewById(String reviewId) async {
    final Review? review = await _reviewRepository.getReviewById(reviewId);

    return review!;
  }

  Future<Review> getReviewByName(String name) async {
    final Review? review = await _reviewRepository.getReviewByName(name);

    return review!;
  }

  Future<List<Review>> listReviews(String userId) async {
    return _reviewRepository.listReviews(userId);
  }

  Future<Review> updateReview({
    required String reviewId,
    required String userId,
    required String filmId,
    required ReviewItemType type,
    required String filmName,
    double? rating,
    String? description,
  }) async {
    final Review updateReview = Review(
      reviewId: reviewId,
      filmId: filmId,
      userId: userId,
      type: type,
      filmName: filmName,
      description: description,
      rating: rating,
    );

    await _reviewRepository.updateReview(reviewId, updateReview);

    return await getReviewById(reviewId);
  }

  Future<void> deleteReveiwById(String reviewId) async {
    await _reviewRepository.deleteReview(reviewId);
  }
}
