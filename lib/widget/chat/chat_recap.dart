import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../consts/custom_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../model/chat_message.dart';
import '../../providers/chat_list.dart';
import '../../providers/film_poster.dart';

class ChatRecap extends ConsumerWidget {
  final String chatId;

  const ChatRecap({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<
      ({ChatMessage? topDateMessage, ChatMessage? topFilmMessage})
    >
    chatAsync = ref.watch(getMostLikedMessagesProvider(chatId: chatId));

    return chatAsync.when(
      data:
          (({ChatMessage? topDateMessage, ChatMessage? topFilmMessage}) data) {
            final String? chosenDate = data.topDateMessage?.content.when(
              text: (String text) => null,
              date: (DateTime date, List<String> likes) =>
                  DateFormat('dd MMMM yyyy').format(date),
              film: (String film, List<String> dislikes, List<String> likes) =>
                  null,
            );
            final String? chosenFilm = data.topFilmMessage?.content.when(
              text: (String text) => null,
              date: (DateTime date, List<String> likes) => null,
              film: (String film, List<String> dislikes, List<String> likes) =>
                  film,
            );

            Uint8List? filmData;
            if (chosenFilm != null) {
              final AsyncValue<Uint8List?> response = ref.watch(
                getFilmDataGivenNameProvider(
                  chosenFilm,
                  AppLocalizations.of(context)!.localeName,
                ),
              );
              filmData = response.value;
            }

            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      "La chat è terminata! Ecco i risultati",
                      style: CustomTypography.titleM.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: MediaQuery.of(context).padding.bottom + 24.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(height: 24.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16.0,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Data scelta per la serata: $chosenDate",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24.0),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16.0,
                            children: <Widget>[],
                          ),
                          const SizedBox(height: 24.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16.0,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Film scelto per la serata: $chosenFilm",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (filmData != null)
                            SizedBox(
                              width: 200,
                              height: 300,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Image.memory(
                                  filmData,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          const SizedBox(height: 32.0),
                          const SizedBox(width: double.infinity),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
      error: (_, __) => const Center(child: Text("Error")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
