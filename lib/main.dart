import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleeping/sleeping_files/sleeping_ui.dart';

void main() {
  runApp(const SleepCalculatorApp());
}

class SleepCalculatorApp extends StatelessWidget {
  const SleepCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      home: const SleepCalculatorScreen(),
    );
  }

  // update test
}
