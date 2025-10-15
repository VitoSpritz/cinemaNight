import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widget/custom_app_bar.dart';

class Chats extends StatelessWidget {
  static String path = '/chats';

  const Chats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.chats,
        searchEnabled: true,
      ),
    );
  }
}
