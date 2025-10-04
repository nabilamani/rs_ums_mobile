class Article {
  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String? thumbnail;
  final int views;
  final String? publishedAt;
  final String? createdAt;
  final String? updatedAt;
  final String status;
  final int? categoryId;
  final int? authorId;
  final CategoryArticle? category;

  Article({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    this.thumbnail,
    this.views = 0,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.status = 'published',
    this.categoryId,
    this.authorId,
    this.category,
  });

  // Factory method untuk membuat object dari JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      excerpt: json['excerpt'],
      content: json['content'],
      thumbnail: json['thumbnail'],
      views: json['views'] ?? 0,
      publishedAt: json['published_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      status: json['status'] ?? 'published',
      categoryId: json['category_id'],
      authorId: json['author_id'],
      category: json['category'] != null 
          ? CategoryArticle.fromJson(json['category'])
          : null,
    );
  }

  // Method untuk convert object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'thumbnail': thumbnail,
      'views': views,
      'published_at': publishedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
      'category_id': categoryId,
      'author_id': authorId,
      'category': category?.toJson(),
    };
  }

  // Helper untuk mendapatkan full URL thumbnail
  String getThumbnailUrl(String baseStorageUrl) {
    if (thumbnail == null || thumbnail!.isEmpty) return '';
    return '$baseStorageUrl/$thumbnail';
  }

  // Copy with method untuk immutability
  Article copyWith({
    int? id,
    String? title,
    String? slug,
    String? excerpt,
    String? content,
    String? thumbnail,
    int? views,
    String? publishedAt,
    String? createdAt,
    String? updatedAt,
    String? status,
    int? categoryId,
    int? authorId,
    CategoryArticle? category,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      views: views ?? this.views,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      authorId: authorId ?? this.authorId,
      category: category ?? this.category,
    );
  }
}

// Model untuk Category Article
class CategoryArticle {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  CategoryArticle({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryArticle.fromJson(Map<String, dynamic> json) {
    return CategoryArticle(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Response wrapper untuk API
class ArticlesResponse {
  final List<Article> articles;
  final int total;
  final int currentPage;
  final int lastPage;

  ArticlesResponse({
    required this.articles,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory ArticlesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ArticlesResponse(
      articles: (data['data'] as List)
          .map((item) => Article.fromJson(item))
          .toList(),
      total: data['total'] ?? 0,
      currentPage: data['current_page'] ?? 1,
      lastPage: data['last_page'] ?? 1,
    );
  }
}

// Response wrapper untuk single article (detail)
class ArticleDetailResponse {
  final Article article;

  ArticleDetailResponse({
    required this.article,
  });

  factory ArticleDetailResponse.fromJson(Map<String, dynamic> json) {
    return ArticleDetailResponse(
      article: Article.fromJson(json['data']),
    );
  }
}