import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class CarImage extends StatelessWidget {
  const CarImage({super.key, required this.source, required this.fit, required this.placeholder});

  final String source;
  final BoxFit fit;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final imageSource = source.trim();
    if (imageSource.isEmpty) {
      return placeholder;
    }

    if (imageSource.startsWith('http://') || imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    final memoryImage = _decodeMemoryImage(imageSource);
    if (memoryImage != null) {
      return Image.memory(
        memoryImage,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return Image.file(
      File(imageSource),
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Uint8List? _decodeMemoryImage(String imageSource) {
    if (imageSource.startsWith('data:')) {
      final commaIndex = imageSource.indexOf(',');
      if (commaIndex == -1) return null;
      return base64Decode(imageSource.substring(commaIndex + 1));
    }

    try {
      return base64Decode(imageSource);
    } catch (_) {
      return null;
    }
  }
}