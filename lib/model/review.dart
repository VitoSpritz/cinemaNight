import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@JsonEnum(valueField: 'type')
enum ReviewItemType {
  @JsonValue("tv")
  tvSeries,
  @JsonValue("movie")
  movie,
}

@freezed
abstract class Review with _$Review {
  const factory Review({
    required String reviewId,
    required String filmId,
    required String userId,
    required ReviewItemType type,
    required String filmName,
    required String lowercaseName,
    double? rating,
    String? description,
    List<String>? likes,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  factory Review.create({
    required String reviewId,
    required String filmId,
    required String userId,
    required ReviewItemType type,
    required String filmName,
    required String lowercaseName,
    double? rating,
    String? description,
    List<String>? likes,
  }) {
    if (rating != null && (rating < 0 || rating > 10)) {
      throw ArgumentError('Rating must be between 0 and 10, got $rating');
    }
    return Review(
      reviewId: reviewId,
      userId: userId,
      filmId: filmId,
      rating: rating,
      filmName: filmName,
      lowercaseName: lowercaseName,
      type: type,
      description: description,
      likes: likes,
    );
  }
}
