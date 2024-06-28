import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignOutPage extends StatefulWidget {
  const SignOutPage({super.key});

  @override
  State<SignOutPage> createState() => _SignOutPageState();
}

class _SignOutPageState extends State<SignOutPage> {
  Future<void> signOutFromAccount(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'User Signed In',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () async {
                  signOutFromAccount(context);
                },
                child: const Text('Sign Out'))
          ],
        ),
      ),
    );
  }
}
