import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  
  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token != null) {
      _apiService.setToken(token);
      isLoggedIn.value = true;
      // You might want to fetch user data here
    }
  }

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    
    try {
      final response = await _apiService.login(username, password);
      
      if (response.success && response.data != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data!['token']);
        
        _apiService.setToken(response.data!['token']);
        currentUser.value = User.fromJson(response.data!['user']);
        isLoggedIn.value = true;
        
        Get.snackbar('Success', 'Login successful');
        return true;
      } else {
        Get.snackbar('Error', response.message);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String name, String email, String username, String password) async {
    isLoading.value = true;
    
    try {
      final response = await _apiService.register(name, email, username, password);
      
      if (response.success && response.data != null) {
        Get.snackbar('Success', 'Registration successful. Please login.');
        return true;
      } else {
        Get.snackbar('Error', response.message);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    
    isLoggedIn.value = false;
    currentUser.value = null;
    _apiService.setToken('');
    
    Get.snackbar('Success', 'Logged out successfully');
  }
}