import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("HR Manager"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome ${user?.displayName ?? 'User'}"),
            SizedBox(height: 20),
            Text("Email: ${user?.email ?? ''}"),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
