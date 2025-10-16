import 'package:emi_calculator/screens/widget/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard',style: TextStyle(fontWeight: FontWeight.bold),),
        //elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon:  Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'EMI Calculators',
                [
                  _buildCard('EMI\nCalculator', Icons.calculate, Colors.blue, '/emi-calculator'),
                  _buildCard('Quick\nCalculator', Icons.flash_on, Colors.orange, '/quick-calculator'),
                  // _buildCard('Advance\nEMI', Icons.analytics, Colors.green, '/emi-calculator'),
                  // _buildCard('Compare\nLoans', Icons.compare_arrows, Colors.purple, '/compare-loans'),
                ],
              ),
              const SizedBox(height: 24),
              // _buildSection(
              //   'Loan',
              //   [
              //     _buildCard('Loan Profile', Icons.account_balance_wallet, Colors.cyan, '/emi-calculator'),
              //     _buildCard('PrePayment/\nROI Change', Icons.change_circle, Colors.purple, '/emi-calculator'),
              //     _buildCard('Check\nEligibility', Icons.percent, Colors.pink, '/emi-calculator'),
              //     _buildCard('Moratorium\nCalculator', Icons.calculate_outlined, Colors.indigo, '/emi-calculator'),
              //   ],
              // ),
              // const SizedBox(height: 16),
              //
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // ✅ Wrap the GridView in a LayoutBuilder
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9, // adjust height ratio
                children: children,
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildCard(String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        // margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 70),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}