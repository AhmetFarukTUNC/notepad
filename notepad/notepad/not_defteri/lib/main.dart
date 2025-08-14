import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:not_defteri/screens/LoginScreen/Login.dart';
import 'dart:convert';

import 'package:not_defteri/screens/RegisterScreen/RegisterScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // veya Key? key ile uyumlu olacak

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PHP Flutter API Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),  // veya HomePage() kullanabilirsin
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String message = "Veri bekleniyor...";

  Future<void> getData() async {
    try {
      var url = Uri.parse("http://10.24.227.1/notepad/db.php");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          message = "${data['message']} \nZaman: ${data['time']}";
        });
      } else {
        setState(() {
          message = "API hatası: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Bağlantı hatası: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PHP Flutter Entegrasyonu")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getData,
              child: const Text("PHP'den Veri Getir"),
            ),
          ],
        ),
      ),
    );
  }
}
