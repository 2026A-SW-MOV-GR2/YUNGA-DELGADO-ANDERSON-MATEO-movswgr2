import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/amazon_colors.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header con saludo + iconos
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3B382), Color(0xFFF6D6BE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 18, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    const Text('Hola, Pepe',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.notifications_none),
                    const SizedBox(width: 14),
                    const Icon(Icons.settings_outlined),
                    const SizedBox(width: 14),
                    Container(
                      width: 24, height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Center(
                          child: Text('🇺🇸', style: TextStyle(fontSize: 11))),
                    ),
                    const SizedBox(width: 4),
                    const Text('ES', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 14),
                // Pills
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _Pill(label: 'Pedidos'),
                      SizedBox(width: 8),
                      _Pill(label: 'Comprar de nuevo'),
                      SizedBox(width: 8),
                      _Pill(label: 'Cuenta'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tus pedidos
          const _SectionHeader(title: 'Tus pedidos'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('Parece que no tienes pedidos recientes',
                style: TextStyle(fontSize: 13, color: Colors.black87)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _InfoCard(
                  bg: const Color(0xFFEAF3F5),
                  title: 'Ahorros a\nmontón',
                  subtitle: 'Compra las\nOfertas del Día',
                  imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=200',
                ),
                _InfoCard(
                  bg: const Color(0xFFEAF3F5),
                  title: 'Audio\ninalámbrico',
                  subtitle: 'Descubre las\nmejores marcas',
                  imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200',
                ),
              ],
            ),
          ),

          // Comprar de nuevo
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Comprar de nuevo'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'Descubre lo que otras personas compran frecuentemente en Comprar de nuevo',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                foregroundColor: Colors.black,
              ),
              child: const Text('Visita Buy Again'),
            ),
          ),

          // Seguir comprando
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Seguir comprando'),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: 6,
              itemBuilder: (context, i) {
                final p = MockData.generateProducts('acc-keep', 6)[i];
                final labels = ['Tenis de moda', 'Audífonos', 'Relojes de puls...'];
                return Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey.shade100,
                          padding: const EdgeInsets.all(6),
                          child: Image.network(p.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(labels[i % labels.length],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${17 + i} vistos',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Icon(Icons.keyboard_arrow_right),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color bg;
  final String title;
  final String subtitle;
  final String imageUrl;

  const _InfoCard({
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.2)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(width: 80, height: 80)),
          ),
        ],
      ),
    );
  }
}