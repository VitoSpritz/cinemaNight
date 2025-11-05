import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../model/review.dart';
import '../providers/user_review.dart';
import '../widget/custom_add_button.dart';
import '../widget/custom_app_bar.dart';
import '../widget/film_picker_modal.dart';
import '../widget/review_card.dart';

class ReviewList extends ConsumerWidget {
  static String path = '/reviewList';

  const ReviewList({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Review>> userReviewListAsync = ref.watch(
      userReviewProvider,
    );
    final String language = AppLocalizations.of(context)!.requiredField;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.reviews,
        searchEnabled: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userReviewProvider);
          await ref.read(userReviewProvider.future);
        },
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 0;
        },
        child: userReviewListAsync.when(
          data: (List<Review> reviews) {
            if (reviews.isEmpty) {
              return ListView(
                children: const <Widget>[
                  SizedBox(height: 200),
                  Center(child: Text("There are no reviews")),
                ],
              );
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.75,
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: reviews.length,
              itemBuilder: (BuildContext context, int index) {
                return ReviewCard(review: reviews[index], language: language);
              },
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
    );
  }
}
