import 'package:flutter/material.dart';

import '../tospino_models.dart';
import '../tospino_style.dart';

class TospinoProductGallery extends StatefulWidget {
  const TospinoProductGallery({
    super.key,
    required this.product,
    required this.imageUrls,
    required this.height,
  });

  final TospinoProduct product;
  final List<String> imageUrls;
  final double height;

  @override
  State<TospinoProductGallery> createState() => _TospinoProductGalleryState();
}

class _TospinoProductGalleryState extends State<TospinoProductGallery> {
  final PageController _controller = PageController();
  int _index = 0;

  List<String> get _imageUrls {
    final urls = <String>{
      for (final url in widget.imageUrls)
        if (url.trim().isNotEmpty) url.trim(),
      if (widget.product.imageUrl.trim().isNotEmpty)
        widget.product.imageUrl.trim(),
    }.toList(growable: false);
    return urls;
  }

  @override
  void didUpdateWidget(TospinoProductGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id ||
        !_sameUrls(oldWidget.imageUrls, widget.imageUrls)) {
      _index = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = _imageUrls;
    if (imageUrls.isEmpty) {
      return TospinoProductArtwork(
        product: widget.product,
        height: widget.height,
        radius: 0,
        hero: false,
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            key: const Key('tospino-product-gallery-pages'),
            controller: _controller,
            itemCount: imageUrls.length,
            allowImplicitScrolling: imageUrls.length > 1,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) => TospinoProductArtwork(
              product: widget.product,
              imageUrl: imageUrls[index],
              height: widget.height,
              radius: 0,
              hero: false,
            ),
          ),
          if (imageUrls.length > 1)
            Positioned(
              right: 14,
              bottom: 12,
              child: Container(
                key: const Key('tospino-product-gallery-counter'),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_index + 1} / ${imageUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: TospinoText.emphasis,
                    height: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

bool _sameUrls(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
