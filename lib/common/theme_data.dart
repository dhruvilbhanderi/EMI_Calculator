import 'package:emi_calculator/common/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


final ThemeData themeData = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColor.appPrimary),
  scaffoldBackgroundColor: AppColor.white,

  appBarTheme: AppBarTheme(
    color: AppColor.white,
    surfaceTintColor: AppColor.white,
  ),


  // RADIO/CHECKBOX (your existing)
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) =>
    states.contains(MaterialState.selected) ? AppColor.appPrimary : AppColor.radioGrey),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) =>
    states.contains(MaterialState.selected) ? AppColor.appPrimary : AppColor.radioGrey),
    checkColor: const MaterialStatePropertyAll(Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
);


SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.white,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: true,
);
