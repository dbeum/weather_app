import 'package:flutter/material.dart';
import 'package:weather_web/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        popupMenuTheme: PopupMenuThemeData(
          color: Color.fromARGB(255, 61, 127, 137), // Background color of the popup menu
          textStyle: TextStyle(
            color: Color.fromARGB(255, 233, 241, 242), // Text color in the popup menu
            fontWeight: FontWeight.bold, // Bold text
            fontSize: 16, // Text size
          ),
        ),
      
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
