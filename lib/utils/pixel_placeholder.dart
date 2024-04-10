import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PixelPlaceholder extends StatelessWidget {
  const PixelPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpinKitWanderingCubes(
      color: Colors.white,
      size: 20,
    );
  }
}
