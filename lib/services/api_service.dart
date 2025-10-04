import 'package:dio/dio.dart';
import '../models/article.dart';
import '../utils/constants.dart';

class ApiService {
  late final Dio _dio;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // Add interceptors untuk logging (opsional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // Getter untuk Dio instance jika dibutuhkan di tempat lain
  Dio get dio => _dio;

  // ========== ARTICLE ENDPOINTS ==========
  
  /// Fetch all articles
  Future<ArticlesResponse> getArticles({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.articlesEndpoint,
        queryParameters: {'page': page},
      );
      
      if (response.statusCode == 200) {
        return ArticlesResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load articles');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch article by slug
  Future<Article> getArticleBySlug(String slug) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.articlesEndpoint}/$slug',
      );
      
      if (response.statusCode == 200) {
        final detailResponse = ArticleDetailResponse.fromJson(response.data);
        return detailResponse.article;
      } else {
        throw Exception('Failed to load article');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search articles
  Future<List<Article>> searchArticles(String query) async {
    try {
      final response = await _dio.get(
        ApiConstants.articlesEndpoint,
        queryParameters: {'search': query},
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data']['data'] as List;
        return data.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search articles');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== SCHEDULE ENDPOINTS ==========
  
  /// Fetch doctor schedules
  Future<Map<String, dynamic>> getSchedules() async {
    try {
      final response = await _dio.get(ApiConstants.schedulesEndpoint);
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load schedules');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== ERROR HANDLING ==========
  
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data not found.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Request failed with status code: $statusCode';
      
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'No internet connection.';
        }
        return 'Unexpected error occurred.';
      
      default:
        return 'Something went wrong.';
    }
  }
}