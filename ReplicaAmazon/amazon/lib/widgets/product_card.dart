import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/amazon_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double width;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.width = 160,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(color: Colors.grey.shade100);
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '${product.discountPercent}% ahorro',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.2),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < product.rating.floor() ? Icons.star : Icons.star_half,
                      size: 14,
                      color: AmazonColors.star,
                    );
                  }),
                ),
                const SizedBox(width: 4),
                Text('${product.reviewCount}',
                    style: const TextStyle(fontSize: 12, color: AmazonColors.blueLink)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('\$', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Text(
                  product.price.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  (product.price % 1 * 100).toInt().toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (product.isPrime)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 12, color: AmazonColors.orange),
                    const SizedBox(width: 2),
                    Text('prime',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}