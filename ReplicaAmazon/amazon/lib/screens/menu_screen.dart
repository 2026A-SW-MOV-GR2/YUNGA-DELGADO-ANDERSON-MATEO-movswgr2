import 'package:flutter/material.dart';
import '../theme/amazon_colors.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AmazonColors.appBarGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar en Amazon',
                prefixIcon: Icon(Icons.search, color: Colors.black),
                suffixIcon: Icon(Icons.camera_alt_outlined, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 10),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Text('Tus accesos directos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  _Pill(label: 'Pedidos'),
                  SizedBox(width: 8),
                  _Pill(label: 'Listas'),
                  SizedBox(width: 8),
                  _Pill(label: 'Comprar de nuevo'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Text('Compra por categoría',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _DepartamentosDropdown(),
            ),
            const SizedBox(height: 12),
            const _MenuItem(title: 'Cambiar de cuenta'),
            const _MenuItem(title: '¿No eres Pepe Delgado? Cerrar sesión'),
            const _MenuItem(title: 'Servicio de atención al cliente'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AmazonColors.blueLink, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '¿Buscas la configuración de la aplicación? Se movió a 👤',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}

class _DepartamentosDropdown extends StatelessWidget {
  const _DepartamentosDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AmazonColors.blueLink, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: const [
          Text('Departamentos', style: TextStyle(fontSize: 15)),
          Spacer(),
          Icon(Icons.keyboard_arrow_down, color: AmazonColors.blueLink),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  const _MenuItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}