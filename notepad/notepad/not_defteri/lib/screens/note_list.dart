import 'package:flutter/material.dart';
import '../db/note_database.dart';
import '../models/note.dart';
import 'note_edit.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late Future<List<Note>> _noteList;
  List<Note> _allNotes = [];  // Tüm notları tutacak liste
  List<Note> _filteredNotes = [];  // Arama sonucu filtrelenmiş notlar

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final notes = await NoteDatabase.instance.readAllNotes();
    setState(() {
      _allNotes = notes;
      _filteredNotes = notes;  // Başlangıçta filtrelenmiş liste tüm notlarla eşleşiyor
    });
  }

  void _deleteNote(int id) async {
    await NoteDatabase.instance.delete(id);
    _refreshNotes();
  }

  void _navigateToEdit(Note? note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditPage(note: note),
      ),
    );
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlarım', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800], // Modern bir yeşil renk
        elevation: 6.0,
      ),
      body: _filteredNotes.isEmpty
          ? const Center(child: Text('Henüz not yok.'))
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8.0, // Gölge efekti
                  color: Colors.green[50],
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      note.title,
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(note.id!),
                    ),
                    onTap: () => _navigateToEdit(note),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(null),
        child: const Icon(Icons.add),
        backgroundColor: Colors.green[800], // Buton rengi
        elevation: 6.0, // Yumuşak gölge efekti
      ),
    );
  }
}
