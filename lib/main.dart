import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:to_do/firebase_options.dart';
import 'package:to_do/screen/authscreen.dart';
import 'package:to_do/screen/homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,),),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      }),
    );
  }
}