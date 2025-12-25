import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/services_models.dart';
import '../../../data/repos/services_repository.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final ServicesRepository _repository;
  List<UserNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = ServicesRepositoryImpl(Supabase.instance.client);
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _repository.getNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNote(
      {String? id, required String title, required String body}) async {
    if (title.isEmpty || body.isEmpty) return;
    try {
      debugPrint('Attempting to save note: $title');
      if (id == null) {
        await _repository.addNote(title, body);
      } else {
        await _repository.updateNote(id, title, body);
      }
      debugPrint('Note saved successfully');
      _fetchNotes();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving note: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving note: $e')));
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      setState(() {
        _notes.removeWhere((n) => n.id == id);
      });
      if (mounted) Navigator.pop(context); // Close detail view if open
    } catch (e) {
      // Handle error
    }
  }

  void _openNoteEditor([UserNote? note]) {
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final contentCtrl = TextEditingController(text: note?.body ?? '');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(note == null ? 'New Note' : 'Edit Note',
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
            actions: [
              if (note != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteNote(note.id),
                ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.greenAccent),
                onPressed: () => _saveNote(
                  id: note?.id,
                  title: titleCtrl.text,
                  body: contentCtrl.text,
                ),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(color: Colors.white24),
                Expanded(
                  child: TextField(
                    controller: contentCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Write your notes here...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Notes",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(),
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent))
          : _notes.isEmpty
              ? const Center(
                  child: Text("No notes yet",
                      style: TextStyle(color: Colors.white54)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return GestureDetector(
                      onTap: () => _openNoteEditor(note),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 24.0), // Space for delete icon
                                  child: Text(
                                    note.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Cairo'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    note.body,
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                                Text(
                                  "${note.createdAt.day}/${note.createdAt.month}",
                                  style: const TextStyle(
                                      color: Colors.white30, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _deleteNote(note.id),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
