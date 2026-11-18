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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CrudApi()),
    );
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

            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() => _seccion = 1),
                  icon: const Icon(Icons.school),
                  label: const Text('Ver prácticas'),
                ),
                ElevatedButton.icon(
                  onPressed: _abrirCrud,
                  icon: const Icon(Icons.cloud),
                  label: const Text('Abrir CRUD'),
                ),
              ],
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
    final nombres = ['Inicio', 'Mis prácticas', 'Contador'];

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
                leading: const Icon(Icons.timer),
                title: const Text('Contador'),
                onTap: () => _cambiarSeccionDesdeMenu(2),
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

      body: _seccion == 1
          ? _listaPracticas()
          : _pantallaEstrella(mostrarContador: _seccion == 2),

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
            icon: Icon(Icons.timer_rounded),
            label: 'Contador',
          ),
        ],
      ),
    );
  }
}

// Estrella de cinco puntas, dorada y con ojos.
class PintorEstrella extends CustomPainter {
  const PintorEstrella({required this.tiempo});

  final double tiempo;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = size.width * 0.43;
    final interior = radio * 0.48;

    // Resplandor alrededor de la estrella.
    canvas.drawCircle(
      centro,
      radio * 1.15,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0x66FFD54F),
            Color(0x00FFD54F),
          ],
        ).createShader(
          Rect.fromCircle(center: centro, radius: radio * 1.15),
        ),
    );

    final estrella = Path();

    for (int i = 0; i < 10; i++) {
      final angulo = -math.pi / 2 + i * math.pi / 5;
      final distancia = i.isEven ? radio : interior;

      final punto = Offset(
        centro.dx + math.cos(angulo) * distancia,
        centro.dy + math.sin(angulo) * distancia,
      );

      if (i == 0) {
        estrella.moveTo(punto.dx, punto.dy);
      } else {
        estrella.lineTo(punto.dx, punto.dy);
      }
    }

    estrella.close();

    canvas.drawShadow(estrella, Colors.black, 10, false);

    // Color y volumen.
    canvas.drawPath(
      estrella,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFC0),
            Color(0xFFFFF600),
            Color(0xFFFFD000),
            Color(0xFFFFA000),
          ],
          stops: [0, 0.3, 0.7, 1],
        ).createShader(estrella.getBounds()),
    );

    canvas.drawPath(
      estrella,
      Paint()
        ..color = const Color(0xFFFFF59D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    // Brillo suave en la parte superior.
    canvas.save();
    canvas.clipPath(estrella);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx - radio * 0.15, centro.dy - radio * 0.5),
        width: radio * 1.5,
        height: radio * 0.65,
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x88FFFFFF), Color(0x00FFFFFF)],
        ).createShader(estrella.getBounds()),
    );

    canvas.restore();

    // Parpadeo breve cada cuatro segundos.
    final fase = tiempo % 4;
    final apertura = fase < 0.16 ? 0.12 : 1.0;
    final altoOjo = radio * 0.34 * apertura;
    final anchoOjo = radio * 0.12;

    for (final lado in [-1, 1]) {
      final ojo = Offset(
        centro.dx + lado * radio * 0.19,
        centro.dy - radio * 0.03,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: ojo,
          width: anchoOjo,
          height: altoOjo,
        ),
        Paint()..color = const Color(0xFF241700),
      );

      if (apertura > 0.5) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              ojo.dx - anchoOjo * 0.1,
              ojo.dy - altoOjo * 0.22,
            ),
            width: anchoOjo * 0.42,
            height: altoOjo * 0.38,
          ),
          Paint()..color = Colors.white,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PintorEstrella oldDelegate) {
    return oldDelegate.tiempo != tiempo;
  }
}