import 'package:emi_calculator/controllers/emi_controller.dart';
import 'package:emi_calculator/screens/emi/widgets/custom_tab_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EMIDetailsScreen extends StatelessWidget {
   EMIDetailsScreen({Key? key}) : super(key: key);

    final EMIController controller = Get.isRegistered<EMIController>()
        ? Get.find<EMIController>()
        : Get.put(EMIController());
  @override
  Widget build(BuildContext context) {


    // ensure latest values
    // controller.calculateEMI();
    return Scaffold(
      appBar: AppBar(
        title:  Text('EMI Details',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
           SizedBox(height: 8),

          // 🔹 Custom Tab Header (Clickable)
          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: CustomTabButton(
                    label: 'Details',
                    isSelected: controller.tabIndex.value == 0,
                    onTap: () => controller.switchTab(0),
                  ),
                ),
                Expanded(
                  child: CustomTabButton(
                    label: 'Chart',
                    isSelected: controller.tabIndex.value == 1,
                    onTap: () => controller.switchTab(1),
                  ),
                ),
              ],
            );
          }),

          // 🔹 Tab content
          Expanded(
            child: Obx(() {
              if (controller.tabIndex.value == 0) {
                return buildDetailsTab(controller);
              } else {
                return _buildChartTab(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget buildDetailsTab(EMIController controller) {
    final schedule = controller.getAmortizationSchedule();
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary table
          Padding(
            padding: const EdgeInsets.all(16),
            child: Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('Amount', NumberFormat.currency(symbol: '', decimalDigits: 0).format(controller.amount.value), true),
                _buildTableRow('Interest %', controller.interestRate.value.toStringAsFixed(2), false),
                _buildTableRow('Period (Years)', controller.periodYears.value.toString(), true),
                _buildTableRow('Monthly EMI', NumberFormat.currency(symbol: '', decimalDigits: 2).format(controller.monthlyEMI.value), false),
                _buildTableRow('Total Interest', NumberFormat.currency(symbol: '', decimalDigits: 2).format(controller.totalInterest.value), true),
                _buildTableRow('Processing Fees', controller.processingFee.value.toStringAsFixed(2), false),
                _buildTableRow('Total Payment', NumberFormat.currency(symbol: '', decimalDigits: 2).format(controller.totalPayment.value), true),
              ],
            ),
          ),

          // Amortization header
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: const [
                Expanded(child: Text('Month', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Principal', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Interest', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Balance', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          // Full amortization list (all months)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final item = schedule[index];
              final bg = index % 2 == 0 ? Colors.grey[100] : Colors.white;
              return Container(
                color: bg,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(item['month'].toString(), textAlign: TextAlign.center)),
                    Expanded(child: Text(currency.format(item['principal']), textAlign: TextAlign.center)),
                    Expanded(child: Text(currency.format(item['interest']), textAlign: TextAlign.center)),
                    Expanded(child: Text(NumberFormat.currency(symbol: '', decimalDigits: 2).format(item['balance']), textAlign: TextAlign.center)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, bool isShaded) {
    return TableRow(
      decoration: BoxDecoration(
        color: isShaded ? Colors.white : Colors.grey[50],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildChartTab(EMIController controller) {
    final schedule = controller.getAmortizationSchedule();

    // choose how many months to show on chart (e.g., first 12 months or full if less)
    final int showMonths = min(12, schedule.length);
    final displayList = schedule.take(showMonths).toList();

    // prepare grouped bars: two bars per group (principal, interest)
    final groups = <BarChartGroupData>[];
    double maxY = 0;
    for (int i = 0; i < displayList.length; i++) {
      final principal = (displayList[i]['principal'] as double).abs();
      final interest = (displayList[i]['interest'] as double).abs();

      maxY = max(maxY, max(principal, interest));

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            // Principal bar (blue)
            BarChartRodData(
              toY: principal,
              width: 6,
              borderRadius: BorderRadius.circular(0),
              color: Colors.blue, // set bar color explicitly
            ),
            // Interest bar (orange)
            BarChartRodData(
              toY: interest,
              width: 6,
              borderRadius: BorderRadius.circular(0),
              color: Colors.orange, // set bar color explicitly
            ),
          ],
          barsSpace: 6,
        ),
      );
    }

    if (maxY <= 0) maxY = 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _ChartLegend(color: Colors.blue, label: 'Principal'),
              SizedBox(width: 16),
              _ChartLegend(color: Colors.orange, label: 'Interest'),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 320,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barGroups: groups,
                groupsSpace: 12,
                barTouchData: BarTouchData(
                  enabled: true,
                  // Show tooltip as before
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey.shade700,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0 ? 'Principal' : 'Interest';
                      return BarTooltipItem(
                        '$label\n${NumberFormat.currency(symbol: '', decimalDigits: 2).format(rod.toY)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                  // Handle tap -> navigate
                  touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                    // Only respond to tap up events and ensure we have a response
                    if (event is FlTapUpEvent && response != null && response.spot != null) {
                      final touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                      final selectedMonth = displayList[touchedGroupIndex]['month'] as int;

                      // Navigate to details screen and pass the selectedMonth
                      Get.to(() => EMIDetailsScreen(), arguments: {'selectedMonth': selectedMonth});
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: (maxY * 1.2) / 5, reservedSize: 50),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= displayList.length) return const SizedBox.shrink();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text('${displayList[idx]['month']}', style: const TextStyle(fontSize: 12)),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
            ),
          ),
          Text('Tap a bar to open details for that month', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
