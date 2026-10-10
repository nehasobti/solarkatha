import 'package:flutter/material.dart';

/// The SolarKatha logo (same artwork as the app icon), with rounded corners.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * 0.24),
    child: Image.asset(
      'assets/icon/icon.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      cacheWidth: (size * 3).round(),
    ),
  );
}
