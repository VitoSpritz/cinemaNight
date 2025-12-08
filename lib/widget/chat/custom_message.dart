import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../consts/custom_colors.dart';
import '../../consts/custom_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../model/chat_item.dart';
import '../../model/chat_message.dart';
import '../../providers/film_poster.dart';
import 'like_dislike_bottom_message_view.dart';

class CustomMessage extends ConsumerWidget {
  final bool isUserMessage;
  final String userId;
  final ChatMessage message;
  final ChatItemState chatState;
  final String? senderName;
  final Function()? onLikeFunction;
  final Function()? onRemoveLikeFunction;
  final Function()? onDislikeFunction;
  final Function()? onRemoveDilikeFunction;
  final int? dateUpdateCount;

  const CustomMessage({
    super.key,
    required this.isUserMessage,
    required this.message,
    required this.userId,
    required this.chatState,
    this.senderName,
    this.onLikeFunction,
    this.dateUpdateCount,
    this.onRemoveLikeFunction,
    this.onDislikeFunction,
    this.onRemoveDilikeFunction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String>? userLikes = message.content.when(
      text: (String text) => null,
      date: (DateTime date, List<String> likes) => likes,
      film: (String film, List<String> likes, List<String> dislikes) => likes,
    );

    final List<String>? userDislikes = message.content.when(
      text: (String text) => null,
      date: (DateTime date, List<String> likes) => null,
      film: (String film, List<String> likes, List<String> dislikes) =>
          dislikes,
    );

    debugPrint("Runtime type => ${message.content.runtimeType}");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            child: ClipRRect(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    color: CustomColors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  color: CustomColors.gray.withValues(alpha: 0.2),
                  borderRadius: isUserMessage
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (senderName != null)
                        Text(
                          senderName!,
                          style: CustomTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 4),
                      message.content.when(
                        text: (String text) {
                          return Text(text, style: CustomTypography.bodySmall);
                        },
                        date: (DateTime proposedDate, List<String> likes) {
                          return Text(
                            DateFormat('dd/MM/yyyy').format(proposedDate),
                            style: CustomTypography.bodySmall,
                          );
                        },
                        film:
                            (
                              String filmName,
                              List<String> likes,
                              List<String> dislikes,
                            ) {
                              final AsyncValue<Uint8List?> posterAsync = ref
                                  .watch(
                                    getFilmDataGivenNameProvider(
                                      filmName,
                                      AppLocalizations.of(context)!.localeName,
                                    ),
                                  );
                              return posterAsync.when(
                                data: (Uint8List? bytes) {
                                  if (bytes == null) {
                                    return Text(
                                      filmName,
                                      style: CustomTypography.bodySmall,
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          bytes,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        filmName,
                                        style: CustomTypography.bodySmall,
                                      ),
                                    ],
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                error: (Object error, StackTrace stack) => Text(
                                  filmName,
                                  style: CustomTypography.bodySmall,
                                ),
                              );
                            },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, M/d/y').format(message.sentAt),
                        style: CustomTypography.minimal,
                      ),

                      if (message.content.runtimeType.toString() !=
                          "TextContent")
                        LikeDislikeBottomMessageView(
                          chatState: chatState,
                          userId: userId,
                          onDislikeFunction: onDislikeFunction,
                          onLikeFunction: onLikeFunction,
                          onRemoveDislikeFunction: onRemoveDilikeFunction,
                          onRemoveLikeFunction: onRemoveLikeFunction,
                          userDislikes: userDislikes,
                          userLikes: userLikes,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
