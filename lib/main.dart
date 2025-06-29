import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/auth/login_screen.dart';
import 'views/main_navigation.dart';
import 'utils/theme.dart';
import 'controllers/auth_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    
    return GetMaterialApp(
      title: 'RememberME',
      theme: AppTheme.lightTheme,
      home: Obx(() {
        final authController = Get.find<AuthController>();
        return authController.isLoggedIn.value ? const MainNavigation() : LoginScreen();
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}
