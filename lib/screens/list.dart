import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widget/custom_app_bar.dart';

class List extends StatelessWidget {
  static String path = '/list';

  const List({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.reviews,
        searchEnabled: true,
      ),
    );
  }
}
