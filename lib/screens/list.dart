import 'package:flutter/material.dart';

import '../widget/custom_app_bar.dart';
import '../widget/custom_bottom_bar.dart';

class List extends StatelessWidget {
  static String path = '/list';

  const List({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: "List", searchEnabled: true),
      bottomNavigationBar: CustomBottomBar(activePage: "list"),
    );
  }
}
