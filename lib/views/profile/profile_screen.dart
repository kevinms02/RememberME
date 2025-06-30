import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    profileController.pickImage();
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profileController.profileImage.value != null
                        ? FileImage(profileController.profileImage.value!)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: profileController.nameController,
                  labelText: 'Name',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: profileController.emailController,
                  labelText: 'Email',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: profileController.usernameController,
                  labelText: 'Username',
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Update Profile',
                  onPressed: () {
                    profileController.updateProfile();
                  },
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
