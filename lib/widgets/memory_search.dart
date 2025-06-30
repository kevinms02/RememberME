import 'package:flutter/material.dart';
import '../controllers/memory_controller.dart';
import '../models/memory.dart';
import '../views/memories/full_card_screen.dart';
import 'memory_card.dart';

class MemorySearch extends SearchDelegate<Memory?> {
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
    final results = memoryController.memories.where((memory) {
      return memory.title.toLowerCase().contains(query.toLowerCase()) ||
             memory.notes.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: results.map((memory) {
              return MemoryCard(
                memory: memory,
                onTap: () {
                  close(context, memory);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullCardScreen(memory: memory),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text(
          'Search memories by title or notes',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return buildResults(context);
  }
}
