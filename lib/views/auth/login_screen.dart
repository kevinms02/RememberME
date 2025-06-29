import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/constants.dart';
import '../main_navigation.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Title
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Text(
                      'RememberME',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Login Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: usernameController,
                      labelText: 'Username',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      labelText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    Obx(() => CustomButton(
                      text: 'Login',
                      onPressed: authController.isLoading.value
                          ? null
                          : () async {
                              if (usernameController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty) {
                                bool success = await authController.login(
                                  usernameController.text,
                                  passwordController.text,
                                );
                                if (success) {
                                  Get.offAll(() => const MainNavigation());
                                }
                              } else {
                                Get.snackbar('Error', 'Please fill all fields');
                              }
                            },
                      isLoading: authController.isLoading.value,
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => SignupScreen());
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
