import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widget/custom_app_bar.dart';

class Account extends StatelessWidget {
  static String path = '/account';

  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.account,
        searchEnabled: false,
      ),
    );
  }
}
