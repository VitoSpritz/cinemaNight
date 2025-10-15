import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'login.dart';

class HomeScreen extends ConsumerWidget {
  static String path = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.homePage,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final bool? isLoggingOut = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirmLogout),
                    content: Text(
                      AppLocalizations.of(context)!.areYouSureYouWantToQuit,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(AppLocalizations.of(context)!.no),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(AppLocalizations.of(context)!.yes),
                      ),
                    ],
                  );
                },
              );
              if (isLoggingOut == true) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go(LoginScreen.path);
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.welcome,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.currentUserString(
                FirebaseAuth.instance.currentUser?.email ??
                    AppLocalizations.of(context)!.unknown,
              ),
              style: const TextStyle(fontSize: 16),
            ),

            ElevatedButton(
              onPressed: () => context.push(HomeScreen.path),
              child: Text(AppLocalizations.of(context)!.goToHome),
            ),
          ],
        ),
      ),
    );
  }
}
