import 'package:flutter/material.dart';
import '../db/note_database.dart';
import '../models/note.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;

  @override
  void initState() {
    super.initState();
    _title = widget.note?.title ?? '';
    _content = widget.note?.content ?? '';
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id,
        title: _title,
        content: _content,
        createdTime: widget.note?.createdTime ?? now,
      );

      if (widget.note == null) {
        await NoteDatabase.instance.create(note);
      } else {
        await NoteDatabase.instance.update(note);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Yeni Not' : 'Notu Düzenle'),
        backgroundColor: Colors.green[800], // Modern yeşil
        elevation: 6.0, // Yumuşak gölge
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  labelStyle: TextStyle(color: Colors.green[800]), // Başlık rengi
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[800]!, width: 2),
                  ),
                ),
                onSaved: (value) => _title = value!,
                validator: (value) => value == null || value.isEmpty
                    ? 'Başlık boş olamaz'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _content,
                decoration: InputDecoration(
                  labelText: 'İçerik',
                  labelStyle: TextStyle(color: Colors.green[800]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[800]!, width: 2),
                  ),
                ),
                onSaved: (value) => _content = value!,
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? 'İçerik boş olamaz'
                    : null,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800], // Buton rengi
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Buton üzerindeki yazı rengi
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5.0, // Butona gölge efekti
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
