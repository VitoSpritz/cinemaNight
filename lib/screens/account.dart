import 'package:flutter/material.dart';

import '../widget/custom_app_bar.dart';
import '../widget/custom_bottom_bar.dart';

class Account extends StatelessWidget {
  static String path = '/account';

  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: "Account", searchEnabled: false),
      bottomNavigationBar: CustomBottomBar(activePage: "account"),
    );
  }
}
