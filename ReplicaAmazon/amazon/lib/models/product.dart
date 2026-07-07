import 'dart:math';

class Product {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final bool isPrime;
  final int discountPercent;

  const Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.isPrime,
    required this.discountPercent,
  });

  bool get hasDiscount => discountPercent > 0;
}

class CartItem {
  final Product product;
  int quantity;
  bool selected;

  CartItem({required this.product, this.quantity = 1, this.selected = true});

  double get subtotal => product.price * quantity;
}

class MockData {
  static const List<String> homeSections = [
    'Ofertas recomendadas para ti',
    'Inspirado en tus compras',
    'Los más vendidos',
    'Compra de nuevo',
  ];

  static const _titles = [
    'Auriculares inalámbricos Bluetooth 5.3 con cancelación de ruido',
    'Reebok Club C 85 - Zapatos de tenis para mujer',
    'Reloj inteligente con GPS y monitor de frecuencia cardíaca',
    'Cámara instantánea con impresión digital y flash automático',
    'Mochila escolar impermeable con puerto USB para portátil',
    'Altavoz Bluetooth portátil resistente al agua IPX7',
    'Teclado mecánico RGB retroiluminado inalámbrico',
    'Cargador rápido USB-C 65W GaN para móvil y laptop',
  ];

  static const _images = [
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
    'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=400',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
    'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400',
    'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
    'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
    'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400',
    'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=400',
  ];

  static List<Product> generateProducts(String seed, int count) {
    final rng = Random(seed.hashCode);
    return List.generate(count, (i) {
      final price = 15 + rng.nextDouble() * 200;
      final discount = rng.nextBool() ? 10 + rng.nextInt(50) : 0;
      final original = discount > 0 ? price / (1 - discount / 100) : price;
      return Product(
        id: '$seed-$i',
        title: _titles[rng.nextInt(_titles.length)],
        imageUrl: _images[rng.nextInt(_images.length)],
        price: double.parse(price.toStringAsFixed(2)),
        originalPrice: double.parse(original.toStringAsFixed(2)),
        rating: 3.5 + rng.nextDouble() * 1.5,
        reviewCount: 20 + rng.nextInt(9000),
        isPrime: rng.nextBool(),
        discountPercent: discount,
      );
    });
  }
}
