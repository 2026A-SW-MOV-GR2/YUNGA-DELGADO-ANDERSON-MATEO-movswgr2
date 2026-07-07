import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/amazon_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> _cartItems;
  static const double _freeShippingThreshold = 99.0;

  @override
  void initState() {
    super.initState();
    _cartItems = MockData.generateProducts('cart', 4)
        .map((p) => CartItem(product: p, quantity: 1))
        .toList();
  }

  double get _subtotal =>
      _cartItems.where((i) => i.selected).fold(0, (s, i) => s + i.subtotal);

  int get _selectedCount =>
      _cartItems.where((i) => i.selected).fold(0, (s, i) => s + i.quantity);

  void _updateQuantity(CartItem item, int delta) {
    setState(() => item.quantity = (item.quantity + delta).clamp(1, 99));
  }

  void _remove(CartItem item) {
    setState(() => _cartItems.remove(item));
  }

  void _addToCart(Product p) {
    setState(() {
      final existing = _cartItems.where((i) => i.product.id == p.id).toList();
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        _cartItems.add(CartItem(product: p, quantity: 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${p.title}" agregado al carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Sugerencias cercanas al monto faltante (±40%).
  List<Product> _suggestionsFor(double missing) {
    if (missing <= 0) return [];
    final pool = MockData.generateProducts('booster', 20);
    final lo = missing * 0.6;
    final hi = missing * 1.4;
    final matches = pool.where((p) => p.price >= lo && p.price <= hi).toList()
      ..sort((a, b) => (a.price - missing).abs().compareTo((b.price - missing).abs()));
    return matches.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_subtotal / _freeShippingThreshold).clamp(0.0, 1.0);
    final missing = (_freeShippingThreshold - _subtotal).clamp(0.0, _freeShippingThreshold);

    return Scaffold(
      backgroundColor: AmazonColors.background,
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
          Container(
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AmazonColors.locationGradient),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 20),
                SizedBox(width: 5),
                Text('Enviar a Mateo - Quito 170201',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Subtotal ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                    Text('US\$${_subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('US\$${_freeShippingThreshold.toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(AmazonColors.success),
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 13.5, height: 1.4),
                    children: [
                      const TextSpan(text: 'Agrega '),
                      TextSpan(
                        text: 'US\$${missing.toStringAsFixed(2)}',
                        style: const TextStyle(color: AmazonColors.blueLink, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text:
                      ' productos elegibles a tu pedido para envío gratis. Ten en cuenta que no todos los productos en tu carrito son elegibles. '),
                      const TextSpan(
                        text: 'Encontrar productos elegibles',
                        style: TextStyle(color: AmazonColors.blueLink),
                      ),
                    ],
                  ),
                ),
                if (missing > 0)
                  _FreeShippingBooster(
                    missing: missing,
                    products: _suggestionsFor(missing),
                    onAdd: _addToCart,
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cartItems.isEmpty ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AmazonColors.yellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text('Proceder al pago ($_selectedCount productos)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Anular la selección de todos los elementos',
                    style: TextStyle(color: AmazonColors.blueLink, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._cartItems.map((item) => _CartTile(
            item: item,
            onIncrement: () => _updateQuantity(item, 1),
            onDecrement: () => _updateQuantity(item, -1),
            onRemove: () => _remove(item),
            onToggle: () => setState(() => item.selected = !item.selected),
          )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onToggle;

  const _CartTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, right: 6),
              child: Icon(
                item.selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: item.selected ? AmazonColors.blueLink : Colors.grey,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              p.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 100, height: 100, color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text('US\$${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 12.5, height: 1.3),
                    children: [
                      const TextSpan(text: 'Envío ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'GRATIS ',
                          style: TextStyle(color: AmazonColors.success, fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'a Ecuador cuando gastes más de US\$99.00 en artículos elegibles.'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Disponible',
                    style: TextStyle(color: AmazonColors.success, fontSize: 12.5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QtyStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                      onDelete: onRemove,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _CartAction(label: 'Guardar para más tarde'),
                _CartAction(label: 'Compartir'),
                _CartAction(label: 'Ver en tu habitación'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _QtyStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AmazonColors.yellow,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          InkWell(
            onTap: quantity == 1 ? onDelete : onDecrement,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(quantity == 1 ? Icons.delete_outline : Icons.remove, size: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$quantity',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          InkWell(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartAction extends StatelessWidget {
  final String label;
  const _CartAction({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(label,
          style: const TextStyle(color: AmazonColors.blueLink, fontSize: 13)),
    );
  }
}

class _FreeShippingBooster extends StatelessWidget {
  final double missing;
  final List<Product> products;
  final ValueChanged<Product> onAdd;

  const _FreeShippingBooster({
    required this.missing,
    required this.products,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined,
                    size: 18, color: AmazonColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.2),
                      children: [
                        const TextSpan(text: 'Agrega uno de estos y obtén '),
                        const TextSpan(
                          text: 'envío gratis',
                          style: TextStyle(color: AmazonColors.success, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' (te faltan US\$${missing.toStringAsFixed(2)})'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final p = products[i];
                return Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.network(p.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(p.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, height: 1.2)),
                      const SizedBox(height: 4),
                      Text('US\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton.icon(
                          onPressed: () => onAdd(p),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Añadir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AmazonColors.yellow,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
