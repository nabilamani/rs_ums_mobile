import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../widgets/article_card.dart';
import '../utils/constants.dart';
import 'detail_article.dart';
import 'list_article.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<Article> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getArticles();
      setState(() {
        _articles = response.articles;
        // Sort by views (descending)
        _articles.sort((a, b) => b.views.compareTo(a.views));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(slug: article.slug),
      ),
    );
  }

  void _navigateToAllArticles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleListPage(articles: _articles),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.teal,
      title: Text(
        "Artikel Kesehatan",
        style: AppTextStyles.heading1.copyWith(color: Colors.grey[50]),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.background),
          onPressed: () {
            // TODO: Implement search functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur pencarian akan segera hadir'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_articles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchArticles,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedSection(),
            if (_articles.length > 1) _buildOtherArticlesSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text('Memuat artikel...', style: AppTextStyles.body2),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Gagal memuat artikel",
              style: AppTextStyles.heading2.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Terjadi kesalahan",
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchArticles,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Belum ada artikel",
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingMedium,
            AppSizes.paddingMedium,
            AppSizes.paddingMedium,
            0,
          ),
          child: Text("Artikel Terpopuler", style: AppTextStyles.heading1),
        ),
        FeaturedArticleCard(
          article: _articles[0],
          onTap: () => _navigateToDetail(_articles[0]),
        ),
      ],
    );
  }

  Widget _buildOtherArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingMedium,
            AppSizes.paddingMedium,
            AppSizes.paddingMedium,
            12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Artikel Lainnya", style: AppTextStyles.heading2),
              TextButton(
                onPressed: _navigateToAllArticles,
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
          ),
          child: Column(
            children: _articles
                .skip(1)
                .take(3)
                .map(
                  (article) => ArticleCard(
                    article: article,
                    onTap: () => _navigateToDetail(article),
                    isHorizontal: true,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
