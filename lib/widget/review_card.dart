import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../model/media_with_poster.dart';
import '../model/review.dart';
import '../providers/review_media.dart';

class ReviewCard extends ConsumerWidget {
  final Review review;
  final String language;

  const ReviewCard({super.key, required this.review, required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MediaWithPoster> mediaAsync = ref.watch(
      reviewMediaProvider(review.reviewId, language),
    );

    return mediaAsync.when(
      data: (MediaWithPoster mediaWithPoster) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              context.pushNamed(
                'reviewInfo',
                pathParameters: <String, String>{'reviewId': review.reviewId},
              );
            },
            child: Image.memory(
              mediaWithPoster.poster!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      },
      loading: () =>
          const Card(child: Center(child: CircularProgressIndicator())),
      error: (Object error, StackTrace stack) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.error, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Error loading ${review.type.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  error.toString(),
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
