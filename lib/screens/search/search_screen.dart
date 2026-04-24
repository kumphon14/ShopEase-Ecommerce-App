// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/product_provider.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Product> _results = [];
  bool _hasSearched = false;

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    final provider = Provider.of<ProductProvider>(context, listen: false);
    setState(() {
      _results = provider.searchByName(query.trim());
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        titleSpacing: 16,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _search,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search,
                  color: AppTheme.textMediumColor, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: AppTheme.backgroundColor,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          size: 18, color: AppTheme.textMediumColor),
                      onPressed: () {
                        _controller.clear();
                        _search('');
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: !_hasSearched
          ? _buildEmptyState()
          : _results.isEmpty
              ? _buildNoResults()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Text(
                        '${_results.length} result(s) for "${_controller.text}"',
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (_, i) =>
                            ProductCard(product: _results[i]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 80, color: AppTheme.textLightColor),
          const SizedBox(height: 16),
          const Text(
            'Start searching',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Type a product name to find what you need',
            style: TextStyle(color: AppTheme.textMediumColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: AppTheme.textLightColor),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No products match "${_controller.text}"',
            style: const TextStyle(color: AppTheme.textMediumColor),
          ),
        ],
      ),
    );
  }
}
