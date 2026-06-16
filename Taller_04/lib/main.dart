import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/outgoing_screen.dart';
import 'screens/incoming_screen.dart';

// ─────────────────────────────────────────────────────────────
//  Canal de comunicación con la capa nativa (MainActivity.kt)
//  Debe coincidir EXACTAMENTE con el String definido en Kotlin
// ─────────────────────────────────────────────────────────────
const platform = MethodChannel('com.snapshare/intent');

void main() {
  runApp(const SnapShareApp());
}

class SnapShareApp extends StatelessWidget {
  const SnapShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapShare',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    // Paleta: fondo casi negro + acento violeta eléctrico + blanco roto
    const Color bgDark = Color(0xFF0D0D0F);
    const Color bgCard = Color(0xFF1A1A1F);
    const Color accent = Color(0xFF7C3AED); // violeta
    const Color accentLight = Color(0xFFAB6EFF);
    const Color textPrimary = Color(0xFFF0EEF6);
    const Color textMuted = Color(0xFF6B6880);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: bgCard,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'sans-serif-condensed',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: textPrimary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentLight,
        unselectedLabelColor: textMuted,
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A35), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textMuted),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Pantalla raíz con TabBar (Salientes / Entrantes)
// ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Datos recibidos por Intent entrante — se pasan al IncomingScreen
  String? _incomingText;
  String? _incomingImagePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupMethodChannel();
    _checkInitialIntent();
  }

  // ── 1. Escucha mensajes en tiempo real (app ya abierta → onNewIntent)
  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'sharedText':
          final text = call.arguments as String?;
          if (text != null) {
            setState(() {
              _incomingText = text;
              _incomingImagePath = null; // limpiamos imagen previa
            });
            // Navegamos automáticamente a la pestaña de entrantes
            _tabController.animateTo(1);
          }
          break;

        case 'sharedImage':
          final path = call.arguments as String?;
          if (path != null) {
            setState(() {
              _incomingImagePath = path;
              _incomingText = null; // limpiamos texto previo
            });
            _tabController.animateTo(1);
          }
          break;
      }
    });
  }

  // ── 2. Revisa si la app fue abierta DESDE un Intent (arranque frío)
  Future<void> _checkInitialIntent() async {
    try {
      final result = await platform.invokeMethod<Map>('getInitialIntent');
      if (result != null) {
        final text = result['text'] as String?;
        final imagePath = result['imagePath'] as String?;

        if (text != null || imagePath != null) {
          setState(() {
            _incomingText = text;
            _incomingImagePath = imagePath;
          });
          _tabController.animateTo(1);
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Error al leer intent inicial: ${e.message}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Snap',
                style: TextStyle(
                  color: Color(0xFFF0EEF6),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              TextSpan(
                text: 'Share',
                style: TextStyle(
                  color: Color(0xFFAB6EFF),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.send_rounded, size: 18),
              text: 'SALIENTES',
            ),
            Tab(
              icon: Icon(Icons.download_rounded, size: 18),
              text: 'ENTRANTES',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const OutgoingScreen(),
          IncomingScreen(
            incomingText: _incomingText,
            incomingImagePath: _incomingImagePath,
          ),
        ],
      ),
    );
  }
}
