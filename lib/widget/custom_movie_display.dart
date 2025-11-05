import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/sizes.dart';

class CustomMovieDisplay extends ConsumerWidget {
  final Uint8List? imageUrl;
  final String? movieTitle;
  final double? rating;

  const CustomMovieDisplay({
    super.key,
    required this.imageUrl,
    required this.movieTitle,
    required this.rating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: imageUrl != null
                ? Image.memory(
                    imageUrl!,
                    width: 100,
                    height: 125,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 100,
                    height: 125,
                    color: CustomColors.grey,
                    child: Icon(
                      Icons.movie,
                      color: CustomColors.white,
                      size: Sizes.iconSize,
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    movieTitle ?? 'Titolo non disponibile',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (rating != null)
                    Text(
                      '⭐ ${rating!.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
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
