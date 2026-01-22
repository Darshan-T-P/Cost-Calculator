import 'package:flutter/material.dart';
import '../widgets/InputFields.dart';
import '../widgets/CalculateButton.dart';
import 'dart:math';

class CalculationForm extends StatefulWidget {
  const CalculationForm({super.key});

  @override
  State<CalculationForm> createState() => _CalculationFormState();
}

class _CalculationFormState extends State<CalculationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final countController = TextEditingController();
  final priceController = TextEditingController();
  final fiberController = TextEditingController();
  final cleanedFiberController = TextEditingController();
  final contributionController = TextEditingController();
  final tmController = TextEditingController();
  final tpiController = TextEditingController();
  final cspSpeedController = TextEditingController();
  final efficiencyController = TextEditingController();
  final gpsController = TextEditingController();
  final productionController = TextEditingController();
  final costOfProductionController = TextEditingController();

  // Selected values
  String? selectedContribution;
  String? selectedProduction;
  String? selectedCount;
  String? selectedMachine;

  // Used to avoid triggering TM listener when updating programmatically
  bool _isProgrammaticTMUpdate = false;

  // shiftType and contributionValue extracted from contribution dropdown
  String? shiftType;
  double? contributionValue;

  // Yarn specs map holds TM, TPI, SpindleSpeed, Efficiency per count/machine
  final Map<String, Map<String, Map<String, double>>> yarnSpecs = {
    "12": {
      "Normal": {
        "TM": 3.5,
        "SpindleSpeed": 14000,
        "Efficiency": 88,
      },
      "Compact": {
        "TM": 3.2,
        "SpindleSpeed": 14000,
        "Efficiency": 87,
      },
      "Siro": {
        "TM": 3.4,
        "SpindleSpeed": 14000,
        "Efficiency": 87,
      },
      "Slub": {
        "TM": 3.75,
        "SpindleSpeed": 12000,
        "Efficiency": 86,
      },
    },
    "15": {
      "Normal": {
        "TM": 3.4,
        "SpindleSpeed": 13000,
        "Efficiency": 89,
      },
      "Compact": {
        "TM": 3.0,
        "SpindleSpeed": 13000,
        "Efficiency": 88,
      },
      "Siro": {
        "TM": 3.3,
        "SpindleSpeed": 13000,
        "Efficiency": 88,
      },
      "Slub": {
        "TM": 3.7,
        "SpindleSpeed": 11000,
        "Efficiency": 85,
      },
    },
    // Added count 30 specs here
    "30": {
      "Normal": {
        "TM": 3.35,
        "SpindleSpeed": 19000,
        "Efficiency": 92,
      },
      "Compact": {
        "TM": 3.0,
        "SpindleSpeed": 19000,
        "Efficiency": 91,
      },
      "Siro": {
        "TM": 3.2,
        "SpindleSpeed": 19000,
        "Efficiency": 91,
      },
      "Slub": {
        "TM": 3.7,
        "SpindleSpeed": 18500,
        "Efficiency": 90,
      },
    },
    "32": {
      "Normal": {
        "TM": 3.35,
        "SpindleSpeed": 19000,
        "Efficiency": 92,
      },
      "Compact": {
        "TM": 3.0,
        "SpindleSpeed": 19000,
        "Efficiency": 91,
      },
      "Siro": {
        "TM": 3.2,
        "SpindleSpeed": 19000,
        "Efficiency": 91,
      },
      "Slub": {
        "TM": 3.7,
        "SpindleSpeed": 18500,
        "Efficiency": 90,
      },
    },
  };

  // GPS production map: count -> machine -> shift -> GPS value

  void _calculateGPS() {
    final speed = double.tryParse(cspSpeedController.text);
    final efficiency = double.tryParse(efficiencyController.text);
    final tpi = double.tryParse(tpiController.text);
    final countNum = double.tryParse(selectedCount ?? '');

    if (speed != null && tpi != null && countNum != null && countNum != 0) {
      final gpsValue = ((7.2 * speed) / (tpi * countNum)) * (efficiency! / 100);
      gpsController.text = gpsValue.toStringAsFixed(2);
    } else {
      gpsController.text = '';
    }
  }

  void _calculateProductionAndCost() {
    final gps = double.tryParse(gpsController.text);
    if (gps == null || selectedContribution == null) {
      productionController.text = '';
      return;
    }

    // Parse contribution like "1632 - 60000"
    final parts = selectedContribution!.split('-');
    if (parts.length != 2) {
      productionController.text = '';
      return;
    }

    final machineCount = double.tryParse(parts[0].trim());
    final contributionCost = double.tryParse(parts[1].trim());

    if (machineCount == null || contributionCost == null) {
      productionController.text = '';
      return;
    }

    // Production formula
    final production = (gps * 3 * machineCount) / 1000;
    productionController.text = production.toStringAsFixed(2);

    // Production cost formula
    if (production != 0) {
      final prodCost = contributionCost / production;
      costOfProductionController.text = prodCost.toStringAsFixed(2);
    } else {
      costOfProductionController.text = '';
    }
  }

  void _updateSpecs() {
    if (selectedCount != null && selectedMachine != null) {
      final specs = yarnSpecs[selectedCount]?[selectedMachine];
      if (specs != null) {
        final tmValue = specs["TM"] ?? 0.0;
        final countNum = double.tryParse(selectedCount!);
        if (countNum != null) {
          _isProgrammaticTMUpdate = true;

          // Set TM directly from yarnSpecs
          tmController.text = tmValue.toStringAsFixed(2);

          // Calculate TPI = sqrt(count) * TM
          final tpiValue = sqrt(countNum) * tmValue;
          tpiController.text = tpiValue.toStringAsFixed(2);

          cspSpeedController.text = specs["SpindleSpeed"]?.toString() ?? "";
          efficiencyController.text = specs["Efficiency"]?.toString() ?? "";
          costOfProductionController.text =
              specs["ProductionCost"]?.toStringAsFixed(2) ?? "";
          priceController.text = specs["Price"]?.toStringAsFixed(2) ?? "";

          _isProgrammaticTMUpdate = false;
        }
      }
      _calculateGPS();
      _calculateProductionAndCost();
    }
  }

  @override
  void initState() {
    super.initState();

    fiberController.addListener(() {
      final fiberText = fiberController.text;
      final fiber = double.tryParse(fiberText);
      if (fiber != null) {
        cleanedFiberController.text = (fiber * 1.05).toStringAsFixed(2);
      } else {
        cleanedFiberController.text = '';
      }
    });

    tmController.addListener(() {
      if (_isProgrammaticTMUpdate) return;
      final tm = double.tryParse(tmController.text);
      final countNum = double.tryParse(selectedCount ?? '');
      if (tm != null && countNum != null) {
        final tpiValue = sqrt(countNum) * tm;
        tpiController.text = tpiValue.toStringAsFixed(2);

        _calculateGPS();
        _calculateProductionAndCost();
      } else {
        tpiController.text = '';
        gpsController.text = '';
        productionController.text = '';
        costOfProductionController.text = '';
      }
    });
  }

  @override
  void dispose() {
    countController.dispose();
    priceController.dispose();
    fiberController.dispose();
    cleanedFiberController.dispose();
    contributionController.dispose();
    tmController.dispose();
    tpiController.dispose();
    cspSpeedController.dispose();
    efficiencyController.dispose();
    gpsController.dispose();
    productionController.dispose();
    costOfProductionController.dispose();
    super.dispose();
  }

  // Validator for numbers (int or double)
  String? _validateRequiredNum(String? value, {bool isInt = false}) {
    if (value == null || value.isEmpty) return 'This field is required';
    return isInt
        ? (int.tryParse(value) == null ? 'Enter a valid integer' : null)
        : (double.tryParse(value) == null ? 'Enter a valid number' : null);
  }

  void _onCalculate() {
    if (_formKey.currentState!.validate()) {
      // Your calculation logic goes here

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calculation successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: Text(
                  'Cost Calculation Form',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Count Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Count',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedCount,
                items: yarnSpecs.keys
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCount = val;
                    // Automatically select first machine if none or invalid for new count
                    if (selectedMachine == null ||
                        !(yarnSpecs[selectedCount]
                                ?.containsKey(selectedMachine) ??
                            false)) {
                      selectedMachine = yarnSpecs[selectedCount]?.keys.first;
                    }
                    _updateSpecs();
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select count' : null,
              ),
              const SizedBox(height: 12),

              // Fiber input
              InputFields(
                labelText: 'Fiber',
                hintText: 'Enter Fiber',
                controller: fiberController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: _validateRequiredNum,
              ),
              const SizedBox(height: 12),

              // Cleaned Fiber read-only
              InputFields(
                labelText: 'Cleaned Fiber',
                hintText: 'Auto-calculated',
                controller: cleanedFiberController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: false,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Cleaned Fiber will auto-fill'
                    : null,
              ),
              const SizedBox(height: 12),

              // Contribution/Shift Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Contribution',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedContribution,
                items: ["1632 - 60000", "1440 - 50000"]
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedContribution = val;
                    if (val != null) {
                      final parts = val.split('-');
                      if (parts.length == 2) {
                        shiftType = parts[0].trim();
                        contributionValue = double.tryParse(parts[1].trim());
                        _updateSpecs(); // This calls _calculateGPS & _calculateProductionAndCost
                        // But just to be safe and immediate:
                        // _calculateProductionAndCost();
                      }
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select contribution' : null,
              ),
              const SizedBox(height: 12),

              // Machine Selector - dynamic radio buttons based on selectedCount
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: yarnSpecs[selectedCount]
                        ?.keys
                        .map(
                          (machine) => RadioListTile<String>(
                            title: Text(machine),
                            value: machine,
                            groupValue: selectedMachine,
                            onChanged: (val) => setState(() {
                              selectedMachine = val;
                              _updateSpecs();
                            }),
                          ),
                        )
                        .toList() ??
                    [],
              ),

              // TM
              InputFields(
                labelText: 'TM',
                hintText: 'Auto-calculated or change to recalculate TPI',
                controller: tmController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'TM required' : null,
              ),
              const SizedBox(height: 12),

              // TPI
              InputFields(
                labelText: 'TPI',
                hintText: 'Auto-calculated from TM',
                controller: tpiController,
                enabled: false,
              ),
              const SizedBox(height: 12),

              // CSP Speed (Spindle Speed)
              InputFields(
                labelText: 'Spindle Speed',
                hintText: 'Auto-calculated from Count and Machine',
                controller: cspSpeedController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: false,
                validator: _validateRequiredNum,
              ),
              const SizedBox(height: 12),

              // Efficiency
              InputFields(
                labelText: 'Efficiency',
                hintText: 'Auto-calculated from Count and Machine',
                controller: efficiencyController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: false,
                validator: _validateRequiredNum,
              ),
              const SizedBox(height: 12),

              // GPS
              InputFields(
                labelText: 'GPS',
                hintText: 'Auto-filled based on Count, Machine, and Shift',
                controller: gpsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: _validateRequiredNum,
              ),
              const SizedBox(height: 12),

              // Production (calculated, read-only)
              InputFields(
                labelText: 'Production',
                hintText: 'Auto-calculated from GPS and Contribution',
                controller: productionController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: false,
                validator: _validateRequiredNum,
              ),
              const SizedBox(height: 12),
// Cost of Production
              InputFields(
                labelText: 'Cost of Production',
                hintText: 'Auto-filled',
                controller: costOfProductionController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: false,
                validator: _validateRequiredNum,
              ),
              const SizedBox(height: 24),
              const SizedBox(
                height: 10,
              ),
              // Calculate Button
              CalculateButton(onPressed: _onCalculate),
            ],
          ),
        ),
      ),
    );
  }
}
