import 'dart:convert';
import 'dart:io';  // Dosya işlemleri için
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';  // Kamera için
import 'package:video_player/video_player.dart';  // Video önizleme için

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  XFile? _selectedImage;
  XFile? _selectedVideo;
  VideoPlayerController? _videoController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = image;

        // Not: video seçimini kaldırma, ikisi de olabilir
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf başarıyla çekildi!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf çekilmedi.')),
      );
    }
  }
  Future<void> _pickVideoFromCamera() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      _videoController?.dispose(); // eski videoyu temizle
      _videoController = VideoPlayerController.file(File(video.path));
      await _videoController!.initialize();
      setState(() {
        _selectedVideo = video;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video başarıyla kaydedildi!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video kaydedilmedi.')),
      );
    }
  }



  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null && _selectedVideo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir fotoğraf veya video seçin!')),
        );
        return;
      }

      final url = Uri.parse('http://100.119.177.30/notepad/add_note.php');

      try {
        var request = http.MultipartRequest('POST', url);

        request.fields['title'] = _titleController.text.trim();
        request.fields['content'] = _contentController.text.trim();

        if (_selectedImage != null) {
          var pic = await http.MultipartFile.fromPath('image', _selectedImage!.path);
          request.files.add(pic);
        }

        if (_selectedVideo != null) {
          var vid = await http.MultipartFile.fromPath('video', _selectedVideo!.path);
          request.files.add(vid);
        }

        var response = await request.send();
        var respStr = await response.stream.bytesToString();
        var data = jsonDecode(respStr);

        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note saved successfully! 🎉')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save note: ${data['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      }
    }
  }

  List<Widget> _buildMediaPreviews() {
    List<Widget> widgets = [];

    if (_selectedImage != null) {
      widgets.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(_selectedImage!.path),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    if (_selectedVideo != null && _videoController != null && _videoController!.value.isInitialized) {
      widgets.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));

      widgets.add(
        IconButton(
          icon: Icon(
            _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
            });
          },
        ),
      );
    }

    if (widgets.isEmpty) {
      widgets.add(const SizedBox.shrink());
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add New Note',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: const TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.white38),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              prefixIcon: const Icon(Icons.title, color: Colors.white70),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _contentController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 8,
                            decoration: InputDecoration(
                              labelText: 'Content',
                              labelStyle: const TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.white38),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              alignLabelWithHint: true,
                              prefixIcon: const Icon(Icons.notes, color: Colors.white70),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter some content';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          ..._buildMediaPreviews(),

                          ElevatedButton.icon(
                            onPressed: _pickImageFromCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: _pickVideoFromCamera,
                            icon: const Icon(Icons.videocam),
                            label: const Text('Record Video'),
                          ),


                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _saveNote,
                            child: const Text('Save Note'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
