import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/quick_calculator_controller.dart';

class QuickCalculatorDetailsScreen extends StatelessWidget {
  const QuickCalculatorDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuickCalculatorController controller =Get.isRegistered<QuickCalculatorController>()
        ? Get.find<QuickCalculatorController>()
        : Get.put(QuickCalculatorController());

    return Scaffold(
      appBar: AppBar(
        title:  Text('Calculation Details',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: 'Summary'),
                  Tab(text: 'Schedule'),
                  Tab(text: 'Charts'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSummaryTab(controller),
                  _buildScheduleTab(controller),
                  _buildChartsTab(controller),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomBar(controller),
    );
  }

  Widget _buildSummaryTab(QuickCalculatorController controller) {
    return SingleChildScrollView(
      child: Obx(() {
        final summary = controller.getLoanSummary();
        return Column(
          children: [
            // Loan Overview Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Monthly EMI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Per Month',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Details Table
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  _buildDetailRow('Loan Amount', '₹${NumberFormat('#,##,##0').format(controller.amount.value)}', true),
                  _buildDetailRow('Interest Rate', '${controller.interestRate.value.toStringAsFixed(2)}% p.a.', false),
                  _buildDetailRow('Loan Period', '${controller.periodYears.value} Years (${controller.periodMonths.value} Months)', true),
                  _buildDetailRow('Monthly EMI', '₹${NumberFormat('#,##,##0').format(controller.monthlyEMI.value)}', false, isHighlight: true),
                  _buildDetailRow('Total Interest', '₹${NumberFormat('#,##,##0').format(controller.totalInterest.value)}', true, valueColor: Colors.orange),
                  _buildDetailRow('Total Payment', '₹${NumberFormat('#,##,##0').format(controller.totalPayment.value)}', false, valueColor: Colors.green),
                ],
              ),
            ),

            // Breakdown Cards
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildBreakdownCard(
                      'Principal',
                      controller.amount.value,
                      summary['loanPercentage'],
                      Colors.blue,
                      Icons.account_balance,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBreakdownCard(
                      'Interest',
                      controller.totalInterest.value,
                      summary['interestPercentage'],
                      Colors.orange,
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInfoCard(controller),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isEven, {bool isHighlight = false, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[50] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isHighlight ? Colors.blue : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(String label, double value, double percentage, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##,##0').format(value)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(QuickCalculatorController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Loan Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('Total payable amount is ${((controller.totalPayment.value / controller.amount.value) * 100).toStringAsFixed(1)}% of loan amount'),
          _buildInfoItem('You will pay ₹${NumberFormat('#,##,##0').format(controller.totalInterest.value)} as interest'),
          _buildInfoItem('Average monthly interest: ₹${NumberFormat('#,##,##0').format(controller.totalInterest.value / controller.periodMonths.value)}'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(QuickCalculatorController controller) {
    return Obx(() {
      final schedule = controller.getAmortizationSchedule();
      final yearWiseSummary = controller.getYearWiseSummary();

      return SingleChildScrollView(
        child: Column(
          children: [
            // Year-wise Summary
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Year-wise Payment Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: yearWiseSummary.length,
              itemBuilder: (context, index) {
                final year = yearWiseSummary[index];
                return _buildYearCard(year);
              },
            ),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Divider(),
            ),

            // Monthly Schedule
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Month-wise Payment Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Expanded(child: Text('Month', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(child: Text('Principal', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(child: Text('Interest', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(child: Text('Balance', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: schedule.length > 12 ? 12 : schedule.length,
                    itemBuilder: (context, index) {
                      final month = schedule[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text('${month['month']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                            Expanded(child: Text(NumberFormat('#,##0').format(month['principal']), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                            Expanded(child: Text(NumberFormat('#,##0').format(month['interest']), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                            Expanded(child: Text(NumberFormat('#,##0').format(month['balance']), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                          ],
                        ),
                      );
                    },
                  ),
                  if (schedule.length > 12)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextButton(
                        onPressed: () {
                          Get.dialog(
                            _buildFullScheduleDialog(schedule),
                          );
                        },
                        child: const Text('View All Months'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildYearCard(Map<String, dynamic> year) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
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
                'Year ${year['year']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${NumberFormat('#,##,##0').format(year['totalPayment'])}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildYearDetailItem('Principal', year['principal'], Colors.green),
              ),
              Expanded(
                child: _buildYearDetailItem('Interest', year['interest'], Colors.orange),
              ),
              Expanded(
                child: _buildYearDetailItem('Balance', year['balance'], Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearDetailItem(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${NumberFormat('#,##,##0').format(value)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFullScheduleDialog(List<Map<String, dynamic>> schedule) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(Get.context!).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Complete Schedule',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.grey[300]!),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.blue),
                      children: [
                        _buildTableHeader('Month'),
                        _buildTableHeader('Principal'),
                        _buildTableHeader('Interest'),
                        _buildTableHeader('Balance'),
                      ],
                    ),
                    ...schedule.map((month) => TableRow(
                      decoration: BoxDecoration(
                        color: month['month'] % 2 == 0 ? Colors.grey[50] : Colors.white,
                      ),
                      children: [
                        _buildTableCell('${month['month']}'),
                        _buildTableCell(NumberFormat('#,##0').format(month['principal'])),
                        _buildTableCell(NumberFormat('#,##0').format(month['interest'])),
                        _buildTableCell(NumberFormat('#,##0').format(month['balance'])),
                      ],
                    )).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _buildChartsTab(QuickCalculatorController controller) {
    return Obx(() {
      final schedule = controller.getAmortizationSchedule();
      final yearWiseSummary = controller.getYearWiseSummary();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pie Chart - Principal vs Interest
            const Text(
              'Payment Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPieChartCard(controller),

            const SizedBox(height: 30),

            // Line Chart - Principal vs Interest over time
            const Text(
              'Payment Breakdown Over Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildLineChartCard(yearWiseSummary),

            const SizedBox(height: 30),

            // Bar Chart - Year-wise comparison
            const Text(
              'Year-wise Payment Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildBarChartCard(yearWiseSummary),
          ],
        ),
      );
    });
  }

  Widget _buildPieChartCard(QuickCalculatorController controller) {
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
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: loanPercentage,
                    color: Colors.blue,
                    title: '${loanPercentage.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  PieChartSectionData(
                    value: interestPercentage,
                    color: Colors.orange,
                    title: '${interestPercentage.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
                sectionsSpace: 3,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChartLegend(Colors.blue, 'Principal', controller.amount.value),
              _buildChartLegend(Colors.orange, 'Interest', controller.totalInterest.value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label, double value) {
    return Column(
      children: [
        Row(
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₹${NumberFormat('#,##,##0').format(value)}',
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChartCard(List<Map<String, dynamic>> yearWiseSummary) {
    if (yearWiseSummary.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Container(
      height: 300,
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
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 50000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'Y${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
          lineBarsData: [
            LineChartBarData(
              spots: yearWiseSummary.asMap().entries.map((e) {
                return FlSpot(e.value['year'].toDouble(), e.value['principal'].toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: yearWiseSummary.asMap().entries.map((e) {
                return FlSpot(e.value['year'].toDouble(), e.value['interest'].toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(List<Map<String, dynamic>> yearWiseSummary) {
    if (yearWiseSummary.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Container(
      height: 300,
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
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: yearWiseSummary.map((e) => e['totalPayment'] as double).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'Y${value.toInt() + 1}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
          barGroups: yearWiseSummary.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value['principal'],
                  color: Colors.blue,
                  width: 12,
                ),
                BarChartRodData(
                  toY: e.value['interest'],
                  color: Colors.orange,
                  width: 12,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomBar(QuickCalculatorController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                controller.reset();
                Get.back();
              },
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text('New Calculation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
