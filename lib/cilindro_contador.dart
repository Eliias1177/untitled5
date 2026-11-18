import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// Ambas pantallas comparten este mismo reloj.
class RelojCilindro extends ChangeNotifier {
  final Stopwatch _reloj = Stopwatch();
  late final Timer _timer;

  RelojCilindro() {
    _reloj.start();

    // Actualiza la imagen aproximadamente 30 veces por segundo.
    _timer = Timer.periodic(
      const Duration(milliseconds: 33),
          (_) => notifyListeners(),
    );
  }

  int get segundos => _reloj.elapsed.inSeconds;

  // Una vuelta cada cuatro segundos.
  double get angulo {
    return (_reloj.elapsedMilliseconds % 4000) / 4000 * 2 * math.pi;
  }

  @override
  void dispose() {
    _timer.cancel();
    _reloj.stop();
    super.dispose();
  }
}

// Esta pantalla crea el reloj y lo conserva durante la práctica.
class CilindroContador extends StatefulWidget {
  const CilindroContador({super.key});

  @override
  State<CilindroContador> createState() => _CilindroContadorState();
}

class _CilindroContadorState extends State<CilindroContador> {
  late final RelojCilindro _reloj;

  @override
  void initState() {
    super.initState();
    _reloj = RelojCilindro();
  }

  @override
  void dispose() {
    // Se libera solamente al salir de esta práctica.
    _reloj.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VistaCilindro(
      reloj: _reloj,
      segundaPantalla: false,
    );
  }
}

// Se utiliza en las dos pantallas con el mismo reloj.
class VistaCilindro extends StatelessWidget {
  const VistaCilindro({
    super.key,
    required this.reloj,
    required this.segundaPantalla,
  });

  final RelojCilindro reloj;
  final bool segundaPantalla;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      segundaPantalla ? Colors.blue.shade50 : Colors.white,
      appBar: AppBar(
        title: Text(
          segundaPantalla
              ? 'Cilindro · Pantalla 2'
              : 'Cilindro · Pantalla 1',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Cilindro giratorio',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              AnimatedBuilder(
                animation: reloj,
                builder: (context, child) {
                  return Column(
                    children: [
                      CustomPaint(
                        size: const Size(220, 260),
                        painter: PintorCilindro(
                          angulo: reloj.angulo,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${reloj.segundos} segundos',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'El contador y el giro continúan al cambiar de pantalla.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: Icon(
                  segundaPantalla
                      ? Icons.arrow_back
                      : Icons.arrow_forward,
                ),
                label: Text(
                  segundaPantalla
                      ? 'Regresar a pantalla 1'
                      : 'Ir a pantalla 2',
                ),
                onPressed: () {
                  if (segundaPantalla) {
                    Navigator.pop(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VistaCilindro(
                          // Compartimos el reloj existente.
                          reloj: reloj,
                          segundaPantalla: true,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dibuja un cilindro con efecto de volumen.
// Las líneas sobre su superficie permiten apreciar el giro.
class PintorCilindro extends CustomPainter {
  const PintorCilindro({required this.angulo});

  final double angulo;

  @override
  void paint(Canvas canvas, Size size) {
    final centroX = size.width / 2;
    final radioX = size.width * 0.38;
    final radioY = size.height * 0.08;
    final arriba = size.height * 0.15;
    final abajo = size.height * 0.80;
    final izquierda = centroX - radioX;
    final derecha = centroX + radioX;

    // Sombra debajo del cilindro.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centroX, abajo + radioY + 14),
        width: radioX * 2,
        height: radioY,
      ),
      Paint()..color = Colors.black12,
    );

    // Silueta del cuerpo y su borde inferior curvo.
    final cuerpo = Path()
      ..moveTo(izquierda, arriba)
      ..lineTo(derecha, arriba)
      ..lineTo(derecha, abajo)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(centroX, abajo),
          width: radioX * 2,
          height: radioY * 2,
        ),
        0,
        math.pi,
        false,
      )
      ..close();

    final pinturaCuerpo = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF1A237E),
          Color(0xFF7986CB),
          Color(0xFF3949AB),
          Color(0xFF1A237E),
        ],
        stops: [0, 0.35, 0.7, 1],
      ).createShader(
        Rect.fromLTRB(
          izquierda,
          arriba,
          derecha,
          abajo + radioY,
        ),
      );

    canvas.drawPath(cuerpo, pinturaCuerpo);

    // Marcas que giran alrededor de la superficie.
    canvas.save();
    canvas.clipPath(cuerpo);

    for (int i = 0; i < 8; i++) {
      final posicion = angulo + i * 2 * math.pi / 8;
      final profundidad = math.cos(posicion);

      // Solo dibujamos las líneas del lado visible.
      if (profundidad > 0) {
        final x = centroX + math.sin(posicion) * radioX;
        final desplazamientoY = profundidad * radioY;

        final pinturaLinea = Paint()
          ..color = i == 0 ? Colors.amber : Colors.white54
          ..strokeWidth = i == 0 ? 7 : 3
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(x, arriba + desplazamientoY),
          Offset(x, abajo + desplazamientoY),
          pinturaLinea,
        );
      }
    }

    canvas.restore();

    // Tapa superior.
    final tapa = Rect.fromCenter(
      center: Offset(centroX, arriba),
      width: radioX * 2,
      height: radioY * 2,
    );

    canvas.drawOval(
      tapa,
      Paint()..color = const Color(0xFF9FA8DA),
    );

    canvas.drawOval(
      tapa,
      Paint()
        ..color = Colors.indigo
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Marca sobre la tapa para visualizar también su rotación.
    canvas.drawLine(
      Offset(centroX, arriba),
      Offset(
        centroX + math.sin(angulo) * radioX * 0.85,
        arriba + math.cos(angulo) * radioY * 0.85,
      ),
      Paint()
        ..color = Colors.amber.shade700
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant PintorCilindro oldDelegate) {
    return oldDelegate.angulo != angulo;
  }
}