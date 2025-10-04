import 'package:flutter/material.dart';
import '../models/article.dart';
import '../utils/constants.dart';
import 'category_badge.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final bool isHorizontal;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    return isHorizontal ? _buildHorizontalCard() : _buildVerticalCard();
  }

  Widget _buildHorizontalCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(120, 140, isHorizontal: true),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: AppTextStyles.body1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (article.excerpt != null)
                      Text(
                        article.excerpt!,
                        style: AppTextStyles.body2.copyWith(height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (article.category != null) ...[
                          CategoryBadge(category: article.category),
                          const SizedBox(width: 8),
                        ],
                        Expanded(child: _buildViewsCount()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(double.infinity, 180, isHorizontal: false),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.category != null) ...[
                    CategoryBadge(category: article.category),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    article.title,
                    style: AppTextStyles.body1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (article.excerpt != null)
                    Text(
                      article.excerpt!,
                      style: AppTextStyles.body2.copyWith(height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Baca selengkapnya",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(
    double width,
    double height, {
    required bool isHorizontal,
  }) {
    final imageUrl = article.getThumbnailUrl(ApiConstants.storageUrl);

    return ClipRRect(
      borderRadius: isHorizontal
          ? const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusLarge),
              bottomLeft: Radius.circular(AppSizes.radiusLarge),
            )
          : const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusLarge),
              topRight: Radius.circular(AppSizes.radiusLarge),
            ),
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 40),
            ),
          ),
          if (!isHorizontal)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${article.views}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewsCount() {
    return Row(
      children: [
        Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text("${article.views} views", style: AppTextStyles.caption),
      ],
    );
  }
}

// Featured Article Card (untuk artikel populer)
class FeaturedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.getThumbnailUrl(ApiConstants.storageUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 60),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusXLarge,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Populer • ${article.views} views",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        article.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (article.excerpt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          article.excerpt!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
