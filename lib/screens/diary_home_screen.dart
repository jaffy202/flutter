import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diary_entry.dart';
import '../services/diary_repository.dart';
import 'entry_editor_screen.dart';

class DiaryHomeScreen extends StatelessWidget {
  const DiaryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DiaryRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<DiaryEntry>>(
        stream: repo.watchEntries(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data!;
          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'No entries yet.\nTap + to write your first thought.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final date = entry.createdAt;
              final dateText = date != null
                  ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                  : 'Just now';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Text(entry.mood, style: const TextStyle(fontSize: 28)),
                  title: Text(
                    entry.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        entry.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: entry.tags
                              .map((tag) => Chip(
                                    label: Text('#$tag'),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        dateText,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          entry.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: entry.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () =>
                            repo.toggleFavorite(entry.id, entry.isFavorite),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => repo.deleteEntry(entry.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EntryEditorScreen(existingEntry: entry),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EntryEditorScreen()),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Write'),
      ),
    );
  }
}
