import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../consts/custom_colors.dart';
import '../../consts/custom_typography.dart';
import '../../consts/sizes.dart';
import '../../model/chat_item.dart';

class LikeDislikeBottomMessageView extends ConsumerWidget {
  final ChatItemState chatState;
  final String userId;
  final List<String>? userLikes;
  final List<String>? userDislikes;
  final Function()? onLikeFunction;
  final Function()? onRemoveLikeFunction;
  final Function()? onDislikeFunction;
  final Function()? onRemoveDislikeFunction;

  const LikeDislikeBottomMessageView({
    super.key,
    required this.chatState,
    required this.userId,
    this.userDislikes,
    this.userLikes,
    this.onDislikeFunction,
    this.onLikeFunction,
    this.onRemoveDislikeFunction,
    this.onRemoveLikeFunction,
  });

  bool hasAlreadyChosen({required String type}) {
    switch (type) {
      case 'like':
        return userDislikes?.contains(userId) ?? false;
      case 'dislike':
        return userLikes?.contains(userId) ?? false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasLiked = userLikes?.contains(userId) ?? false;
    final bool hasDisliked = userDislikes?.contains(userId) ?? false;

    final bool isDateMessage = userDislikes == null;

    final bool hasDislikes = userDislikes != null
        ? chatState == ChatItemState.filmSelection
        : chatState == ChatItemState.dateSelection;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 4.0),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            if (!hasDislikes) {
              return;
            } else if (hasAlreadyChosen(type: 'like') == false) {
              hasLiked ? onRemoveLikeFunction?.call() : onLikeFunction?.call();
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Icon(
                      Icons.thumb_up,
                      size: Sizes.iconSmall,
                      color: hasLiked
                          ? CustomColors.mainYellow
                          : CustomColors.inputFill,
                    ),
                    const Icon(
                      Icons.thumb_up_outlined,
                      size: Sizes.iconSmall,
                      color: CustomColors.black,
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Text(
                  (userLikes?.length ?? 0).toString(),
                  style: CustomTypography.caption,
                ),
              ],
            ),
          ),
        ),
        if (!isDateMessage) ...<Widget>[
          const SizedBox(width: 16.0),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              if (!hasDislikes) {
                return;
              } else if (hasAlreadyChosen(type: 'dislike') == false) {
                hasDisliked
                    ? onRemoveDislikeFunction?.call()
                    : onDislikeFunction?.call();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Icon(
                        Icons.thumb_down,
                        size: Sizes.iconSmall,
                        color: hasDisliked
                            ? CustomColors.mainYellow
                            : CustomColors.inputFill,
                      ),
                      const Icon(
                        Icons.thumb_down_outlined,
                        size: Sizes.iconSmall,
                        color: CustomColors.black,
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    (userDislikes?.length ?? 0).toString(),
                    style: CustomTypography.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
