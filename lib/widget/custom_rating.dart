import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomRating extends ConsumerStatefulWidget {
  final double initialRating;
  final int maxRating;
  final Function(double) onRatingChanged;
  final double iconSize;

  const CustomRating({
    super.key,
    this.initialRating = 0.0,
    this.maxRating = 5,
    required this.onRatingChanged,
    this.iconSize = 24,
  });

  @override
  ConsumerState<CustomRating> createState() => _CustomRatingState();
}

class _CustomRatingState extends ConsumerState<CustomRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating.toDouble();
  }

  void _handleTap(int index, Offset localPosition, double iconWidth) {
    final double tapPosition = localPosition.dx;
    final double halfIcon = iconWidth / 2;
    final bool isLeftHalf = tapPosition < halfIcon;

    double newRating = index.toDouble();
    if (isLeftHalf) {
      newRating += 0.5;
    } else {
      newRating += 1.0;
    }

    if (_currentRating == newRating) {
      newRating = newRating - 0.5;
    }

    newRating = newRating.clamp(0.0, widget.maxRating.toDouble());

    setState(() => _currentRating = newRating);
    widget.onRatingChanged(_currentRating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (int index) {
        final double fillLevel = _currentRating - index;

        return GestureDetector(
          onTapDown: (TapDownDetails details) {
            _handleTap(index, details.localPosition, widget.iconSize);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Stack(
              children: <Widget>[
                // Background (empty) icon
                Icon(Icons.movie, size: widget.iconSize, color: Colors.grey),
                // Foreground (filled) icon, clipped based on fillLevel
                if (fillLevel > 0)
                  ClipRect(
                    clipper: _HalfClipper(fillLevel),
                    child: Icon(
                      Icons.movie,
                      size: widget.iconSize,
                      color: Colors.amber,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final double fillLevel;

  _HalfClipper(this.fillLevel);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      0,
      size.width * fillLevel.clamp(0.0, 1.0),
      size.height,
    );
  }

  @override
  bool shouldReclip(_HalfClipper oldClipper) =>
      oldClipper.fillLevel != fillLevel;
}
