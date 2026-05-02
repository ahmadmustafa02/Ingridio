import 'package:flutter/material.dart';

/// Enhanced image widget with caching, lazy loading, and placeholder support
class CachedRecipeImage extends StatelessWidget {
  const CachedRecipeImage({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    required this.errorWidget,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.width,
    this.height,
  });

  final String imageUrl;
  final Widget placeholder;
  final Widget errorWidget;
  final BoxFit fit;
  final double borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider>(
      future: _loadImage(),
      builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image(
            image: snapshot.data!,
            fit: fit,
            width: width,
            height: height,
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            width: width,
            height: height,
            child: errorWidget,
          );
        }
        
        return SizedBox(
          width: width,
          height: height,
          child: placeholder,
        );
      },
    );
  }

  Future<ImageProvider> _loadImage() async {
    try {
      if (_dummyContext != null) {
        await precacheImage(NetworkImage(imageUrl), _dummyContext!);
      }
      return NetworkImage(imageUrl);
    } catch (_) {
      rethrow;
    }
  }

  static BuildContext? _dummyContext;

  static void initializeDummyContext(BuildContext context) {
    _dummyContext = context;
  }
}

/// Optimized recipe product image with fade-in animation
class OptimizedRecipeImage extends StatelessWidget {
  const OptimizedRecipeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
    this.height = 250,
    this.loadingColor = const Color(0xFFFFF1E9),
  });

  final String imageUrl;
  final BoxFit fit;
  final double borderRadius;
  final double height;
  final Color loadingColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        color: loadingColor,
        child: Image.network(
          imageUrl,
          fit: fit,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            }
            return Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Container(
              color: loadingColor,
              child: const Icon(
                Icons.image_not_supported_rounded,
                size: 48,
                color: Color(0xFFE0C0B1),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Skeleton loader for recipe images
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 250,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Color.lerp(
                const Color(0xFFFFF1E9),
                const Color(0xFFFFE3D1),
                _animation.value,
              ),
            ),
          );
        },
      ),
    );
  }
}
