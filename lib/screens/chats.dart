import 'package:flutter/material.dart';

import '../widget/custom_app_bar.dart';

class Chats extends StatelessWidget {
  static String path = '/chats';

  const Chats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: "Chats", searchEnabled: true),
    );
  }
}
