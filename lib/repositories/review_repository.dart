import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/review.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createReview(Review review) async {
    _firestore.collection('reviews').doc(review.reviewId).set(<String, Object?>{
      'userId': review.userId,
      'reviewId': review.reviewId,
      'filmId': review.filmId,
      'rating': review.rating,
      'description': review.description,
    });
  }

  Future<Review?> getReviewById(String reviewId) async {
    final DocumentSnapshot<Map<String, dynamic>> result = await _firestore
        .collection('reviews')
        .doc(reviewId)
        .get();

    if (!result.exists) {
      return null;
    }
    return Review.fromJson(result.data()!);
  }

  Future<List<Review>> listReviews(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();

    return result.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              Review.fromJson(doc.data()),
        )
        .toList();
  }

  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }
}
