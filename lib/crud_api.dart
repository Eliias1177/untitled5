import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Todas las peticiones de esta pantalla pasan por este servicio.
class ApiService {
  final http.Client _cliente = http.Client();

  static const String _url =
      'https://jsonplaceholder.typicode.com';

  // Añade el mensaje automáticamente a cada registro del GET.
  dynamic _agregarMensaje(dynamic datos) {
    if (datos is List) {
      return datos.map(_agregarMensaje).toList();
    }

    if (datos is Map) {
      return {
        ...Map<String, dynamic>.from(datos),
        'mensaje': 'eliasxpaqui',
      };
    }

    return {
      'datos': datos,
      'mensaje': 'eliasxpaqui',
    };
  }

  Future<Map<String, dynamic>> solicitar(
      String metodo,
      String ruta, {
        Map<String, dynamic>? cuerpo,
      }) async {
    final peticion = http.Request(
      metodo,
      Uri.parse('$_url$ruta'),
    );

    peticion.headers['Accept'] = 'application/json';

    if (cuerpo != null) {
      peticion.headers['Content-Type'] =
      'application/json; charset=UTF-8';
      peticion.body = jsonEncode(cuerpo);
    }

    final respuesta = await _cliente
        .send(peticion)
        .then(http.Response.fromStream)
        .timeout(const Duration(seconds: 20));

    if (respuesta.statusCode < 200 ||
        respuesta.statusCode >= 300) {
      throw Exception(
        'Error HTTP ${respuesta.statusCode}: ${respuesta.body}',
      );
    }

    dynamic datos = respuesta.body.trim().isEmpty
        ? null
        : jsonDecode(respuesta.body);

    // Se ejecuta automáticamente para cualquier GET del servicio.
    if (metodo == 'GET') {
      datos = _agregarMensaje(datos);
    }

    return {
      'metodo': metodo,
      'codigo': respuesta.statusCode,
      'datos': datos,
    };
  }

  void cerrar() {
    _cliente.close();
  }
}

class CrudApi extends StatefulWidget {
  const CrudApi({super.key});

  @override
  State<CrudApi> createState() => _CrudApiState();
}

class _CrudApiState extends State<CrudApi> {
  final _api = ApiService();

  final _id = TextEditingController(text: '1');
  final _titulo = TextEditingController();
  final _contenido = TextEditingController();

  bool _cargando = false;
  String _respuesta = 'Todavía no hay una respuesta.';
  List<Map<String, dynamic>> _registros = [];

  @override
  void initState() {
    super.initState();
    _ejecutar('GET');
  }

  @override
  void dispose() {
    _api.cerrar();
    _id.dispose();
    _titulo.dispose();
    _contenido.dispose();
    super.dispose();
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> _ejecutar(String metodo) async {
    if (_cargando) return;

    final id = int.tryParse(_id.text.trim());
    final necesitaId =
        metodo == 'PUT' || metodo == 'PATCH' || metodo == 'DELETE';

    // JSONPlaceholder tiene publicaciones existentes del 1 al 100.
    if (necesitaId && (id == null || id < 1 || id > 100)) {
      _aviso('Para esta API de prueba usa un ID del 1 al 100.');
      return;
    }

    if ((metodo == 'POST' || metodo == 'PUT' || metodo == 'PATCH') &&
        _titulo.text.trim().isEmpty) {
      _aviso('Escribe un título.');
      return;
    }

    if ((metodo == 'POST' || metodo == 'PUT') &&
        _contenido.text.trim().isEmpty) {
      _aviso('Escribe el contenido.');
      return;
    }

    String ruta;
    Map<String, dynamic>? cuerpo;

    switch (metodo) {
      case 'GET':
      // Diez registros para que la lista sea fácil de revisar.
        ruta = '/posts?_limit=10';
        break;

      case 'POST':
        ruta = '/posts';
        cuerpo = {
          'title': _titulo.text.trim(),
          'body': _contenido.text.trim(),
          'userId': 1,
        };
        break;

      case 'PUT':
        ruta = '/posts/$id';
        cuerpo = {
          'id': id,
          'title': _titulo.text.trim(),
          'body': _contenido.text.trim(),
          'userId': 1,
        };
        break;

      case 'PATCH':
        ruta = '/posts/$id';
        cuerpo = {
          'title': _titulo.text.trim(),
        };
        break;

      case 'DELETE':
        ruta = '/posts/$id';
        break;

      default:
        return;
    }

    setState(() {
      _cargando = true;
      _respuesta = 'Enviando $metodo...';
    });

    try {
      final resultado = await _api.solicitar(
        metodo,
        ruta,
        cuerpo: cuerpo,
      );

      if (!mounted) return;

      setState(() {
        _respuesta =
            const JsonEncoder.withIndent('  ').convert(resultado);

        if (metodo == 'GET') {
          _registros = (resultado['datos'] as List)
              .map((elemento) => Map<String, dynamic>.from(elemento))
              .toList();
        } else if (metodo == 'PUT' || metodo == 'PATCH') {
          // Refleja localmente el cambio de la API de demostración.
          final indice =
          _registros.indexWhere((registro) => registro['id'] == id);

          if (indice != -1) {
            _registros[indice] = {
              ..._registros[indice],
              ...Map<String, dynamic>.from(resultado['datos']),
            };
          }
        } else if (metodo == 'DELETE') {
          _registros.removeWhere((registro) => registro['id'] == id);
        }

        // POST muestra el registro creado en el panel de respuesta.
        // No se añade a la lista porque esta API no lo persiste:
        // un GET posterior a ese ID no lo encontraría.
      });

      _aviso('$metodo completado: HTTP ${resultado['codigo']}');
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _respuesta = 'La API tardó demasiado. Intenta nuevamente.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _respuesta = 'No se pudo completar la petición:\n$error';
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  void _seleccionar(Map<String, dynamic> registro) {
    setState(() {
      _id.text = registro['id'].toString();
      _titulo.text = registro['title']?.toString() ?? '';
      _contenido.text = registro['body']?.toString() ?? '';
    });

    _aviso('Registro ${registro['id']} seleccionado para editar.');
  }

  Widget _boton(String metodo, String accion) {
    return ElevatedButton(
      onPressed: _cargando ? null : () => _ejecutar(metodo),
      child: Text('$metodo · $accion'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD con API'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'API de demostración: los cambios no se guardan '
                'permanentemente en el servidor.',
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _id,
            enabled: !_cargando,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ID del registro',
              helperText: 'PUT, PATCH y DELETE usan este ID: 1 a 100.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _titulo,
            enabled: !_cargando,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _contenido,
            enabled: !_cargando,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Contenido',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _boton('GET', 'Consultar'),
              _boton('POST', 'Crear'),
              _boton('PUT', 'Actualizar todo'),
              _boton('PATCH', 'Cambiar título'),
              _boton('DELETE', 'Eliminar'),
            ],
          ),

          if (_cargando) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],

          const SizedBox(height: 24),
          const Text(
            'Registros: toca uno para editarlo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          for (final registro in _registros)
            Card(
              child: ListTile(
                onTap: _cargando ? null : () => _seleccionar(registro),
                leading: CircleAvatar(
                  child: Text('${registro['id']}'),
                ),
                title: Text(registro['title'].toString()),
                subtitle: Text(
                  '${registro['body']}\n'
                      ': ${registro['mensaje']}',
                ),
                trailing: const Icon(Icons.edit),
              ),
            ),

          const SizedBox(height: 24),
          const Text(
            'Última respuesta procesada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              _respuesta,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}