import 'dart:math';

import 'package:emi_calculator/database/database_helper.dart';
import 'package:emi_calculator/models/emi_calculation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EMIController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  var tabIndex = 0.obs;

  void switchTab(int index) {
    tabIndex.value = index;
  }
  // Observables
  var amount = 0.0.obs;
  var interestRate = 0.0.obs;
  var periodYears = 0.obs;
  var processingFee = 0.0.obs;
  var monthlyEMI = 0.0.obs;
  var totalInterest = 0.0.obs;
  var totalPayment = 0.0.obs;
  var calculations = <EMICalculation>[].obs;
  var currentCalculation = Rxn<EMICalculation>();
  var isEMIInputSelected = false.obs;
  final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  var hasCalculated = false.obs;

  // TextEditingControllers to avoid rebuilding creating new controllers
  late final TextEditingController amountController;
  late final TextEditingController interestController;
  late final TextEditingController periodController;
  late final TextEditingController emiController;
  late final TextEditingController processingFeeController;

  // Internal guard to avoid update loops
  bool _internalUpdate = false;

  @override
  void onInit() {
    super.onInit();

    // init text controllers with initial values
    amountController = TextEditingController();
    interestController = TextEditingController();
    periodController = TextEditingController();
    emiController = TextEditingController();
    processingFeeController = TextEditingController();

    // listeners: when user types, update observables
    amountController.addListener(() {
      if (_internalUpdate) return;
      final parsed = double.tryParse(amountController.text.replaceAll(',', ''));
      if (parsed != null) {
        amount.value = parsed;
      }
      // if parsed is null (empty/invalid), keep previous value => do nothing
    });

    interestController.addListener(() {
      if (_internalUpdate) return;
      final parsed = double.tryParse(interestController.text);
      if (parsed != null) {
        // keep interest within reasonable bounds to avoid slider assertion
        final bounded = parsed.clamp(0.0, 100.0);
        interestRate.value = bounded;
      }
    });

    periodController.addListener(() {
      if (_internalUpdate) return;
      final parsed = double.tryParse(periodController.text);
      if (parsed != null && parsed > 0) {
        periodYears.value = parsed.round();
      }
    });



    emiController.addListener(() {
      if (_internalUpdate) return;
      final parsed = double.tryParse(emiController.text);
      if (parsed != null && parsed > 0) {
        monthlyEMI.value = parsed;

        // if EMI field is the active input, compute period automatically
        if (!isEMIInputSelected.value) {
          _computePeriodFromEmi();
        }
      }
    });

    processingFeeController.addListener(() {
      if (_internalUpdate) return;
      final parsed = double.tryParse(processingFeeController.text);
      if (parsed != null) {
        processingFee.value = parsed;
      }
    });

    // keep text controllers in sync when observables change programmatically
    ever(amount, (_) => _updateTextControllers());
    ever(interestRate, (_) => _updateTextControllers());
    ever(periodYears, (_) => _updateTextControllers());
    ever(monthlyEMI, (_) => _updateTextControllers());
    ever(processingFee, (_) => _updateTextControllers());

    // load saved calculations
    loadCalculations();
  }

  void _updateTextControllers() {
    _internalUpdate = true;

    String formatNumber(double value) {
      if (value == 0) return '';
      if (value % 1 == 0) {
        // integer (no decimal part)
        return value.toInt().toString();
      } else {
        // decimal (keep only necessary digits)
        return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
      }
    }

    amountController.text = formatNumber(amount.value);
    interestController.text = formatNumber(interestRate.value);
    periodController.text = formatNumber(periodYears.value.toDouble());
    emiController.text = formatNumber(monthlyEMI.value);
    processingFeeController.text = formatNumber(processingFee.value);

    // move caret to end
    amountController.selection = TextSelection.fromPosition(TextPosition(offset: amountController.text.length));
    interestController.selection = TextSelection.fromPosition(TextPosition(offset: interestController.text.length));
    periodController.selection = TextSelection.fromPosition(TextPosition(offset: periodController.text.length));
    emiController.selection = TextSelection.fromPosition(TextPosition(offset: emiController.text.length));
    processingFeeController.selection = TextSelection.fromPosition(TextPosition(offset: processingFeeController.text.length));

    _internalUpdate = false;
  }



  void resetAll() {
    amount.value = 0.0;
    interestRate.value = 0.0;
    periodYears.value = 0;
    processingFee.value = 0.0;
    monthlyEMI.value = 0.0;
    totalInterest.value = 0.0;
    totalPayment.value = 0.0;

    _internalUpdate = true;
    amountController.clear();
    interestController.clear();
    periodController.clear();
    emiController.clear();
    processingFeeController.clear();
    _internalUpdate = false;

    hasCalculated.value = false;
    isEMIInputSelected.value = false;
    currentCalculation.value = null;
  }

  calculateEMI() {
    double p = amount.value;
    double r = interestRate.value / 12 / 100;
    int n = (periodYears.value * 12).round(); // years → months

    if (p <= 0 || r <= 0 || n <= 0) {
      monthlyEMI.value = 0.0;
      totalInterest.value = 0.0;
      totalPayment.value = 0.0;
      return;
    }

    double emi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    if (emi.isNaN || emi.isInfinite) emi = 0.0;
    monthlyEMI.value = emi;

    double total = emi * n;
    totalPayment.value = total + (p * processingFee.value / 100);
    totalInterest.value = total - p;
  }



  // When user enters EMI (and EMI input is active), compute n (period months)
  void _computePeriodFromEmi() {
    double p = amount.value;
    double r = interestRate.value / 12 / 100;
    double emi = monthlyEMI.value;

    if (p <= 0 || r <= 0 || emi <= 0) return;

    double denom = (emi - p * r);
    if (denom <= 0) return;

    double nRaw = (log(emi / denom) / log(1 + r));
    if (nRaw.isNaN || nRaw.isInfinite) return;

    // convert months → years
    double years = nRaw / 12;
    periodYears.value = years.round();
    calculateEMI();
  }



  Future<void> saveCalculation() async {
    final calculation = EMICalculation(
      amount: double.parse(amount.value.toStringAsFixed(2)),
      interestRate: double.parse(interestRate.value.toStringAsFixed(2)),
      periodMonths: periodYears.value * 12,
      monthlyEMI: double.parse(monthlyEMI.value.toStringAsFixed(2)),
      totalInterest: double.parse(totalInterest.value.toStringAsFixed(2)),
      processingFee: double.parse((amount.value * processingFee.value / 100).toStringAsFixed(2)),
      totalPayment: double.parse(totalPayment.value.toStringAsFixed(2)),
      calculatedDate: DateTime.now(),
    );


    await _dbHelper.insertCalculation(calculation);
    await loadCalculations();

  }

  Future<void> loadCalculations() async {
    calculations.value = await _dbHelper.getAllCalculations();
  }

  Future<void> deleteCalculation(int id) async {
    await _dbHelper.deleteCalculation(id);
    await loadCalculations();
  }

  Future<void> deleteAllCalculations() async {
    await _dbHelper.deleteAllCalculations();
    await loadCalculations();
  }

  List<Map<String, dynamic>> getAmortizationSchedule() {
    List<Map<String, dynamic>> schedule = [];
    double balance = amount.value;
    double monthlyRate = interestRate.value / 12 / 100;
    int totalMonths = (periodYears.value * 12).round();

    for (int month = 1; month <= totalMonths; month++) {
      double interest = balance * monthlyRate;
      double principal = monthlyEMI.value - interest;
      balance -= principal;

      schedule.add({
        'month': month,
        'principal': principal,
        'interest': interest,
        'balance': max(0.0, balance),
      });
    }

    return schedule;
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_time') ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', value);
  }

  void deleteCalculationAt(int index) {
    calculations.removeAt(index);
    // call your save function here too.
    // saveCalculations();
  }

  @override
  void onClose() {
    amountController.clear();
    // interestController.clear();
    // periodController.clear();
    // emiController.clear();
    // processingFeeController.clear();
    amountController.dispose();
    interestController.dispose();
    periodController.dispose();
    emiController.dispose();
    processingFeeController.dispose();
    super.onClose();
  }
}
