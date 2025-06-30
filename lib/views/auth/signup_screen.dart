import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/constants.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      labelText: 'Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: emailController,
                      labelText: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: usernameController,
                      labelText: 'Username',
                      icon: Icons.account_circle,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      labelText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    Obx(() => CustomButton(
                      text: 'Sign Up',
                      onPressed: authController.isLoading.value
                          ? null
                          : () async {
                              if (nameController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty &&
                                  usernameController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty) {
                                bool success = await authController.register(
                                  nameController.text,
                                  emailController.text,
                                  usernameController.text,
                                  passwordController.text,
                                );
                                if (success) {
                                  Get.back();
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
            ],
          ),
        ),
      ),
    );
  }
}
