import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const TallerApp());

class TallerApp extends StatelessWidget {
  const TallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResolucionNativaScreen(),
    );
  }
}

class ResolucionNativaScreen extends StatefulWidget {
  const ResolucionNativaScreen({super.key});

  @override
  State<ResolucionNativaScreen> createState() => _ResolucionNativaScreenState();
}

class _ResolucionNativaScreenState extends State<ResolucionNativaScreen> with WidgetsBindingObserver {
  // El mismo nombre de canal que declaramos en Kotlin
  static const platform = MethodChannel('epn.edu.ec/recursos_nativos');

  String _text = "Cargando...";
  Color _text_color = Colors.black;
  Color _bg_color = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Escuchar eventos del sistema
    _pedirRecursos(); // Pedir datos la primera vez que arranca
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Se dispara al rotar la pantalla
  @override
  void didChangeMetrics() {
    _pedirRecursos();
  }

  // Se dispara al cambiar el idioma en los ajustes del celular
  @override
  void didChangeLocales(List<Locale>? locales) {
    _pedirRecursos();
  }

  Future<void> _pedirRecursos() async {
    try {
      // Hacemos la petición a Kotlin
      final Map<dynamic, dynamic> result = await platform.invokeMethod('obtenerRecursos');

      // Actualizamos la UI con lo que nos respondió Android
      setState(() {
        _text = result['text'];
        _text_color = Color(result['text_color']);
        _bg_color = Color(result['bg_color']);
      });
    } on PlatformException catch (e) {
      setState(() {
        _text = "Error de canal: \${e.message}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg_color,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _text,
            style: TextStyle(
              color: _text_color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}