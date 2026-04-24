// lib/widgets/star_rating.dart
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final void Function(double)? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final isFilled = i < rating.floor();
        final isHalf = !isFilled && i < rating;
        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(i + 1.0)
              : null,
          child: Icon(
            isFilled
                ? Icons.star
                : isHalf
                    ? Icons.star_half
                    : Icons.star_border,
            color: AppTheme.warningColor,
            size: size,
          ),
        );
      }),
    );
  }
}
