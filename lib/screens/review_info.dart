import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../model/media.dart';
import '../model/media_with_poster.dart';
import '../model/movie.dart';
import '../model/review.dart';
import '../model/tv_show.dart';
import '../model/user_profile.dart';
import '../providers/review_media.dart';
import '../providers/user_profiles.dart';
import '../providers/user_review.dart';
import '../services/review_service.dart';
import '../widget/expandable_text.dart';

class ReviewInfo extends ConsumerStatefulWidget {
  static const String path = '/review/:reviewId/info';
  final String reviewId;

  const ReviewInfo({super.key, required this.reviewId});

  @override
  ConsumerState<ReviewInfo> createState() => _ReviewInfoState();
}

class _ReviewInfoState extends ConsumerState<ReviewInfo> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _textInputControl = TextEditingController();

  @override
  void dispose() {
    _textInputControl.dispose();
    super.dispose();
  }

  void _updateReview({
    required String newReview,
    required String userId,
    required int filmId,
    required String type,
  }) async {
    await _reviewService.updateReview(
      reviewId: widget.reviewId,
      userId: userId,
      filmId: filmId.toString(),
      type: type == ReviewItemType.movie.name
          ? ReviewItemType.movie
          : ReviewItemType.tvSeries,
      description: newReview,
    );

    ref.invalidate(userReviewProvider);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String language = AppLocalizations.of(context)!.requestApiLanguage;
    final AsyncValue<MediaWithPoster> mediaAsync = ref.watch(
      reviewMediaProvider(widget.reviewId, language),
    );
    final AsyncValue<Review> review = ref.watch(
      (getReviewByIdProvider(widget.reviewId)),
    );
    final AsyncValue<UserProfile> userAuth = ref.read(userProfilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Details')),
      body: mediaAsync.when(
        data: (MediaWithPoster mediaWithPoster) {
          final Media media = mediaWithPoster.media;
          _textInputControl.text = review.value!.description ?? "";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(
                        mediaWithPoster.poster!,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            media.when(
                              movie: (Movie movie) => movie.title,
                              tvSeries: (TvShow tvShow) => tvShow.name,
                            ),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            media.when(
                              movie: (Movie movie) =>
                                  'Released: ${movie.releaseDate ?? "N/A"}',
                              tvSeries: (TvShow tvShow) =>
                                  'First aired: ${tvShow.firstAirDate ?? "N/A"}',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ExpandableText(
                      text: media.when(
                        movie: (Movie movie) => movie.overview ?? "N/A",
                        tvSeries: (TvShow tvShow) => tvShow.overview ?? "N/A",
                      ),
                      maxLines: 3,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _textInputControl,
                      decoration: const InputDecoration(
                        labelText: "Insert a review",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _updateReview(
                      newReview: _textInputControl.text,
                      userId: userAuth.value!.userId,
                      filmId: media.when(
                        movie: (Movie movie) => movie.id,
                        tvSeries: (TvShow tvSeries) => tvSeries.id,
                      ),
                      type: media.when(
                        movie: (Movie movie) => movie.mediaType,
                        tvSeries: (TvShow tvSeries) => tvSeries.mediaType,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.updateButton),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final bool? deleteReview = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "You want to delete this review?",
                            ),
                            content: const Text("Delete it"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(AppLocalizations.of(context)!.no),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(AppLocalizations.of(context)!.yes),
                              ),
                            ],
                          );
                        },
                      );
                      if (deleteReview == true) {
                        _reviewService.deleteReveiwById(widget.reviewId);
                        ref.invalidate(userReviewProvider);
                        context.pop();
                      }
                    },
                    child: const Text("Delete review"),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) =>
            Center(child: Text('Error: $error')),
      ),
    );
  }
}
