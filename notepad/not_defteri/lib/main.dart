import 'package:flutter/material.dart';
import 'screens/note_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not Defteri',
      theme: ThemeData(
        brightness: Brightness.light,
        // Soft pastel green tones for a soothing effect
        colorScheme: ColorScheme.light(
          primary: Colors.green[800]!,   // Ana renk
          onPrimary: Colors.white,        // Bu parametreyi kaldırıyoruz
          secondary: Colors.green[400]!, // İkincil renk (butonlar için)
          onSecondary: Colors.white,      // Secondary renginin üzerindeki yazı rengi
        ),
        scaffoldBackgroundColor: Colors.green[50], // Arka plan rengi
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],  // Daha derin yeşil
          elevation: 4.0,  // AppBar'a hafif gölge efekti
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green[800],  // Daha koyu yeşil FAB rengi
          elevation: 5.0,  // FAB'ye gölge efekti
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Colors.black87,
            fontSize: 16, // Okunabilirlik için metin boyutu
          ),
          bodyMedium: TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22, // Başlık için daha büyük yazı
          ),
          bodySmall: TextStyle(
            color: Colors.green[800], // Alt başlık için renk
            fontSize: 18, // Alt başlık için stil
          ),
        ),
        cardColor: Colors.green[100], // Kartların arka plan rengi
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Yuvarlatılmış köşeler
          ),
          elevation: 5.0,  // Kartlara gölge efekti
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],  // Buton rengi
            foregroundColor: Colors.white,  // Buton üzerindeki yazı rengi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Yuvarlatılmış köşeler
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), // İçerik için padding
            elevation: 4.0, // Butona gölge efekti
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.green[800], // İkon renkleri
        ),
      ),
      home: const NoteListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
