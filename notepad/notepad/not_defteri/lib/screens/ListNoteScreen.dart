import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:not_defteri/screens/VideoPlayerExample.dart';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ListNoteScreen(),
  ));
}

class ListNoteScreen extends StatefulWidget {
  const ListNoteScreen({Key? key}) : super(key: key);

  @override
  State<ListNoteScreen> createState() => _ListNoteScreenState();
}

class _ListNoteScreenState extends State<ListNoteScreen> {
  List<Map<String, dynamic>> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final url = Uri.parse('http://100.119.177.30/notepad/get_notes.php');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notes = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception('Sunucudan veri alınamadı');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Widget _buildMediaWidgets(Map note) {
    String? imagePath = note['image_path'];
    String? videoPath = note['video_path'];

    String buildUrl(String path) {
      if (path.startsWith('http')) return path;
      if (path.startsWith('/')) path = path.substring(1);
      return 'http://100.119.177.30/notepad/$path';
    }

    List<Widget> widgets = [];

    if (imagePath != null && imagePath.isNotEmpty) {
      widgets.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            buildUrl(imagePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes!)
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                height: 200,
                child: Center(
                  child:
                  Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                ),
              );
            },
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }

    if (videoPath != null && videoPath.isNotEmpty) {
      widgets.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: VideoPlayerExample(videoUrl: buildUrl(videoPath)),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }

    if (widgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text('Notes List'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Stack(
            children: [
              Container(
                width: double.infinity, // yatayda tam ekran
                margin: const EdgeInsets.only(bottom: 20),
                constraints: const BoxConstraints(
                  minHeight: 220, // tüm kartlar aynı yükseklikte minimum
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 2)
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note['content'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMediaWidgets(note),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        print('Düzenle: ${note['id']}');
                      },
                    ),
                    IconButton(
                      icon:
                      const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        print('Sil: ${note['id']}');
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
