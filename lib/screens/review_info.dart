import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../consts/sizes.dart';
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
import 'review_list.dart';

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
  bool _isReviewCreator = true;
  bool _hasLikedReview = false;

  @override
  void dispose() {
    _reviewController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _initializeControllers(Review review, String currentUserId) {
    if (_isInitialized) {
      return;
    }

    _reviewController.text = review.description ?? "";
    _ratingController.text = review.rating?.toString() ?? "0.0";
    _existingRating = review.rating?.toString() ?? "0.0";
    _existingReview = review.description ?? "";
    _isReviewCreator = review.userId == currentUserId;
    _hasLikedReview = review.likes?.contains(currentUserId) ?? false;

    _isInitialized = true;
  }

  bool _checkValuesOnExit({required String rating, required String review}) {
    if (_existingRating != rating || _existingReview != review) {
      return true;
    }
    return false;
  }

  Future<void> _updateReview({
    required Review review,
    required String newReview,
    required String userId,
    required int filmId,
    required String type,
    required String filmName,
    required double rating,
    List<String>? likes,
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
      lowercaseName: filmName.toLowerCase(),
      likes: likes ?? review.likes,
    );

    ref.invalidate(userReviewProvider);
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _toggleLike({
    required Review review,
    required String visitorUserId,
  }) async {
    final List<String> updatedLikes = _hasLikedReview
        ? review.likes!.where((String id) => id != visitorUserId).toList()
        : <String>[...?review.likes, visitorUserId];

    setState(() {
      _hasLikedReview = !_hasLikedReview;
    });

    await _reviewService.updateReview(
      reviewId: widget.reviewId,
      userId: review.userId,
      filmId: review.filmId,
      type: review.type == ReviewItemType.movie
          ? ReviewItemType.movie
          : ReviewItemType.tvSeries,
      description: review.description ?? '',
      filmName: review.filmName,
      rating: review.rating ?? 0.0,
      lowercaseName: review.filmName.toLowerCase(),
      likes: updatedLikes,
    );

    ref.invalidate(userReviewProvider);
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

    final bool isLoading =
        reviewAsync.isLoading ||
        mediaAsync.isLoading ||
        userAuthAsync.isLoading;
    final bool hasError =
        reviewAsync.hasError || mediaAsync.hasError || userAuthAsync.hasError;

    if (isLoading || _isUpdating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError) {
      final Object? error =
          reviewAsync.error ?? mediaAsync.error ?? userAuthAsync.error;
      return Scaffold(body: Center(child: Text('Error: $error')));
    }

    final Review review = reviewAsync.value!;
    final MediaWithPoster mediaWithPoster = mediaAsync.value!;
    final UserProfile userAuth = userAuthAsync.value!;
    final Media media = mediaWithPoster.media;

    _initializeControllers(review, userAuth.userId);

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 2,
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
                        function: () async {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(ReviewList.path);
                          }
                        },
                      );
                    } else {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(ReviewList.path);
                      }
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
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.reviewInfoPageTitle,
                      style: CustomTypography.titleM.copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                if (!_isReviewCreator)
                  IconButton(
                    onPressed: () async {
                      await _toggleLike(
                        review: review,
                        visitorUserId: userAuth.userId,
                      );
                    },
                    icon: Icon(
                      _hasLikedReview ? Icons.star : Icons.star_border,
                      color: _hasLikedReview
                          ? CustomColors.mainYellow
                          : CustomColors.black,
                      size: Sizes.iconMedium,
                    ),
                  ),
                IconButton(
                  onPressed: () async {
                    final String link =
                        'cinenight://review/${widget.reviewId}/info';
                    await Clipboard.setData(ClipboardData(text: link));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.reviewInfoCopiedLink,
                            style: CustomTypography.bodySmall.copyWith(
                              color: CustomColors.white,
                            ),
                          ),

                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.share,
                    color: CustomColors.black,
                    size: Sizes.iconMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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
                              MediaConverter.getValue(
                                media: media,
                                field: MediaField.title,
                              ),
                              style: CustomTypography.titleXL.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.releasedLabel(
                                MediaConverter.getValue(
                                  media: media,
                                  field: MediaField.releaseDate,
                                ),
                              ),
                              style: CustomTypography.bodySmall.copyWith(
                                color: CustomColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!_isReviewCreator) ...<Widget>[
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.reviewInfoWritteBy(
                                  userAuth.firstLastName ?? "",
                                ),
                                style: CustomTypography.bodySmall.copyWith(
                                  color: CustomColors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            CustomRating(
                              readOnly: !_isReviewCreator,
                              initialRating: review.rating ?? 0.0,
                              onRatingChanged: (double rating) {
                                _ratingController.text = rating.toString();
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
                      style: CustomTypography.body,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _reviewController,
                      onTapOutside: (PointerDownEvent event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      readOnly: !_isReviewCreator,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.insertAReview,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: !_isReviewCreator ? 5 : 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isReviewCreator)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: CustomColors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(18),
                                ),
                                side: BorderSide(
                                  color: CustomColors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              final bool? isUpdated = await CustomDialog.show(
                                context: context,
                                title: AppLocalizations.of(
                                  context,
                                )!.attentionLabel,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.reviewInfoUpdateReview,
                              );
                              if (isUpdated == true) {
                                setState(() {
                                  _isUpdating = true;
                                });
                                _updateReview(
                                  review: review,
                                  newReview: _reviewController.text,
                                  userId: userAuth.userId,
                                  filmId: MediaConverter.getValue(
                                    media: media,
                                    field: MediaField.id,
                                  ),
                                  type: MediaConverter.getValue(
                                    media: media,
                                    field: MediaField.mediaType,
                                  ),
                                  rating: double.parse(_ratingController.text),
                                  filmName: MediaConverter.getValue(
                                    media: media,
                                    field: MediaField.title,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              style: CustomTypography.bodySmallBold.copyWith(
                                color: CustomColors.black,
                              ),
                              AppLocalizations.of(context)!.updateButton,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: CustomColors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
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
                                    subtitle: AppLocalizations.of(
                                      context,
                                    )!.deleteReviewDialog,
                                    context: context,
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
                              style: CustomTypography.bodySmallBold.copyWith(
                                color: CustomColors.black,
                              ),
                              AppLocalizations.of(context)!.deleteReviewButton,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
