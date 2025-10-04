import 'package:flutter/material.dart';

class ApiConstants {
  static const String baseUrl = 'http://192.168.167.141:8000';
  static const String apiVersion = '/api/v1';
  static const String articlesEndpoint = '$apiVersion/articles';
  static const String schedulesEndpoint = '$apiVersion/schedules';
  static const String storageUrl = '$baseUrl/storage';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class AppColors {
  static const primary = Color(0xFF009688); // Teal
  static const secondary = Color(0xFF00796B);
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF388E3C);
  static const background = Color(0xFFF5F5F5);
  static const cardBackground = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
}