import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tospino_models.dart';
import '../tospino_style.dart';

class TospinoProductGallery extends StatefulWidget {
  const TospinoProductGallery({
    super.key,
    required this.product,
    required this.imageUrls,
    required this.height,
    this.imageAspectRatio,
  });

  final TospinoProduct product;
  final List<String> imageUrls;
  final double height;
  final double? imageAspectRatio;

  @override
  State<TospinoProductGallery> createState() => _TospinoProductGalleryState();
}

class _TospinoProductGalleryState extends State<TospinoProductGallery> {
  final PageController _controller = PageController();
  int _index = 0;
  double? _imageAspectRatio;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  String? _resolvedImageUrl;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImageRatio();
  }

  @override
  void didUpdateWidget(TospinoProductGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id ||
        !_sameUrls(oldWidget.imageUrls, widget.imageUrls) ||
        oldWidget.imageAspectRatio != widget.imageAspectRatio) {
      _index = 0;
      _imageAspectRatio = widget.imageAspectRatio;
      _resolvedImageUrl = null;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
      _resolveImageRatio();
    }
  }

  @override
  void dispose() {
    _removeImageListener();
    _controller.dispose();
    super.dispose();
  }

  void _resolveImageRatio() {
    final configuredRatio = widget.imageAspectRatio;
    if (configuredRatio != null && configuredRatio > 0) {
      _removeImageListener();
      _imageAspectRatio = configuredRatio;
      return;
    }
    final imageUrls = _imageUrls;
    if (imageUrls.isEmpty) {
      _removeImageListener();
      _resolvedImageUrl = null;
      _imageAspectRatio = null;
      return;
    }
    final imageUrl = imageUrls.first;
    if (_resolvedImageUrl == imageUrl && _imageListener != null) return;
    _removeImageListener();
    _resolvedImageUrl = imageUrl;
    final stream = NetworkImage(
      imageUrl,
    ).resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, synchronousCall) {
      final width = info.image.width;
      final height = info.image.height;
      if (width <= 0 || height <= 0 || _imageListener != listener) return;
      _setImageRatio(height / width, synchronousCall);
    }, onError: (_, _) {});
    _imageStream = stream;
    _imageListener = listener;
    stream.addListener(listener);
  }

  void _setImageRatio(double ratio, bool synchronousCall) {
    if (!mounted) return;
    if (synchronousCall) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _imageAspectRatio = ratio);
      });
    } else {
      setState(() => _imageAspectRatio = ratio);
    }
  }

  void _removeImageListener() {
    final listener = _imageListener;
    if (listener != null) _imageStream?.removeListener(listener);
    _imageStream = null;
    _imageListener = null;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = _imageUrls;
    final indicatorCount = imageUrls.length.clamp(1, 8);
    final activeIndicator = imageUrls.length <= 8
        ? _index
        : ((_index / (imageUrls.length - 1)) * (indicatorCount - 1)).round();
    if (imageUrls.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: TospinoProductArtwork(
          product: widget.product,
          height: widget.height,
          radius: 0,
          hero: false,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = MediaQuery.sizeOf(context);
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : viewport.width;
        final height = tospinoProductGalleryHeight(
          width: width,
          viewportHeight: viewport.height,
          fallbackHeight: widget.height,
          imageAspectRatio: _imageAspectRatio,
        );
        return AnimatedContainer(
          key: const Key('tospino-product-gallery-frame'),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: height,
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
                  height: height,
                  radius: 0,
                  hero: false,
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 128,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x7A000000), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              if (imageUrls.length > 1)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 92,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x66000000)],
                        ),
                      ),
                    ),
                  ),
                ),
              if (imageUrls.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var index = 0; index < indicatorCount; index++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            width: index == activeIndicator ? 16 : 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: index == activeIndicator
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.52),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (imageUrls.length > 1)
                Positioned(
                  right: 14,
                  bottom: 11,
                  child: Container(
                    key: const Key('tospino-product-gallery-counter'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x990F1A1D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
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
      },
    );
  }
}

double tospinoProductGalleryHeight({
  required double width,
  required double viewportHeight,
  required double fallbackHeight,
  double? imageAspectRatio,
}) {
  final minimum = width * 0.55;
  final maximum = math.max(
    minimum,
    math.min(width * 1.7, viewportHeight * 0.66),
  );
  final ratio = imageAspectRatio;
  final desired = ratio != null && ratio.isFinite && ratio > 0
      ? width * ratio
      : fallbackHeight;
  return desired.clamp(minimum, maximum).toDouble();
}

bool _sameUrls(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
