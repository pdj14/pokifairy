import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

/// Renders a Lottie animation with graceful fallback when the asset is missing.
class SafeLottie extends StatelessWidget {
  /// Creates a [SafeLottie] instance.
  const SafeLottie({
    super.key,
    required this.asset,
    this.repeat = true,
    required this.fallback,
  });

  /// Asset path to the Lottie animation.
  final String asset;

  /// Whether the animation should repeat.
  final bool repeat;

  /// Widget rendered when the asset cannot be loaded.
  final Widget fallback;

  Future<bool> _assetExists() async {
    try {
      await rootBundle.load(asset);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return fallback;
        }
        if (!(snapshot.data ?? false)) {
          return fallback;
        }
        return Lottie.asset(
          asset,
          repeat: repeat,
          errorBuilder: (context, error, stackTrace) => fallback,
        );
      },
    );
  }
}
