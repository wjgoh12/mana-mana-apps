import 'package:flutter/material.dart';

class GradientText1 extends StatelessWidget {
  const GradientText1({
    super.key,
    required this.text,
    this.style,
    required this.gradient,
  });
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}