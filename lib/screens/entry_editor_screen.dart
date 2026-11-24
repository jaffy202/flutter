import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/diary_repository.dart';

class EntryEditorScreen extends StatefulWidget {
  final DiaryEntry? existingEntry;
  const EntryEditorScreen({super.key, this.existingEntry});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;
  late String _selectedMood;
  bool _isSaving = false;

  final List<String> _moods = ['😊', '😌', '😐', '😔', '😤', '🥳'];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingEntry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existingEntry?.content ?? '');
    _tagsController = TextEditingController(
      text: widget.existingEntry?.tags.join(', ') ?? '',
    );
    _selectedMood = widget.existingEntry?.mood ?? '😊';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    final parsedTags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(10)
        .toList();

    final entry = DiaryEntry(
      id: widget.existingEntry?.id ?? '',
      title: _titleController.text.trim().isEmpty
          ? 'Untitled Entry'
          : _titleController.text.trim(),
      content: _contentController.text.trim(),
      mood: _selectedMood,
      tags: parsedTags,
      isFavorite: widget.existingEntry?.isFavorite ?? false,
    );

    try {
      if (widget.existingEntry == null) {
        await DiaryRepository().addEntry(entry);
      } else {
        await DiaryRepository().updateEntry(entry);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _moods.map((mood) {
                return ChoiceChip(
                  label: Text(mood, style: const TextStyle(fontSize: 20)),
                  selected: _selectedMood == mood,
                  onSelected: (_) => setState(() => _selectedMood = mood),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Entry title...',
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                hintText: 'Tags (comma separated, e.g. work, gratitude)',
                prefixIcon: Icon(Icons.tag, size: 18),
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write what happened today...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
