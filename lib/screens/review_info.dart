import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../helpers/media_converter.dart';
import '../l10n/app_localizations.dart';
import '../model/media.dart';
import '../model/media_with_poster.dart';
import '../model/review.dart';
import '../model/user_profile.dart';
import '../providers/review_media.dart';
import '../providers/user_profiles.dart';
import '../providers/user_review.dart';
import '../services/review_service.dart';
import '../widget/custom_dialog.dart';
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
  bool _isUpdating = false;

  @override
  void dispose() {
    _reviewController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _initializeControllers(Review review) {
    if (_isInitialized) {
      return;
    }

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
    required String filmName,
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
      filmName: filmName,
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
      body: _isUpdating
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () async {
                          final bool result = _checkValuesOnExit(
                            rating: _ratingController.text,
                            review: _reviewController.text,
                          );
                          if (result) {
                            await CustomDialog.show(
                              context: context,
                              title: AppLocalizations.of(
                                context,
                              )!.exitWithoutSavingDialong,
                              subtitle: AppLocalizations.of(
                                context,
                              )!.sureYouWantToQuit,
                              function: () async => Navigator.of(context).pop(),
                            );
                          } else {
                            context.pop();
                          }
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          fill: 0,
                          color: CustomColors.black,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            AppLocalizations.of(context)!.reviewInfoPageTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                              _initializeControllers(review);
                              final Media media = mediaWithPoster.media;
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                MediaConverter.getValue(
                                                  media: media,
                                                  field: MediaField.title,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.releasedLabel(
                                                  MediaConverter.getValue(
                                                    media: media,
                                                    field:
                                                        MediaField.releaseDate,
                                                  ),
                                                ),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                              const SizedBox(height: 8),
                                              CustomRating(
                                                initialRating:
                                                    review.rating ?? 0.0,
                                                onRatingChanged:
                                                    (double rating) {
                                                      _ratingController.text =
                                                          rating.toString();
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
                                        color: CustomColors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ExpandableText(
                                        text: MediaConverter.getValue(
                                          media: media,
                                          field: MediaField.overview,
                                        ),
                                        maxLines: 2,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
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
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: FilledButton(
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  CustomColors.white,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(18),
                                                        ),
                                                    side: BorderSide(
                                                      color: CustomColors.black,
                                                      width: 1,
                                                    ),
                                                  ),
                                            ),
                                            onPressed: () async {
                                              final bool?
                                              isUpdated = await CustomDialog.show(
                                                context: context,
                                                title: AppLocalizations.of(
                                                  context,
                                                )!.attentionLabel,
                                                subtitle:
                                                    "Sei sicuro di voler aggiornare la recensione?",
                                              );
                                              if (isUpdated == true) {
                                                setState(() {
                                                  _isUpdating = true;
                                                });
                                                _updateReview(
                                                  newReview:
                                                      _reviewController.text,
                                                  userId: userAuth.userId,
                                                  filmId:
                                                      MediaConverter.getValue(
                                                        media: media,
                                                        field: MediaField.id,
                                                      ),
                                                  type: MediaConverter.getValue(
                                                    media: media,
                                                    field: MediaField.mediaType,
                                                  ),
                                                  rating: double.parse(
                                                    _ratingController.text,
                                                  ),
                                                  filmName:
                                                      MediaConverter.getValue(
                                                        media: media,
                                                        field: MediaField.title,
                                                      ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              style: const TextStyle(
                                                color: CustomColors.black,
                                              ),
                                              AppLocalizations.of(
                                                context,
                                              )!.updateButton,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: FilledButton(
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  CustomColors.white,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(18),
                                                        ),
                                                    side: BorderSide(
                                                      color: CustomColors.black,
                                                      width: 1,
                                                    ),
                                                  ),
                                            ),
                                            onPressed: () async {
                                              final bool? deleteReview =
                                                  await CustomDialog.show(
                                                    title: AppLocalizations.of(
                                                      context,
                                                    )!.attentionLabel,
                                                    subtitle:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.deleteReviewDialog,
                                                    context: context,
                                                  );
                                              if (deleteReview == true) {
                                                await _reviewService
                                                    .deleteReveiwById(
                                                      widget.reviewId,
                                                    );
                                                ref.invalidate(
                                                  userReviewProvider,
                                                );
                                                if (mounted) {
                                                  context.pop();
                                                }
                                              }
                                            },
                                            child: Text(
                                              style: const TextStyle(
                                                color: CustomColors.black,
                                              ),
                                              AppLocalizations.of(
                                                context,
                                              )!.deleteReviewButton,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
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
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (Object error, StackTrace stack) =>
                        Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
    );
  }
}
