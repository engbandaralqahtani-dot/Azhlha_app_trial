import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseInit extends StatelessWidget {
  final Widget child;
  const FirebaseInit({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطأ في الاتصال بـ Firebase'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
