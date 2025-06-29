import 'package:flutter/material.dart';

class BookImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double iconSize;
  final BoxFit fit;

  const BookImageWidget({
    super.key,
    required this.imageUrl,
    this.iconSize = 60,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.book,
          size: iconSize,
          color: Colors.grey,
        ),
      );
    }

    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return Image.network(
        imageUrl!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.book,
              size: iconSize,
              color: Colors.grey,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.book,
              size: iconSize,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }
}
