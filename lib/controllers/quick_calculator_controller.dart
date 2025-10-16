import 'package:emi_calculator/database/database_helper.dart';
import 'package:emi_calculator/models/emi_calculation.dart';
import 'package:get/get.dart';
import 'dart:math';

class QuickCalculatorController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Observable variables for Quick Calculator
  var amount = 100000.0.obs;
  var interestRate = 6.5.obs;
  var periodMonths = 96.obs;
  var periodYears = 8.obs; // 96 months = 8 years

  // Calculated values
  var monthlyEMI = 0.0.obs;
  var totalInterest = 0.0.obs;
  var totalPayment = 0.0.obs;
  var processingFee = 0.0.obs;

  // History
  var quickCalculations = <EMICalculation>[].obs;
  var currentCalculation = Rxn<EMICalculation>();

  // Active tab (0: EMI, 1: Amount, 2: Period, 3: Interest)
  var activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    calculateEMI();
    loadQuickCalculations();
  }

  // Calculate EMI based on active tab
  void calculateEMI() {
    double p = amount.value;
    double r = interestRate.value / 12 / 100;
    int n = periodMonths.value;

    if (p <= 0 || r <= 0 || n <= 0) {
      monthlyEMI.value = 0;
      totalPayment.value = 0;
      totalInterest.value = 0;
      return;
    }

    // EMI Formula: [P x R x (1+R)^N] / [(1+R)^N-1]
    double emi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    monthlyEMI.value = emi;

    double total = emi * n;
    totalPayment.value = total;
    totalInterest.value = total - p;
  }

  // Calculate when Amount is unknown (solve for Principal)
  void calculateAmount() {
    if (monthlyEMI.value <= 0 || interestRate.value <= 0 || periodMonths.value <= 0) {
      amount.value = 0;
      return;
    }

    double emi = monthlyEMI.value;
    double r = interestRate.value / 12 / 100;
    int n = periodMonths.value;

    // P = EMI × [(1+R)^N-1] / [R × (1+R)^N]
    double principal = emi * ((pow(1 + r, n) - 1) / (r * pow(1 + r, n)));
    amount.value = principal;

    totalPayment.value = emi * n;
    totalInterest.value = totalPayment.value - principal;
  }

  // Calculate when Period is unknown (solve for N)
  void calculatePeriod() {
    if (amount.value <= 0 || monthlyEMI.value <= 0 || interestRate.value <= 0) {
      periodMonths.value = 0;
      return;
    }

    double p = amount.value;
    double emi = monthlyEMI.value;
    double r = interestRate.value / 12 / 100;

    if (emi <= p * r) {
      // EMI is too small to cover even the interest
      periodMonths.value = 0;
      return;
    }

    // N = log[(EMI) / (EMI - P×R)] / log(1+R)
    double n = log(emi / (emi - p * r)) / log(1 + r);
    periodMonths.value = n.ceil();
    periodYears.value = (periodMonths.value / 12).ceil();

    totalPayment.value = emi * periodMonths.value;
    totalInterest.value = totalPayment.value - p;
  }

  // Calculate when Interest Rate is unknown (solve for R) - Complex, using approximation
  void calculateInterestRate() {
    if (amount.value <= 0 || monthlyEMI.value <= 0 || periodMonths.value <= 0) {
      interestRate.value = 0;
      return;
    }

    double p = amount.value;
    double emi = monthlyEMI.value;
    int n = periodMonths.value;

    // Using Newton-Raphson method for approximation
    double rate = 0.01; // Starting guess (1% monthly rate)
    double precision = 0.000001;

    for (int i = 0; i < 100; i++) {
      double fRate = p * rate * pow(1 + rate, n) / (pow(1 + rate, n) - 1) - emi;
      double fPrimeRate = (p * pow(1 + rate, n) * (pow(1 + rate, n) - 1 - n * rate)) /
          pow(pow(1 + rate, n) - 1, 2);

      double newRate = rate - fRate / fPrimeRate;

      if ((newRate - rate).abs() < precision) {
        rate = newRate;
        break;
      }
      rate = newRate;
    }

    interestRate.value = rate * 12 * 100; // Convert to annual percentage

    totalPayment.value = emi * n;
    totalInterest.value = totalPayment.value - p;
  }

  // Switch between tabs
  void setActiveTab(int index) {
    activeTab.value = index;
  }

  // Update period in years and convert to months
  void updatePeriodYears(double years) {
    periodYears.value = years.toInt();
    periodMonths.value = (years * 12).toInt();
    if (activeTab.value == 0) {
      calculateEMI();
    }
  }

  // Update period in months
  void updatePeriodMonths(int months) {
    periodMonths.value = months;
    periodYears.value = (months / 12).ceil();
    if (activeTab.value == 0) {
      calculateEMI();
    }
  }

  // Update amount
  void updateAmount(double newAmount) {
    amount.value = newAmount;
    if (activeTab.value == 0) {
      calculateEMI();
    }
  }

  // Update interest rate
  void updateInterestRate(double newRate) {
    interestRate.value = newRate;
    if (activeTab.value == 0) {
      calculateEMI();
    }
  }

  // Save current calculation to history
  Future<void> saveQuickCalculation() async {
    if (monthlyEMI.value <= 0) return;

    final calculation = EMICalculation(
      amount: amount.value,
      interestRate: interestRate.value,
      periodMonths: periodMonths.value,
      monthlyEMI: monthlyEMI.value,
      totalInterest: totalInterest.value,
      processingFee: 0,
      totalPayment: totalPayment.value,
      calculatedDate: DateTime.now(),
    );

    currentCalculation.value = calculation;
    await _dbHelper.insertCalculation(calculation);
    await loadQuickCalculations();
  }

  // Load all quick calculations
  Future<void> loadQuickCalculations() async {
    quickCalculations.value = await _dbHelper.getAllCalculations();
  }

  // Delete a calculation
  Future<void> deleteCalculation(int id) async {
    await _dbHelper.deleteCalculation(id);
    await loadQuickCalculations();
  }

  // Get amortization schedule
  List<Map<String, dynamic>> getAmortizationSchedule() {
    List<Map<String, dynamic>> schedule = [];
    double balance = amount.value;
    double monthlyRate = interestRate.value / 12 / 100;

    if (monthlyEMI.value <= 0 || periodMonths.value <= 0) {
      return schedule;
    }

    for (int month = 1; month <= periodMonths.value; month++) {
      double interest = balance * monthlyRate;
      double principal = monthlyEMI.value - interest;
      balance -= principal;

      if (balance < 0) balance = 0;

      schedule.add({
        'month': month,
        'principal': principal,
        'interest': interest,
        'balance': balance,
        'emi': monthlyEMI.value,
      });
    }

    return schedule;
  }

  // Get year-wise summary
  List<Map<String, dynamic>> getYearWiseSummary() {
    List<Map<String, dynamic>> yearSummary = [];
    final schedule = getAmortizationSchedule();

    if (schedule.isEmpty) return yearSummary;

    int totalYears = (periodMonths.value / 12).ceil();

    for (int year = 1; year <= totalYears; year++) {
      int startMonth = (year - 1) * 12;
      int endMonth = year * 12;
      if (endMonth > periodMonths.value) endMonth = periodMonths.value;

      double yearPrincipal = 0;
      double yearInterest = 0;
      double yearEMI = 0;

      for (int i = startMonth; i < endMonth && i < schedule.length; i++) {
        yearPrincipal += schedule[i]['principal'];
        yearInterest += schedule[i]['interest'];
        yearEMI += schedule[i]['emi'];
      }

      double remainingBalance = endMonth < schedule.length ? schedule[endMonth - 1]['balance'] : 0;

      yearSummary.add({
        'year': year,
        'principal': yearPrincipal,
        'interest': yearInterest,
        'totalPayment': yearEMI,
        'balance': remainingBalance,
      });
    }

    return yearSummary;
  }

  // Reset all values
  void reset() {
    amount.value = 100000.0;
    interestRate.value = 6.5;
    periodMonths.value = 96;
    periodYears.value = 8;
    monthlyEMI.value = 0.0;
    totalInterest.value = 0.0;
    totalPayment.value = 0.0;
    processingFee.value = 0.0;
    activeTab.value = 0;
    calculateEMI();
  }

  // Get loan summary
  Map<String, dynamic> getLoanSummary() {
    return {
      'amount': amount.value,
      'interestRate': interestRate.value,
      'periodMonths': periodMonths.value,
      'periodYears': periodYears.value,
      'monthlyEMI': monthlyEMI.value,
      'totalInterest': totalInterest.value,
      'totalPayment': totalPayment.value,
      'processingFee': processingFee.value,
      'loanPercentage': totalPayment.value > 0
          ? (amount.value / totalPayment.value) * 100
          : 100.0,
      'interestPercentage': totalPayment.value > 0
          ? (totalInterest.value / totalPayment.value) * 100
          : 0.0,
    };
  }
}