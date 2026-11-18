import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _timer;
  int _segundos = 0;
  int _indice = 0;

  final List<Color> _colores = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    // Cada segundo se suma 1; cada 3 segundos cambia el color de fondo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _segundos++;
        if (_segundos % 3 == 0) {
          _indice = (_indice + 1) % _colores.length;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colores[_indice],
      appBar: AppBar(title: const Text('Timer + Change')),
      body: Center(
        child: Text(
          'Segundos: $_segundos',
          style: const TextStyle(fontSize: 36, color: Colors.white),
        ),
      ),
    );
  }
}
