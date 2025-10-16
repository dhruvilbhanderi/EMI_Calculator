import 'package:emi_calculator/common/theme_data.dart';
import 'package:emi_calculator/controllers/emi_controller.dart';
import 'package:emi_calculator/screens/compare/compare_loans_screen.dart';
import 'package:emi_calculator/screens/dashboard_screen.dart';
import 'package:emi_calculator/screens/emi/emi_calculator_screen.dart';
import 'package:emi_calculator/screens/emi/emi_details_screen.dart';
import 'package:emi_calculator/screens/emi/history_screen.dart';
import 'package:emi_calculator/screens/onboarding_screen.dart';
import 'package:emi_calculator/screens/quick/quick_calculator_details_screen.dart';
import 'package:emi_calculator/screens/quick/quick_calculator_screen.dart';
import 'package:emi_calculator/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(EMIController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EMI Calculator',
      debugShowCheckedModeBanner: false,
      /*theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          //color: Colors.white,
          elevation: 1,
        ),
        primaryColor: Colors.white,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.red,
      ),*/
      theme: themeData,
      home: SplashScreen(),
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/onboarding', page: () => OnboardingScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/emi-calculator', page: () => EMICalculatorScreen()),
        GetPage(name: '/quick-calculator', page: () => QuickCalculatorScreen()),
        GetPage(name: '/compare-loans', page: () => CompareLoansScreen()),
        GetPage(name: '/emidetails', page: () => EMIDetailsScreen()),
        GetPage(name: '/history', page: () => HistoryScreen()),
        GetPage(name: '/quick-calculator-details', page: () => QuickCalculatorDetailsScreen()),
      ],
    );
  }
}
