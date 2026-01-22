// lib/features/cost_calculation/presentation/pages/calculation_page.dart
import './calculation_input.dart';

import 'package:flutter/material.dart';

class CalculationPage extends StatelessWidget {
  const CalculationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cost Calculation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CalculationForm(),
      ),
    );
  }
}
