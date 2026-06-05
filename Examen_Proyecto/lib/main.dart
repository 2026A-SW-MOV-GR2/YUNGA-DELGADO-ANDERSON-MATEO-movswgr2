// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/logger/app_logger.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/nosql_datasource.dart';
import 'data/datasources/local/sql_datasource.dart';
import 'data/repositories/content_repository_impl.dart';
import 'presentation/pages/favorites_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/library_page.dart';
import 'presentation/pages/network/network_page.dart';       // ← NUEVO
import 'presentation/pages/secrets/secrets_pages.dart';      // ← NUEVO (Note: secrets_pages.dart)
import 'presentation/providers/content_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  AppLogger.info('Hive inicializado', tag: 'main');

  final sqlDs = SqlDatasource();
  final noSqlDs = NoSqlDatasource();
  final repository = ContentRepositoryImpl(
    sqlDatasource: sqlDs,
    noSqlDatasource: noSqlDs,
    useNoSql: false,
  );

  AppLogger.info('CineTrack iniciando...', tag: 'main');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ContentProvider(repository)..loadAll(),
      child: const CineTrackApp(),
    ),
  );
}

class CineTrackApp extends StatelessWidget {
  const CineTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _MainShell(),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  static const _pages = [
    HomePage(),
    LibraryPage(),
    FavoritesPage(),
    NetworkPage(),      // ← NUEVO (Módulo 1)
    SecretsPage(),      // ← NUEVO (Módulo 3)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'REST API',           // ← NUEVO
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock),
            label: 'Secretos',           // ← NUEVO
          ),
        ],
      ),
    );
  }
}