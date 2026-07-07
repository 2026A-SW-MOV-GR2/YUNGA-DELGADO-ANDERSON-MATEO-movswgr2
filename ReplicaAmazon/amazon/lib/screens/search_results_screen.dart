import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/amazon_colors.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, this.query = 'audífonos'});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final List<Product> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _page = 0;
  static const _pageSize = 14;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      final nearBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400;
      if (nearBottom && !_isLoadingMore) _loadMore();
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final newItems = MockData.generateProducts('search-$_page', _pageSize);
    if (mounted) {
      setState(() {
        _items.addAll(newItems);
        _page++;
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AmazonColors.appBarGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: widget.query,
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    suffixIcon: const Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        controller: _scrollController,
        itemCount: _items.length + 1,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return _isLoadingMore
                ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(color: AmazonColors.orange)),
            )
                : const SizedBox(height: 50);
          }
          return _SearchResultTile(product: _items[index]);
        },
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Product product;
  const _SearchResultTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < product.rating.floor() ? Icons.star : Icons.star_border,
                        size: 16, color: AmazonColors.star,
                      )),
                    ),
                    const SizedBox(width: 4),
                    Text('${product.reviewCount}',
                        style: const TextStyle(fontSize: 13, color: AmazonColors.blueLink)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\$', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(product.price.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text((product.price % 1 * 100).toInt().toString().padLeft(2, '0'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (product.isPrime)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 14, color: AmazonColors.orange),
                        const SizedBox(width: 4),
                        Text('prime',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                const Text('Envío GRATIS por Amazon',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
