import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_typography.dart';
import '../l10n/app_localizations.dart';
import '../model/user_profile.dart';
import '../providers/user_profiles.dart';
import '../widget/custom_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  static String path = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserProfile> userProfileAsync = ref.watch(
      userProfilesProvider,
    );
    return userProfileAsync.when(
      data: (UserProfile data) {
        return Scaffold(
          appBar: CustomAppBar(title: AppLocalizations.of(context)!.info),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        data.firstLastName != null
                            ? AppLocalizations.of(
                                context,
                              )!.welcome(data.firstLastName!)
                            : AppLocalizations.of(context)!.singelWelcome,
                        style: CustomTypography.titleM.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.homeReviewInstructionFirst,
                        style: CustomTypography.body,
                      ),
                      const SizedBox(height: 16),
                      Card.outlined(
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.homeReviewInstructionSecond,
                                  style: CustomTypography.bodyBold,
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: AppLocalizations.of(
                                          context,
                                        )!.homeReviewInstructionThird,
                                      ),
                                      const WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(Icons.list, size: 18),
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(
                                          context,
                                        )!.homeReviewInstructionFourth,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card.outlined(
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.homeChatInstructionFirst,
                                  style: CustomTypography.bodyBold,
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: AppLocalizations.of(
                                          context,
                                        )!.homeChatInstructionSecond,
                                      ),
                                      const WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(Icons.chat, size: 18),
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(
                                          context,
                                        )!.homeChatInstructionThird,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (_, __) {
        return const Center(child: Text("Errore"));
      },
      loading: () {
        return const Center(
          child: Column(children: <Widget>[CircularProgressIndicator()]),
        );
      },
    );
  }
}
