import 'package:emi_calculator/screens/emi/emi_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/emi_controller.dart';

class HistoryScreen extends StatelessWidget {
   HistoryScreen({Key? key}) : super(key: key);

    final EMIController controller = Get.isRegistered<EMIController>()
        ? Get.find<EMIController>()
        : Get.put(EMIController());
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        controller.resetAll();
        return true;
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete All'),
                    content: const Text('Are you sure you want to delete all calculations?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.deleteAllCalculations();
                          Get.back();
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Obx(() {
          if (controller.calculations.isEmpty) {
            return const Center(
              child: Text('No calculations yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            //shrinkWrap: true,
            //physics: NeverScrollableScrollPhysics(),
            itemCount: controller.calculations.length,
            itemBuilder: (context, index) {
              final calc = controller.calculations[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () async{
                    controller.amount.value = calc.amount;
                    controller.interestRate.value = calc.interestRate;
                    controller.periodYears.value = (calc.periodMonths / 12).round();
                    controller.calculateEMI();
                    //Get.toNamed('/emidetails');
                    Get.to(EMIDetailsScreen());

                  },
                  onLongPress: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Delete Entry'),
                        content: const Text('Do you want to delete this calculation?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.deleteCalculationAt(index);
                              Get.back();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  leading: Container(
                    width: 50,
                    padding: const EdgeInsets.all(8), // reduce padding
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // scales down to fit
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(DateFormat('MMM').format(calc.calculatedDate),
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                          Text(DateFormat('dd').format(calc.calculatedDate),
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(DateFormat('yyyy').format(calc.calculatedDate),
                              style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),

                  title: Text(
                    'Amount - ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(calc.amount)} (${calc.interestRate}%)',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text('${calc.periodMonths} Months'),
                  trailing: const Icon(Icons.chevron_right),
                  // onTap: () {
                  //   controller.amount.value = calc.amount;
                  //   controller.interestRate.value = calc.interestRate;
                  //   controller.periodYears.value = (calc.periodMonths / 12).round();
                  //   controller.calculateEMI();
                  //   Get.toNamed('/emi-details');
                  // },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}