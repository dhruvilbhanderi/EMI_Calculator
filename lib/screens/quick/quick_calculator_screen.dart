import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/quick_calculator_controller.dart';

class QuickCalculatorScreen extends StatelessWidget {
  QuickCalculatorScreen({Key? key}) : super(key: key);
  final controller = Get.isRegistered<QuickCalculatorController>()
      ? Get.find<QuickCalculatorController>()
      : Get.put(QuickCalculatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Calculator',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon:  Icon(Icons.refresh),
            onPressed: () => controller.reset(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tab Selection
            _buildTabBar(),
            const SizedBox(height: 30),

            // Result Card with Chart
            Obx(() => _buildResultCard()),
            const SizedBox(height: 30),

            // Input Controls based on active tab
            Obx(() => _buildInputControls()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() => Row(
        children: [
          _buildTab('EMI', 0),
          _buildTab('Amount', 1),
          _buildTab('Period', 2),
          _buildTab('Interest', 3),
        ],
      )),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = controller.activeTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setActiveTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final summary = controller.getLoanSummary();
    final double loanPercentage = summary['loanPercentage'];
    final double interestPercentage = summary['interestPercentage'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Interest',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${NumberFormat('#,##,##0').format(controller.totalInterest.value)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Total Payment',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${NumberFormat('#,##,##0').format(controller.totalPayment.value)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: loanPercentage,
                        color: Colors.orange,
                        title: '${loanPercentage.toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      PieChartSectionData(
                        value: interestPercentage,
                        color: Colors.teal,
                        title: '${interestPercentage.toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(Colors.orange, 'Loan Amount'),
              const SizedBox(width: 20),
              _buildLegend(Colors.teal, 'Total Interest'),
            ],
          ),
          const Divider(height: 30),
          Column(
            children: [
              Text(
                'Monthly EMI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${NumberFormat('#,##,##0.00').format(controller.monthlyEMI.value)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _numberToWords(controller.monthlyEMI.value.toInt()),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  controller.saveQuickCalculation();
                  Get.toNamed('/quick-calculator-details');
                },
                icon: const Icon(Icons.visibility),
                label:  Text('VIEW DETAILS'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 15),
                ),
              ),
              //const SizedBox(width: 12),
              // Expanded(
              //   child: ElevatedButton.icon(
              //     onPressed: () => controller.saveQuickCalculation(),
              //     icon:  Icon(Icons.save, color: Colors.white),
              //     label:  Text('SAVE',style: TextStyle(color: Colors.white),),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blue,
              //       padding: const EdgeInsets.symmetric(vertical: 12),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInputControls() {
    switch (controller.activeTab.value) {
      case 0: // Calculate EMI
        return Column(
          children: [
            _buildAmountSlider(),
            const SizedBox(height: 20),
            _buildInterestSlider(),
            const SizedBox(height: 20),
            _buildPeriodSlider(),
          ],
        );
      case 1: // Calculate Amount
        return Column(
          children: [
            _buildEMISlider(),
            const SizedBox(height: 20),
            _buildInterestSlider(),
            const SizedBox(height: 20),
            _buildPeriodSlider(),
          ],
        );
      case 2: // Calculate Period
        return Column(
          children: [
            _buildAmountSlider(),
            const SizedBox(height: 20),
            _buildEMISlider(),
            const SizedBox(height: 20),
            _buildInterestSlider(),
          ],
        );
      case 3: // Calculate Interest
        return Column(
          children: [
            _buildAmountSlider(),
            const SizedBox(height: 20),
            _buildEMISlider(),
            const SizedBox(height: 20),
            _buildPeriodSlider(),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAmountSlider() {
    return _buildSliderCard(
      title: 'Loan Amount',
      value: controller.amount.value,
      displayValue: '₹${NumberFormat('#,##,##0').format(controller.amount.value)}',
      min: 10000,
      max: 10000000,
      divisions: 1000,
      onChanged: (value) {
        controller.updateAmount(value);
      },
      color: Colors.blue,
    );
  }

  Widget _buildInterestSlider() {
    return _buildSliderCard(
      title: 'Interest Rate',
      value: controller.interestRate.value,
      displayValue: '${controller.interestRate.value.toStringAsFixed(2)}% p.a.',
      min: 1.0,
      max: 30.0,
      divisions: 290,
      onChanged: (value) {
        controller.updateInterestRate(value);
      },
      color: Colors.orange,
    );
  }

  Widget _buildPeriodSlider() {
    return _buildSliderCard(
      title: 'Loan Period',
      value: controller.periodYears.value.toDouble(),
      displayValue: '${controller.periodYears.value} Years (${controller.periodMonths.value} Months)',
      min: 1,
      max: 30,
      divisions: 29,
      onChanged: (value) {
        controller.updatePeriodYears(value);
      },
      color: Colors.green,
    );
  }

  Widget _buildEMISlider() {
    return _buildSliderCard(
      title: 'Monthly EMI',
      value: controller.monthlyEMI.value,
      displayValue: '₹${NumberFormat('#,##,##0').format(controller.monthlyEMI.value)}',
      min: 1000,
      max: 500000,
      divisions: 500,
      onChanged: (value) {
        controller.monthlyEMI.value = value;
        if (controller.activeTab.value == 1) {
          controller.calculateAmount();
        } else if (controller.activeTab.value == 2) {
          controller.calculatePeriod();
        } else if (controller.activeTab.value == 3) {
          controller.calculateInterestRate();
        }
      },
      color: Colors.purple,
    );
  }

  Widget _buildSliderCard({
    required String title,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              inactiveTrackColor: color.withOpacity(0.2),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _numberToWords(int number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)} Crore';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)} Lakh';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)} Thousand';
    }
    return number.toString();
  }
}