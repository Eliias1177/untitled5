import 'package:flutter/cupertino.dart';
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

class Home extends StatelessWidget {
  const Home({super.key});

  void _mostrarAlerta(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Alerta'),
        content: const Text('Esta es una alerta estilo iOS'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Aceptar'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupertino + Stack + Alert')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Capa 1: fondo
          Container(color: Colors.blue.shade100),
          // Capa 2: cuadro azul
          Container(width: 250, height: 250, color: Colors.blue),
          // Capa 3: texto encima
          const Text(
            'Stack',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          // Capa 4: botón Cupertino abajo
          Positioned(
            bottom: 40,
            child: CupertinoButton.filled(
              onPressed: () => _mostrarAlerta(context),
              child: const Text('Mostrar alerta'),
            ),
          ),
        ],
      ),
    );
  }
}
