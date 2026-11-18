import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'crud_api.dart';
import 'practica1.dart' as practica1;
import 'practica2.dart' as practica2;
import 'practica3.dart' as practica3;
import 'practica4.dart' as practica4;
import 'practica5.dart' as practica5;

class InicioEstrella extends StatefulWidget {
  const InicioEstrella({
    super.key,
    required this.cerrarSesion,
  });

  final VoidCallback cerrarSesion;

  @override
  State<InicioEstrella> createState() => _InicioEstrellaState();
}

class _InicioEstrellaState extends State<InicioEstrella> {
  final Stopwatch _reloj = Stopwatch();
  final ValueNotifier<double> _tiempo = ValueNotifier(0);

  late final Timer _timer;
  int _seccion = 0;

  final List<String> _titulos = [
    'Texto e imagen',
    'Entrada de texto',
    'Temporizador',
    'Cupertino y alertas',
    'Navegación',
  ];

  final List<Widget> _practicas = const [
    practica1.MyApp(),
    practica2.MyApp(),
    practica3.MyApp(),
    practica4.MyApp(),
    practica5.MyApp(),
  ];

  @override
  void initState() {
    super.initState();
    _reloj.start();

    _timer = Timer.periodic(
      const Duration(milliseconds: 33),
          (_) {
        _tiempo.value = _reloj.elapsedMilliseconds / 1000;
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _reloj.stop();
    _tiempo.dispose();
    super.dispose();
  }

  void _abrirPractica(int indice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('Práctica ${indice + 1}'),
          ),
          body: _practicas[indice],
        ),
      ),
    );
  }

  void _abrirCrud() {
    setState(() => _seccion = 2);
  }

  void _cambiarSeccionDesdeMenu(int indice) {
    Navigator.pop(context); // Cierra el menú lateral.
    setState(() => _seccion = indice);
  }

  String _formatoTiempo(int segundos) {
    final horas = (segundos ~/ 3600).toString().padLeft(2, '0');
    final minutos = ((segundos ~/ 60) % 60).toString().padLeft(2, '0');
    final resto = (segundos % 60).toString().padLeft(2, '0');

    return '$horas:$minutos:$resto';
  }

  Widget _pantallaEstrella({bool mostrarContador = false}) {
    final ancho = MediaQuery.of(context).size.width;
    final tamano = math.min(300.0, ancho * 0.78);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              mostrarContador ? '' : '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mostrarContador
                  ? '.'
                  : '.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 30),

            ValueListenableBuilder<double>(
              valueListenable: _tiempo,
              builder: (context, tiempo, child) {
                final segundos = tiempo.floor();

                return Column(
                  children: [
                    Transform.translate(
                      offset: Offset(0, math.sin(tiempo * 2) * 10),
                      child: Transform.scale(
                        scale: 1 + math.sin(tiempo * 2) * 0.025,
                        child: Transform.rotate(
                          angle: tiempo * math.pi / 8,
                          child: CustomPaint(
                            size: Size(tamano, tamano),
                            painter: PintorEstrella(tiempo: tiempo),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25254A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'TIEMPO TRANSCURRIDO',
                            style: TextStyle(
                              color: Colors.white70,
                              letterSpacing: 2,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatoTiempo(segundos),
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$segundos segundos',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),


          ],
        ),
      ),
    );
  }

  Widget _listaPracticas() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Selecciona una práctica',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (int i = 0; i < _titulos.length; i++)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(_titulos[i]),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _abrirPractica(i),
            ),
          ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('CRUD con API'),
            subtitle: const Text('GET, POST, PUT, PATCH y DELETE'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _abrirCrud,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombres = ['Inicio', 'Mis prácticas', 'CRUD con API'];

    return Scaffold(
      backgroundColor: const Color(0xFF13132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D3B),
        foregroundColor: Colors.white,
        title: Text(nombres[_seccion]),
      ),

      // Flutter muestra automáticamente el botón de hamburguesa.
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF1D1D3B),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 64,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Elias · Mis prácticas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                onTap: () => _cambiarSeccionDesdeMenu(0),
              ),
              ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('CRUD con API'),
                onTap: () {
                  Navigator.pop(context);
                  _abrirCrud();
                },
              ),
              const Divider(),

              for (int i = 0; i < _titulos.length; i++)
                ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(_titulos[i]),
                  onTap: () {
                    Navigator.pop(context);
                    _abrirPractica(i);
                  },
                ),

              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  Navigator.pop(context);
                  widget.cerrarSesion();
                },
              ),
            ],
          ),
        ),
      ),

      body: IndexedStack(
        index: _seccion,
        children: [
          _pantallaEstrella(),
          _listaPracticas(),
          const CrudApi(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seccion,
        onTap: (indice) => setState(() => _seccion = indice),
        backgroundColor: const Color(0xFF1D1D3B),
        selectedItemColor: const Color(0xFFFFD54F),
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Prácticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_rounded),
            label: 'CRUD',
          ),
        ],
      ),
    );
  }
}

class PintorEstrella extends CustomPainter {
  const PintorEstrella({required this.tiempo});

  final double tiempo;

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.shortestSide;
    final ancho = lado * 0.84;
    final alto = lado * 0.39;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 6);

    final capsula = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: ancho,
        height: alto,
      ),
      Radius.circular(alto / 2),
    );

    canvas.drawRRect(capsula, Paint()..color = const Color(0xFFFF0000));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PintorEstrella anterior) => false;
}