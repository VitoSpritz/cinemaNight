import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';
import '../l10n/app_localizations.dart';
import '../model/review.dart';
import '../model/user_profile.dart';
import '../providers/deep_link.dart';
import '../providers/user_profiles.dart';
import '../providers/user_review.dart';
import '../widget/custom_add_button.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_icon_button.dart';
import '../widget/custom_search_bar.dart';
import '../widget/film_picker_modal.dart';
import '../widget/review_card.dart';
import '../widget/search_modal.dart';

class ReviewList extends ConsumerStatefulWidget {
  static String path = '/reviewList';
  const ReviewList({super.key});

  @override
  ConsumerState<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends ConsumerState<ReviewList> {
  String? searchQuery;

  final TextEditingController searchController = TextEditingController();

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const FilmPickerModal();
      },
    );
  }

  List<Review> _filterReviews(List<Review> reviews) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return reviews;
    }

    return reviews.where((Review review) {
      return review.filmName.toLowerCase().contains(searchQuery!.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Review>> userReviewListAsync = ref.watch(
      userReviewProvider,
    );
    final AsyncValue<UserProfile> userAsync = ref.watch(userProfilesProvider);

    final UserProfile? user = userAsync.when(
      data: (UserProfile data) => data,
      error: (_, __) => null,
      loading: () => null,
    );
    final String language = AppLocalizations.of(context)!.requestApiLanguage;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: AppPalette.of(context).backgroudColor.defaultColor,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: AppLocalizations.of(context)!.reviews,
            actionButton: CustomIconButton(
              icon: Icons.ios_share,
              onTap: () async {
                final String? searchValue = await SearchModal.show(
                  title: AppLocalizations.of(context)!.pasteALink,
                  context: context,
                );
                setState(() {
                  handleDeepLink(Uri.parse(searchValue!));
                });
              },
              color: CustomColors.text,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(userReviewProvider.future);
            },
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 0;
            },
            child: userReviewListAsync.when(
              data: (List<Review> reviews) {
                final List<Review> filteredReviews = _filterReviews(reviews);
                if (filteredReviews.isEmpty) {
                  return ListView(
                    children: <Widget>[
                      const SizedBox(height: 200),
                      Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              searchQuery != null && searchQuery!.isNotEmpty
                                  ? AppLocalizations.of(
                                      context,
                                    )!.reviewListNoReviewsFound(searchQuery!)
                                  : AppLocalizations.of(
                                      context,
                                    )!.reviewListNoReviewAvailable,
                              style: CustomTypography.body.copyWith(
                                color: AppPalette.of(
                                  context,
                                ).textColors.defaultColor,
                              ),
                            ),
                            if (searchQuery != null) ...<Widget>[
                              const SizedBox(height: 16),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppPalette.of(
                                    context,
                                  ).textColors.defaultColor,
                                ),
                                onPressed: () => setState(() {
                                  searchQuery = null;
                                }),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.chatListDeleteSearch,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 8.0,
                      ),
                      child: CustomSearchBar(
                        searchController: searchController,
                        onSubmitFunction: () {
                          setState(() {
                            searchQuery = searchController.text;
                            searchController.text = "";
                          });
                        },
                      ),
                    ),
                    if (searchQuery != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                              border: Border.all(
                                color: CustomColors.black,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 6.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Text(
                                      searchQuery!,
                                      style: CustomTypography.caption,
                                    ),
                                  ),
                                  CustomIconButton(
                                    icon: Icons.cancel,
                                    color: CustomColors.black,
                                    iconSize: 14,
                                    padding: 4,
                                    onTap: () => setState(() {
                                      searchQuery = null;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.75,
                            ),
                        padding: const EdgeInsets.all(8.0),
                        itemCount: filteredReviews.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ReviewCard(
                            review: filteredReviews.elementAt(index),
                            userId: user!.userId,
                            language: language,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              error: (Object error, StackTrace stack) => ListView(
                children: <Widget>[
                  const SizedBox(height: 200),
                  Center(child: Text("Error: $error")),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          floatingActionButton: CustomAddButton(
            onPressed: () => _showModal(context),
          ),
        ),
      ],
    );
  }
}
