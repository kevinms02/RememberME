import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/memory_controller.dart';
import '../../widgets/memory_card.dart';
import 'full_card_screen.dart';

class MemorySearch extends SearchDelegate {
  final MemoryController memoryController;

  MemorySearch(this.memoryController);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = memoryController.memories
        .where((memory) => memory.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final memory = results[index];
        return MemoryCard(
          key: ValueKey(memory.id),
          memory: memory,
          onTap: () => Get.to(() => FullCardScreen(memory: memory)),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = memoryController.memories
        .where((memory) => memory.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final memory = suggestions[index];
        return ListTile(
          title: Text(memory.title),
          onTap: () {
            query = memory.title;
            showResults(context);
          },
        );
      },
    );
  }
}

class MemoriesVaultScreen extends StatelessWidget {
  final MemoryController memoryController = Get.put(MemoryController());
  final TextEditingController searchController = TextEditingController();

  MemoriesVaultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MemorySearch(memoryController),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              memoryController.sortMemories(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'title_asc',
                  child: Text('Title A-Z'),
                ),
                const PopupMenuItem(
                  value: 'title_desc',
                  child: Text('Title Z-A'),
                ),
                const PopupMenuItem(
                  value: 'date_asc',
                  child: Text('Date (Oldest)'),
                ),
                const PopupMenuItem(
                  value: 'date_desc',
                  child: Text('Date (Newest)'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(() {
        if (memoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (memoryController.memories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No memories found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 24),
                Text(
                  'Create your first memory by scanning an NFC tag',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: memoryController.memories.length,
          itemBuilder: (context, index) {
            final memory = memoryController.memories[index];
            return MemoryCard(
              key: ValueKey(memory.id),
              memory: memory,
              onTap: () => Get.to(() => FullCardScreen(memory: memory)),
            );
          },
        );
      }),
    );
  }
}
