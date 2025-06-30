import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/memory_controller.dart';
import '../../utils/snackbar_helper.dart';

class CreateMemoryScreen extends StatelessWidget {
  final String? existingNfcUrl;
  final MemoryController memoryController = Get.find<MemoryController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<File> selectedMedia = <File>[].obs;

  CreateMemoryScreen({Key? key, this.existingNfcUrl}) : super(key: key);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        if (selectedMedia.length >= 3) {
          SnackbarHelper.showError(
            'Maximum Limit',
            'You can only add up to 3 photos',
          );
          return;
        }
        selectedMedia.add(File(pickedFile.path));
      }
    } catch (e) {
      SnackbarHelper.showError('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> _saveMemory() async {
    if (titleController.text.isEmpty) {
      SnackbarHelper.showError('Error', 'Please enter a title');
      return;
    }
    if (selectedMedia.isEmpty) {
      SnackbarHelper.showError('Error', 'Please add at least one photo');
      return;
    }
    try {
      await memoryController.createMemory(
        title: titleController.text,
        notes: notesController.text,
        date: selectedDate.value,
        mediaFiles: selectedMedia,
        nfcUrl: existingNfcUrl,
      );
      Get.back();
      SnackbarHelper.showSuccess('Success', 'Memory created successfully');
    } catch (e) {
      SnackbarHelper.showError('Error', 'Failed to create memory: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Memory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveMemory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter memory title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedMedia.length < 3 ? selectedMedia.length + 1 : 3,
                itemBuilder: (context, index) {
                  if (index == selectedMedia.length) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_photo_alternate),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_camera),
                                  title: const Text('Take Photo'),
                                  onTap: () {
                                    Get.back();
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from Gallery'),
                                  onTap: () {
                                    Get.back();
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(selectedMedia[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => selectedMedia.removeAt(index),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _pickDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Obx(() => Text(
                  DateFormat('MMMM dd, yyyy').format(selectedDate.value),
                )),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter memory details',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
