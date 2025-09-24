import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  //TODO: make this statefull and adda a login logic to check the user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/logo.png", width: 200),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
