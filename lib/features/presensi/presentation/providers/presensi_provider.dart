// lib/features/presensi/presentation/providers/presensi_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/models/presensi_model.dart';
import '../../domain/repositories/presensi_repository.dart';

class PresensiProvider with ChangeNotifier {
  final PresensiRepository _repository;

  PresensiProvider({PresensiRepository? repository})
      : _repository = repository ?? PresensiRepository();

  // State
  PresensiModel? _todayPresensi;
  PresensiStats _stats = PresensiStats.empty();
  List<PresensiModel> _history = [];
  
  bool _isLoading = false;
  bool _isLoadingStats = false;
  String? _error;

  // Getters
  PresensiModel? get todayPresensi => _todayPresensi;
  PresensiStats get stats => _stats;
  List<PresensiModel> get history => _history;
  bool get isLoading => _isLoading;
  bool get isLoadingStats => _isLoadingStats;
  String? get error => _error;
  bool get isCheckedIn => _todayPresensi != null;
  bool get hasCheckedOut => _todayPresensi?.checkOut != null;

  // Initialize - load all data
  Future<void> initialize() async {
    await Future.wait([
      loadTodayPresensi(),
      loadStats(),
      loadHistory(),
    ]);
  }

  // Load today's presensi
  Future<void> loadTodayPresensi() async {
    try {
      _error = null;
      _todayPresensi = await _repository.getTodayPresensi();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load statistics
  Future<void> loadStats() async {
    try {
      _isLoadingStats = true;
      _error = null;
      notifyListeners();

      _stats = await _repository.getStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // Load history
  Future<void> loadHistory() async {
    try {
      _error = null;
      _history = await _repository.getHistory(limit: 5);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check in with location validation
  Future<bool> checkIn() async {
    if (_repository.currentUser == null) {
      _error = 'Anda belum login';
      notifyListeners();
      return false;
    }

    // Validate: only one presensi per day
    if (_todayPresensi != null) {
      _error = 'Anda sudah melakukan presensi hari ini';
      notifyListeners();
      return false;
    }

    // Validate: only working days (Monday-Friday)
    final now = DateTime.now();
    if (!_repository.isWorkingDay(now)) {
      _error = 'Presensi hanya dapat dilakukan pada hari Senin-Jumat';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // This will validate location and throw exception if outside area
      _todayPresensi = await _repository.checkIn();
      
      // Reload stats and history
      await Future.wait([
        loadStats(),
        loadHistory(),
      ]);

      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check out with location validation
  Future<bool> checkOut() async {
    if (_todayPresensi == null) {
      _error = 'Anda belum check-in hari ini';
      notifyListeners();
      return false;
    }

    if (_todayPresensi!.checkOut != null) {
      _error = 'Anda sudah check-out hari ini';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // This will validate location and throw exception if outside area
      _todayPresensi = await _repository.checkOut(_todayPresensi!.id!);
      
      // Reload history
      await loadHistory();

      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get distance from hospital
  Future<double> getDistanceFromHospital() async {
    try {
      return await _repository.locationService.getDistanceFromHospital();
    } catch (e) {
      throw Exception('Gagal mendapatkan jarak: ${e.toString()}');
    }
  }

  // Format distance for display
  String formatDistance(double meters) {
    return _repository.locationService.formatDistance(meters);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    await initialize();
  }
}