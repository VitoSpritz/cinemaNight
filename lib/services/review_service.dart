import 'package:uuid/uuid.dart';

import '../model/review.dart';
import '../repositories/review_repository.dart';

class ReviewService {
  final ReviewRepository _reviewRepository = ReviewRepository();

  Future<Review> createReview({
    required String userId,
    required String filmId,
    double? rating,
    String? description,
  }) async {
    final String reviewId = const Uuid().v4();

    final Review newReview = Review(
      reviewId: reviewId,
      filmId: filmId,
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

  Future<List<Review>> listReviews(String userId) async {
    return _reviewRepository.listReviews(userId);
  }

  Future<void> deleteReveiwById(String reviewId) async {
    await _reviewRepository.deleteReview(reviewId);
  }
}
