import 'package:flutter/material.dart';
import 'screens/main_shell.dart';

void main() => runApp(const AmazonCloneApp());

class AmazonCloneApp extends StatelessWidget {
  const AmazonCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amazon Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFEAEDED),
      ),
      home: const MainShell(),
    );
  }
}