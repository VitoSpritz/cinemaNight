import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget implements Icon {
  @override
  final IconData icon;
  final VoidCallback? onTap;
  final double iconSize;
  @override
  final Color color;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.iconSize = 60,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 60,
        height: 100,
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }

  @override
  // TODO: implement applyTextScaling
  bool? get applyTextScaling => throw UnimplementedError();

  @override
  // TODO: implement blendMode
  BlendMode? get blendMode => throw UnimplementedError();

  @override
  // TODO: implement fill
  double? get fill => throw UnimplementedError();

  @override
  // TODO: implement fontWeight
  FontWeight? get fontWeight => throw UnimplementedError();

  @override
  // TODO: implement grade
  double? get grade => throw UnimplementedError();

  @override
  // TODO: implement opticalSize
  double? get opticalSize => throw UnimplementedError();

  @override
  // TODO: implement semanticLabel
  String? get semanticLabel => throw UnimplementedError();

  @override
  // TODO: implement shadows
  List<Shadow>? get shadows => throw UnimplementedError();

  @override
  // TODO: implement size
  double? get size => throw UnimplementedError();

  @override
  // TODO: implement textDirection
  TextDirection? get textDirection => throw UnimplementedError();

  @override
  // TODO: implement weight
  double? get weight => throw UnimplementedError();
}
