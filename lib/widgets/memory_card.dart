import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({
    Key? key,
    required this.memory,
    required this.onTap,
  }) : super(key: key);

  final Memory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memory.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat.yMMMd().format(memory.date),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              if (memory.media.isNotEmpty)
                Image.network(
                  memory.media.first,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 8),
              Text(
                memory.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
