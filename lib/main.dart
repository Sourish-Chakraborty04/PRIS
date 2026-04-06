import 'package:flutter/material.dart';
import 'core/widgets/nav_bar.dart';
import 'core/utils/colors.dart';

void main() {
  runApp(const PrisApp());
}

class PrisApp extends StatelessWidget {
  const PrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PrisColors.background,
        primaryColor: PrisColors.primary,
        fontFamily: 'Inter',
      ),
      home: const MainNavBar(),
    );
  }
}