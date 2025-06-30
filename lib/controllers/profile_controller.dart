import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var profileImage = Rxn<File>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;

  @override
  void onInit() {
    super.onInit();
    final user = _authController.currentUser.value;
    nameController = TextEditingController(text: user?.name);
    emailController = TextEditingController(text: user?.email);
    usernameController = TextEditingController(text: user?.username);
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    final user = User(
      id: _authController.currentUser.value!.id,
      name: nameController.text,
      email: emailController.text,
      username: usernameController.text,
      profilePicture: _authController.currentUser.value!.profilePicture,
    );

    final response = await _apiService.updateProfile(user, profileImage.value);
    if (response.success) {
      _authController.currentUser.value = response.data;
      Get.snackbar('Success', 'Profile updated successfully');
    } else {
      Get.snackbar('Error', response.message);
    }
    isLoading.value = false;
  }
}
