import 'package:flutter/material.dart';
import '../models/article.dart';
import '../utils/constants.dart';

class CategoryBadge extends StatelessWidget {
  final CategoryArticle? category;
  final double fontSize;
  final EdgeInsets padding;

  const CategoryBadge({
    super.key,
    required this.category,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (category == null) return const SizedBox.shrink();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label_outline,
            size: fontSize + 2,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            category!.name,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}