import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/memory_controller.dart';
import '../../models/memory.dart';

class FullCardScreen extends StatelessWidget {
  final Memory memory;
  final bool fromNfc;

  const FullCardScreen({
    Key? key,
    required this.memory,
    this.fromNfc = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MemoryController memoryController = Get.find<MemoryController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(memory.title),
        actions: fromNfc
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to edit screen
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    memoryController.deleteMemory(memory.id);
                    Get.back();
                  },
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              memory.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Date: ${memory.date}',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            // Display media (images/videos)
            // This is a placeholder, you'll need to implement a proper media viewer
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: memory.media.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(memory.media[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              memory.notes,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: fromNfc ? null : null, // Placeholder for bottom navigation
    );
  }
}
