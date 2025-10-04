import 'package:flutter/material.dart';
import '../models/article.dart';
import '../widgets/article_card.dart';
import '../utils/constants.dart';
import 'detail_article.dart';

class ArticleListPage extends StatefulWidget {
  final List<Article> articles;

  const ArticleListPage({
    super.key,
    required this.articles,
  });

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  String _searchQuery = '';
  String _sortBy = 'latest'; // 'latest' or 'popular'
  final TextEditingController _searchController = TextEditingController();

  List<Article> get _filteredArticles {
    var filtered = widget.articles.where((article) {
      if (_searchQuery.isEmpty) return true;
      return article.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (article.excerpt ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort based on selection
    if (_sortBy == 'popular') {
      filtered.sort((a, b) => b.views.compareTo(a.views));
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(slug: article.slug),
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
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
      backgroundColor: AppColors.cardBackground,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Semua Artikel",
        style: AppTextStyles.heading1.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        AppSizes.paddingSmall,
        AppSizes.paddingMedium,
        12,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari artikel...',
          hintStyle: AppTextStyles.body2,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        0,
        AppSizes.paddingMedium,
        12,
      ),
      child: Row(
        children: [
          const Text(
            "Urutkan:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChoiceChip(
                    label: 'Terbaru',
                    value: 'latest',
                    icon: Icons.schedule,
                  ),
                  const SizedBox(width: 8),
                  _buildChoiceChip(
                    label: 'Terpopuler',
                    value: 'popular',
                    icon: Icons.trending_up,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildBody() {
    if (_filteredArticles.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildResultCount(),
        Expanded(child: _buildArticleList()),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.article_outlined : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "Tidak ada artikel"
                : "Artikel tidak ditemukan",
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Coba kata kunci lain',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Hapus Pencarian'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        12,
        AppSizes.paddingMedium,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${_filteredArticles.length} artikel ditemukan",
            style: AppTextStyles.body2,
          ),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: _clearSearch,
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArticleList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        0,
        AppSizes.paddingMedium,
        AppSizes.paddingMedium,
      ),
      itemCount: _filteredArticles.length,
      itemBuilder: (context, index) {
        final article = _filteredArticles[index];
        return ArticleCard(
          article: article,
          onTap: () => _navigateToDetail(article),
          isHorizontal: false, // Vertical layout for list page
        );
      },
    );
  }
}