import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../theme/amazon_colors.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  double _page = 0;

  late final List<_HeroCard> _heroCards;

  @override
  void initState() {
    super.initState();
    _heroCards = [
      _HeroCard(
        title: 'Sigue\ncomprando',
        color: AmazonColors.heroCards[0],
        tileColor: const Color(0xFFEF9377),
        products: MockData.generateProducts('keep', 4),
      ),
      _HeroCard(
        title: 'Envío gratis',
        subtitle: 'En pedidos internacionales…',
        color: AmazonColors.heroCards[1],
        illustration: 'assets/images/free.jpg',
        products: const [],
      ),
      _HeroCard(
        title: 'Impulsa\npara\nestudiar',
        color: AmazonColors.heroCards[2],
        tileColor: const Color(0xFF54B0B8),
        products: MockData.generateProducts('study', 4),
      ),
      _HeroCard(
        title: 'Tu\nbelleza',
        color: AmazonColors.heroCards[3],
        tileColor: const Color(0xFFEDB1AB),
        products: MockData.generateProducts('beauty', 4),
      ),
    ];
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color get _blendedColor {
    final i = _page.floor().clamp(0, _heroCards.length - 1);
    final next = (i + 1).clamp(0, _heroCards.length - 1);
    final t = _page - i;
    return Color.lerp(_heroCards[i].color, _heroCards[next].color, t)!;
  }

  @override
  Widget build(BuildContext context) {
    final topColor = _blendedColor;
    final sections = MockData.homeSections;

    return Scaffold(
      backgroundColor: AmazonColors.background,
      body: CustomScrollView(
        slivers: [
          // BLOQUE TOP: search + location + carrusel, todo con el mismo color fusionado
          SliverToBoxAdapter(
            child: Container(
              color: topColor,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Buscador
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4),
                          ],
                        ),
                        child: TextField(
                          onSubmitted: (q) => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SearchResultsScreen(query: q)),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Buscar en Amazon',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.black, size: 22),
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 22),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 12),
                          ),
                        ),
                      ),
                    ),
                    // Location banner (pastilla blanca sutil)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.location_on_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Enviar a Mateo - Quito 170201',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    // Carrusel hero
                    SizedBox(
                      height: 380,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _heroCards.length,
                        padEnds: false,
                        itemBuilder: (context, index) {
                          final card = _heroCards[index];
                          // Interpolación de escala/opacidad simple para efecto stack
                          final delta = (index - _page).abs().clamp(0.0, 1.0);
                          final scale = 1 - (delta * 0.04);
                          return Transform.scale(
                            scale: scale,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _HeroCardView(card: card),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          // Secciones normales
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final products = MockData.generateProducts('home-$index', 10);
                return _HomeSection(title: sections[index], products: products);
              },
              childCount: sections.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _HeroCard {
  final String title;
  final String? subtitle;
  final Color color;
  final Color? tileColor;
  final String? illustration;
  final List<Product> products;
  _HeroCard({
    required this.title,
    this.subtitle,
    required this.color,
    this.tileColor,
    this.illustration,
    required this.products,
  });
}

class _HeroCardView extends StatelessWidget {
  final _HeroCard card;
  const _HeroCardView({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.05,
              color: Colors.black,
            ),
          ),
          if (card.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(card.subtitle!, style: const TextStyle(fontSize: 15)),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: card.products.isNotEmpty
                ? GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: card.products.length.clamp(0, 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, i) => Container(
                decoration: BoxDecoration(
                  color: card.tileColor ?? Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.network(
                  card.products[i].imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              ),
            )
                : Center(
              child: card.illustration != null
                  ? Image.asset(card.illustration!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 100))
                  : const SizedBox(),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Con compra mínima. Aplican términos',
              style: TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  const _HomeSection({required this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: products.length,
              itemBuilder: (context, index) => ProductCard(product: products[index]),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 14, top: 10),
            child: Text('Ver más',
                style: TextStyle(color: AmazonColors.blueLink, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}