import 'package:flutter/material.dart';
import 'package:weather_mobile/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
