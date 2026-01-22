import 'package:cost_calculator/features/cost_calculation/presentation/pages/calculation_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cost Calculator',
      // theme: AppTheme.darkThemeMode,
      debugShowCheckedModeBanner: false,
      home: const CalculationPage(),
    );
  }
}
