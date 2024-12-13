import 'package:books/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Book Discovery App',
      theme: ThemeData(
        primaryColor: const Color(0xFF001E48), // App bar color
        scaffoldBackgroundColor: Colors.white, // Background color
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xFF001E48), // App bar color
        ),
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.white), // Text color
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Icon color
      ),
      debugShowCheckedModeBanner: false,
      home:const HomeScreen(),
    );
  }
}





