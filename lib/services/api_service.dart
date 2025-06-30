import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/memory.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth endpoints
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: response.statusCode == 200,
        message: data['message'],
        data: response.statusCode == 200 ? data : null,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  Future<ApiResponse<User>> register(String name, String email, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      return ApiResponse<User>(
        success: response.statusCode == 201,
        message: data['message'],
        data: response.statusCode == 201 ? User.fromJson(data['user']) : null,
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // Memory endpoints
  Future<ApiResponse<List<Memory>>> getMemories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/memories'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<Memory> memories = (data['data'] as List)
            .map((memory) => Memory.fromJson(memory))
            .toList();
        return ApiResponse<List<Memory>>(
          success: true,
          message: '',
          data: memories,
        );
      }
      return ApiResponse<List<Memory>>(
        success: false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<List<Memory>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  Future<ApiResponse<Memory>> createMemory(Memory memory, List<File> mediaFiles, {String? nfcUrl}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/memories'));
      request.headers.addAll(_headers);
      request.fields['title'] = memory.title;
      request.fields['notes'] = memory.notes;
      request.fields['date'] = memory.date.toIso8601String();
      if (nfcUrl != null) {
        request.fields['url'] = nfcUrl;
      }
      for (int i = 0; i < mediaFiles.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          mediaFiles[i].path,
        ));
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      return ApiResponse<Memory>(
        success: response.statusCode == 201,
        message: data['message'] ?? '',
        data: response.statusCode == 201 ? Memory.fromJson(data['data']) : null,
      );
    } catch (e) {
      return ApiResponse<Memory>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  Future<ApiResponse<Memory>> getMemoryByUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/memories/url/$url'),
      );

      final data = jsonDecode(response.body);
      return ApiResponse<Memory>(
        success: response.statusCode == 200,
        message: data['message'],
        data: response.statusCode == 200 ? Memory.fromJson(data['memory']) : null,
      );
    } catch (e) {
      return ApiResponse<Memory>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  Future<ApiResponse<void>> deleteMemory(String memoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/memories/$memoryId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      return ApiResponse<void>(
        success: response.statusCode == 200,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // Profile endpoints
  Future<ApiResponse<User>> updateProfile(User user, File? profileImage) async {
    try {
      if (profileImage != null) {
        var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/profile'));
        request.headers.addAll(_headers);
        
        request.fields['name'] = user.name;
        request.fields['email'] = user.email;
        request.fields['username'] = user.username;
        
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          profileImage.path,
        ));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final data = jsonDecode(response.body);

        return ApiResponse<User>(
          success: response.statusCode == 200,
          message: data['message'],
          data: response.statusCode == 200 ? User.fromJson(data['user']) : null,
        );
      } else {
        final response = await http.put(
          Uri.parse('$baseUrl/profile'),
          headers: _headers,
          body: jsonEncode(user.toJson()),
        );

        final data = jsonDecode(response.body);
        return ApiResponse<User>(
          success: response.statusCode == 200,
          message: data['message'],
          data: response.statusCode == 200 ? User.fromJson(data['user']) : null,
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
