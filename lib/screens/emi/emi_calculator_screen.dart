import 'package:emi_calculator/controllers/emi_controller.dart';
import 'package:emi_calculator/screens/emi/history_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EMICalculatorScreen extends StatelessWidget {
  EMICalculatorScreen({Key? key}) : super(key: key);

  final EMIController controller = Get.isRegistered<EMIController>()
      ? Get.find<EMIController>()
      : Get.put(EMIController());

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.resetAll();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          //backgroundColor: Color(0xFF009EF7),
          title: Text('EMI Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            tooltip: 'Back',
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // optionally delete controller here if you want
              // Get.delete<EMIController>();
              // controller.resetAll();
              Get.back();
            },
          ),
          actions: [
            IconButton(
              tooltip: 'History',
              icon: Icon(Icons.history),
              onPressed: () {
                Get.to(() => HistoryScreen());
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form( // <-- wrap inputs in Form
            key: _formKey,
            child: Column(
              children: [
                _buildInputCard(controller),
                SizedBox(height: 18),

                // Buttons: validate form before calculating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- CALCULATE BUTTON ---
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // validate form according to current selection
                          if (_formKey.currentState?.validate() ?? false) {
                            controller.calculateEMI();
                            controller.hasCalculated.value = true;
                            if (controller.hasCalculated.value) {
                              controller.saveCalculation();
                            }
                          }
                          // else {
                          //   // show a short message
                          //   Get.snackbar(
                          //     'Invalid input',
                          //     'Please fill required fields correctly',
                          //     snackPosition: SnackPosition.BOTTOM,
                          //     backgroundColor: Colors.black87,
                          //     colorText: Colors.white,
                          //   );
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.calculate, size: 20),
                        label: const Text(
                          'Calculate',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // --- RESET BUTTON ---
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // also reset any error states in the form
                          _formKey.currentState?.reset();
                            controller.resetAll();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.blue,
                        ),
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text(
                          'Reset',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Obx(() => controller.hasCalculated.value ? _buildResultCard(controller) : SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(EMIController controller) {
    // helper validators that read controller.isEMIInputSelected.value
    String? amountValidator(String? value) {
      if (value == null || value.trim().isEmpty) return 'Amount is required';
      final parsed = double.tryParse(value.replaceAll(',', ''));
      if (parsed == null || parsed <= 0) return 'Enter a valid amount';
      return null;
    }

    String? interestValidator(String? value) {
      if (value == null || value.trim().isEmpty) return 'Interest is required';
      final parsed = double.tryParse(value);
      if (parsed == null || parsed <= 0) return 'Enter a valid interest rate';
      return null;
    }

    String? periodValidator(String? value) {
      // required only when Period mode is selected
      if (controller.isEMIInputSelected.value) {
        if (value == null || value.trim().isEmpty) return 'Period (years) is required';
        final parsed = double.tryParse(value);
        if (parsed == null || parsed <= 0) return 'Enter a valid number of years';
      }
      return null;
    }

    String? emiValidator(String? value) {
      // required only when EMI mode is selected
      if (!controller.isEMIInputSelected.value) {
        if (value == null || value.trim().isEmpty) return 'EMI is required';
        final parsed = double.tryParse(value);
        if (parsed == null || parsed <= 0) return 'Enter a valid EMI amount';
      }
      return null;
    }

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AMOUNT
          Row(
            children: [
              Text('Amount ', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 27),
              Expanded(
                child: TextFormField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    SingleDotInputFormatter(),
                  ],
                  cursorColor: Colors.blue,
                  validator: amountValidator,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1.2, color: Colors.blue),
                    ),
                    hintText: 'Enter amount',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // INTEREST
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interest', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(' (%)', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(width: 29),
              Expanded(
                child: TextFormField(
                  controller: controller.interestController,
                  keyboardType: TextInputType.number,
                  validator: interestValidator,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    SingleDotInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1.2, color: Colors.blue),
                    ),
                    hintText: 'Enter Interest',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Radio selection (Period or EMI). When user taps, we must revalidate the form so validators change.
          Obx(() => Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    controller.isEMIInputSelected.value = true;
                    // revalidate to update validators
                    _formKey.currentState?.validate();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    decoration: BoxDecoration(
                      color: controller.isEMIInputSelected.value ? Colors.grey.shade200 : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Radio<bool>(
                          activeColor: Colors.blue,
                          value: true,
                          groupValue: controller.isEMIInputSelected.value,
                          onChanged: (v) {
                            controller.isEMIInputSelected.value = true;
                            _formKey.currentState?.validate();
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('(Years)', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    controller.isEMIInputSelected.value = false;
                    _formKey.currentState?.validate();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    decoration: BoxDecoration(
                      color: !controller.isEMIInputSelected.value ? Colors.grey.shade200 : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Radio<bool>(
                          activeColor: Colors.blue,
                          value: false,
                          groupValue: controller.isEMIInputSelected.value,
                          onChanged: (v) {
                            controller.isEMIInputSelected.value = false;
                            _formKey.currentState?.validate();
                          },
                        ),
                        Text('EMI'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),

          SizedBox(height: 12),

          // PERIOD input (required only if Period selected)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('(Years)', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(width: 31),
              Expanded(
                child: Obx(() => TextFormField(
                  controller: controller.periodController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    SingleDotInputFormatter(),
                  ],
                  enabled: controller.isEMIInputSelected.value,
                  validator: (_) => periodValidator(controller.periodController.text),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1.2, color: Colors.blue),
                    ),
                    hintText: 'Enter years',
                    filled: !controller.isEMIInputSelected.value ? true : false,
                    fillColor: !controller.isEMIInputSelected.value ? Colors.grey.shade200 : Colors.white,
                  ),
                )),
              ),
            ],
          ),

          SizedBox(height: 12),

          // EMI input (required only if EMI selected)
          Row(
            children: [
              Text('EMI (₹)', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 29),
              Expanded(
                child: Obx(() => TextFormField(
                  controller: controller.emiController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    SingleDotInputFormatter(),
                  ],
                  enabled: !controller.isEMIInputSelected.value,
                  validator: (_) => emiValidator(controller.emiController.text),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1.2, color: Colors.blue),
                    ),
                    hintText: 'Enter EMI',
                    filled: controller.isEMIInputSelected.value ? true : false,
                    fillColor: controller.isEMIInputSelected.value ? Colors.grey.shade200 : Colors.white,
                  ),
                )),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Processing Fee
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Processing', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(' Fees (%)', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(width: 5),
              Expanded(
                child: TextFormField(
                  controller: controller.processingFeeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    SingleDotInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(width: 1.2, color: Colors.blue),
                    ),
                    hintText: 'Enter Processing Fees',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // _buildResultCard(...) stays unchanged; use your existing method.
  Widget _buildResultCard(EMIController controller) {
    // copy your existing implementation
    controller.calculateEMI();
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    double denomForTotal = controller.totalPayment.value == 0 ? 1 : controller.totalPayment.value;
    double loanPercentage = (controller.amount.value / denomForTotal) * 100;
    double interestPercentage = (controller.totalInterest.value / denomForTotal) * 100;

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          Table(
            columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[50]),
                children: [
                  Padding(padding: EdgeInsets.all(12), child: Text('Monthly EMI', style: TextStyle(fontWeight: FontWeight.w500))),
                  Padding(padding: EdgeInsets.all(12), child: Text(currencyFmt.format(controller.monthlyEMI.value), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.white),
                children: [
                  Padding(padding: EdgeInsets.all(12), child: Text('Total Interest', style: TextStyle(fontWeight: FontWeight.w500))),
                  Padding(padding: EdgeInsets.all(12), child: Text(currencyFmt.format(controller.totalInterest.value), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[50]),
                children: [
                  Padding(padding: EdgeInsets.all(12), child: Text('Total Payment', style: TextStyle(fontWeight: FontWeight.w500))),
                  Padding(padding: EdgeInsets.all(12), child: Text(currencyFmt.format(controller.totalPayment.value), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),

          SizedBox(height: 16),

          Center(
            child: SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: loanPercentage, color: Colors.orange, radius: 60, title: '${loanPercentage.toStringAsFixed(1)}%', titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(value: interestPercentage, color: Colors.teal, radius: 60, title: '${interestPercentage.toStringAsFixed(1)}%', titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 28,
                ),
              ),
            ),
          ),

          SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Legend(color: Colors.orange, label: 'Loan Amount'), SizedBox(width: 12), Legend(color: Colors.teal, label: 'Total Interest')]),
          SizedBox(height: 12),

          OutlinedButton(
            onPressed: () => Get.toNamed('/emi-details'),
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.blue), padding: EdgeInsets.symmetric(vertical: 12)),
            child: Text('VIEW FULL DETAILS', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String label;
  const Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.black87)), // changed to visible color
      ],
    );
  }
}

class SingleDotInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Allow only one dot
    if (newValue.text.split('.').length > 2) {
      return oldValue; // reject if more than one dot
    }
    return newValue;
  }
}