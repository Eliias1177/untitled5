import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Texto, Imagen, Texto')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Este es el primer texto',
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 16),
              Image.network(
                'https://picsum.photos/300/200',
                width: 300,
                height: 200,
              ),
              const SizedBox(height: 16),
              const Text(
                'Este es el segundo texto',
                style: TextStyle(fontSize: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
