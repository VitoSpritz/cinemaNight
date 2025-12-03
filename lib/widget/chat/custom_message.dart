import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../consts/custom_colors.dart';
import '../../consts/custom_typography.dart';
import '../../consts/sizes.dart';
import '../../model/chat_item.dart';
import '../../model/chat_message.dart';

class CustomMessage extends ConsumerWidget {
  final bool isUserMessage;
  final String userId;
  final ChatMessage message;
  final ChatItemState chatState;
  final String? senderName;
  final Function()? dateLikeFunction;
  final Function()? removeDateLikeFunction;
  final int? dateUpdateCount;

  const CustomMessage({
    super.key,
    required this.isUserMessage,
    required this.message,
    required this.userId,
    required this.chatState,
    this.senderName,
    this.dateLikeFunction,
    this.dateUpdateCount,
    this.removeDateLikeFunction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String messageType = message.content.runtimeType.toString();
    final List<String> dateLikeUsers = message.content.when(
      text: (String text) => <String>[],
      date: (DateTime date, List<String> likes) => likes,
      film:
          (
            String film,
            List<String> likes,
            List<String> dislikes,
            String? comment,
          ) => <String>[],
    );

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
                              String filmId,
                              List<String> likes,
                              List<String> dislikes,
                              String? comment,
                            ) {
                              return Text(
                                comment != null ? '$filmId: $comment' : filmId,
                                style: CustomTypography.bodySmall,
                              );
                            },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, M/d/y').format(message.sentAt),
                        style: CustomTypography.minimal,
                      ),
                      messageType == "DateContent"
                          ? const SizedBox(height: 4)
                          : const SizedBox(height: 0),
                      if (messageType == "DateContent" &&
                          dateLikeUsers.contains(userId))
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                chatState == ChatItemState.dateSelection
                                    ? removeDateLikeFunction?.call()
                                    : null;
                              },
                              child: const Icon(
                                Icons.thumb_up,
                                size: Sizes.iconSmall,
                                color: CustomColors.mainYellow,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateLikeUsers.length.toString(),
                              style: CustomTypography.caption,
                            ),
                          ],
                        )
                      else if (messageType == "DateContent")
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                chatState == ChatItemState.dateSelection
                                    ? dateLikeFunction?.call()
                                    : null;
                              },
                              child: const Icon(Icons.thumb_up, size: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateLikeUsers.length.toString(),
                              style: CustomTypography.caption,
                            ),
                          ],
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
