import 'dart:io';
import 'package:get/get.dart';
import '../models/memory.dart';
import '../services/api_service.dart';
import '../services/nfc_service.dart';

class MemoryController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final NfcService _nfcService = Get.put(NfcService());
  
  var memories = <Memory>[].obs;
  var filteredMemories = <Memory>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var sortBy = 'newest'.obs; // newest, oldest, title_asc, title_desc, date_asc, date_desc
  var nfcScanResult = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadMemories();
  }

  Future<void> loadMemories() async {
    isLoading.value = true;
    
    try {
      final response = await _apiService.getMemories();
      
      if (response.success && response.data != null) {
        memories.value = response.data!;
        applyFiltersAndSort();
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load memories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchMemories(String query) {
    searchQuery.value = query;
    applyFiltersAndSort();
  }

  void sortMemories(String sortType) {
    sortBy.value = sortType;
    applyFiltersAndSort();
  }

  void applyFiltersAndSort() {
    List<Memory> filtered = memories.where((memory) {
      if (searchQuery.value.isEmpty) return true;
      return memory.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
             memory.notes.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    switch (sortBy.value) {
      case 'newest':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'title_asc':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_desc':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    filteredMemories.value = filtered;
  }

  Future<Memory?> createMemory({
    required String title,
    required String notes,
    required DateTime date,
    required List<File> mediaFiles,
    String? nfcUrl,
  }) async {
    isLoading.value = true;
    
    try {
      final tempMemory = Memory(
        id: '',
        title: title,
        notes: notes,
        date: date,
        media: [],
        url: nfcUrl,
      );
      final response = await _apiService.createMemory(tempMemory, mediaFiles, nfcUrl: nfcUrl);
      
      if (response.success && response.data != null) {
        memories.add(response.data!);
        applyFiltersAndSort();
        Get.snackbar('Success', 'Memory created successfully');
        return response.data;
      } else {
        Get.snackbar('Error', response.message);
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create memory: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> writeToNfc(String url) async {
    try {
      return await _nfcService.writeNfcTag(url);
    } catch (e) {
      Get.snackbar('Error', 'Failed to write to NFC tag: $e');
      return false;
    }
  }

  Future<String?> readFromNfc() async {
    try {
      return await _nfcService.readNfcTag();
    } catch (e) {
      Get.snackbar('Error', 'Failed to read NFC tag: $e');
      return null;
    }
  }

  Future<Memory?> getMemoryByUrl(String url) async {
    try {
      final response = await _apiService.getMemoryByUrl(url);
      
      if (response.success && response.data != null) {
        return response.data;
      } else {
        Get.snackbar('Error', response.message);
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load memory: $e');
      return null;
    }
  }

  Future<bool> deleteMemory(String memoryId) async {
    try {
      final response = await _apiService.deleteMemory(memoryId);
      
      if (response.success) {
        memories.removeWhere((memory) => memory.id == memoryId);
        applyFiltersAndSort();
        Get.snackbar('Success', 'Memory deleted successfully');
        return true;
      } else {
        Get.snackbar('Error', response.message);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete memory: $e');
      return false;
    }
  }
}
