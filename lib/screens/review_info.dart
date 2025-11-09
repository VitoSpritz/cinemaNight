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
import '../widget/custom_rating.dart';
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
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  String _existingReview = '';
  String _existingRating = '0.0';
  bool _isInitialized = false;

  @override
  void dispose() {
    _reviewController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _initializeControllers(Review review) {
    if (_isInitialized) return; // ✅ Only initialize once

    _reviewController.text = review.description ?? "";
    _ratingController.text = review.rating?.toString() ?? "0.0";
    _existingRating = review.rating?.toString() ?? "0.0";
    _existingReview = review.description ?? "";

    _isInitialized = true;
  }

  bool _checkValuesOnExit({required String rating, required String review}) {
    if (_existingRating != rating || _existingReview != review) {
      return true;
    }
    return false;
  }

  void _updateReview({
    required String newReview,
    required String userId,
    required int filmId,
    required String type,
    required double rating,
  }) async {
    await _reviewService.updateReview(
      reviewId: widget.reviewId,
      userId: userId,
      filmId: filmId.toString(),
      type: type == ReviewItemType.movie.name
          ? ReviewItemType.movie
          : ReviewItemType.tvSeries,
      description: newReview,
      rating: rating,
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
    final AsyncValue<Review> reviewAsync = ref.watch(
      (getReviewByIdProvider(widget.reviewId)),
    );
    final AsyncValue<UserProfile> userAuthAsync = ref.watch(
      userProfilesProvider,
    );

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.reviewInfoPageTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () async {
                      final bool result = _checkValuesOnExit(
                        rating: _ratingController.text,
                        review: _reviewController.text,
                      );
                      if (result) {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(
                                  context,
                                )!.exitWithoutSavingDialong,
                              ),
                              content: Text(
                                AppLocalizations.of(context)!.sureYouWantToQuit,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(AppLocalizations.of(context)!.no),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    AppLocalizations.of(context)!.yes,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        context.pop();
                      }
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: reviewAsync.when(
              data: (Review review) {
                return mediaAsync.when(
                  data: (MediaWithPoster mediaWithPoster) {
                    return userAuthAsync.when(
                      data: (UserProfile userAuth) {
                        // Initialize controllers only once
                        _initializeControllers(review);

                        final Media media = mediaWithPoster.media;

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          media.when(
                                            movie: (Movie movie) => movie.title,
                                            tvSeries: (TvShow tvShow) =>
                                                tvShow.name,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          media.when(
                                            movie: (Movie movie) =>
                                                AppLocalizations.of(
                                                  context,
                                                )!.releasedLabel(
                                                  movie.releaseDate ?? "N/A",
                                                ),
                                            tvSeries: (TvShow tvShow) =>
                                                AppLocalizations.of(
                                                  context,
                                                )!.firstAiredLabel(
                                                  tvShow.firstAirDate ?? "N/A",
                                                ),
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 8),
                                        CustomRating(
                                          initialRating: review.rating ?? 0.0,
                                          onRatingChanged: (double rating) {
                                            _ratingController.text = rating
                                                .toString();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ExpandableText(
                                  text: media.when(
                                    movie: (Movie movie) => movie.overview,
                                    tvSeries: (TvShow tvShow) =>
                                        tvShow.overview,
                                  ),
                                  maxLines: 3,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: TextField(
                                  controller: _reviewController,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.insertAReview,
                                    border: const OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () => _updateReview(
                                      newReview: _reviewController.text,
                                      userId: userAuth.userId,
                                      filmId: media.when(
                                        movie: (Movie movie) => movie.id,
                                        tvSeries: (TvShow tvSeries) =>
                                            tvSeries.id,
                                      ),
                                      type: media.when(
                                        movie: (Movie movie) => movie.mediaType,
                                        tvSeries: (TvShow tvSeries) =>
                                            tvSeries.mediaType,
                                      ),
                                      rating:
                                          double.tryParse(
                                            _ratingController.text,
                                          ) ??
                                          0.0,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.updateButton,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final bool? deleteReview =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.deleteReviewDialog,
                                                ),
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.deleteReviewButton,
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.no,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.yes,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                      if (deleteReview == true) {
                                        await _reviewService.deleteReveiwById(
                                          widget.reviewId,
                                        );
                                        ref.invalidate(userReviewProvider);
                                        if (mounted) {
                                          context.pop();
                                        }
                                      }
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.deleteReviewButton,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (Object error, StackTrace stack) =>
                          Center(child: Text('Error: $error')),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace stack) =>
                      Center(child: Text('Error: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) =>
                  Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
