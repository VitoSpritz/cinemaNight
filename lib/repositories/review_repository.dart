import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../model/review.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createReview(Review review) async {
    _firestore.collection('reviews').doc(review.reviewId).set(review.toJson());
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

  Future<Review?> getReviewByName(String name) async {
    final DocumentSnapshot<Map<String, dynamic>> result = await _firestore
        .collection('reviews')
        .doc(name)
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
        .orderBy('rating', descending: true)
        .get();

    List<Review> liked = <Review>[];
    try {
      final QuerySnapshot<Map<String, dynamic>> likedReviews = await _firestore
          .collection('reviews')
          .where('likes', arrayContains: userId)
          .get();

      liked = likedReviews.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                Review.fromJson(doc.data()),
          )
          .toList();
    } catch (e) {
      debugPrint("Error fetching liked reviews: $e");
    }

    final List<Review> userReviews = result.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              Review.fromJson(doc.data()),
        )
        .toList();

    final List<Review> reviews = <Review>[...userReviews, ...liked]
      ..sort((Review a, Review b) => b.rating!.compareTo(a.rating!));

    return reviews;
  }

  Future<void> updateReview(String reviewId, Review review) async {
    await _firestore
        .collection('reviews')
        .doc(reviewId)
        .update(review.toJson());
  }

  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }
}
