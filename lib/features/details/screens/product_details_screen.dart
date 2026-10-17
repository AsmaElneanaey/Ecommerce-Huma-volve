import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/dummy_data.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/theme.dart';
import '../../main_navigation/screens/main_navigation_screen.dart';
import '../widgets/color_selector.dart';
import '../widgets/size_selector.dart';
import '../../../core/widgets/primary_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;
  final String? productId;

  const ProductDetailsScreen({
    super.key,
    this.product,
    this.productId,
  }) : assert(
          product != null || productId != null,
          'Either product or productId must be provided',
        );

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? _product;
  Color? _selectedColor;
  String? _selectedSize;
  bool _isNotFound = false;

  @override
  void initState() {
    super.initState();
    _resolveProduct();
  }

  void _resolveProduct() {
    if (widget.product != null) {
      _product = widget.product;
    } else if (widget.productId != null) {
      try {
        _product = dummyProducts.firstWhere(
          (p) => p.id == widget.productId,
        );
      } catch (_) {
        _isNotFound = true;
      }
    }

    if (_product != null) {
      _selectedColor =
          _product!.colors.isNotEmpty ? _product!.colors.first : AppTheme.primary;
      _selectedSize =
          _product!.sizes.isNotEmpty ? _product!.sizes.first : 'One Size';
    }
  }

  void _handleBackNavigation() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _shareDeepLink() {
    if (_product == null) return;
    final deepLink = DeepLinkService.buildProductUri(_product!.id);
    Clipboard.setData(ClipboardData(text: deepLink));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.link, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Deep link copied: $deepLink',
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isNotFound || _product == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
            onPressed: _handleBackNavigation,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Product Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.productId != null
                      ? 'No product found with ID "${widget.productId}".'
                      : 'The requested product could not be found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Explore Products',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
              onPressed: _handleBackNavigation,
            ),
            actions: [
              IconButton(
                tooltip: 'Copy Deep Link',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                ),
                onPressed: _shareDeepLink,
              ),
              IconButton(
                tooltip: 'Favorite',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, size: 18),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              transform: Matrix4.translationValues(0.0, -32.0, 0.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontSize: 28,
                                  height: 1.2,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AppTheme.primary,
                                  fontSize: 24,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            fontSize: 16,
                          ),
                    ),
                    if (product.colors.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Select Color',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ColorSelector(
                        colors: product.colors,
                        selectedColor: _selectedColor ?? product.colors.first,
                        onColorSelected: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),
                    ],
                    if (product.sizes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Select Size',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SizeSelector(
                        sizes: product.sizes,
                        selectedSize: _selectedSize ?? product.sizes.first,
                        onSizeSelected: (size) {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Add to Cart',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: AppTheme.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
