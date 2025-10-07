// lib/features/presensi/domain/repositories/presensi_repository.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/presensi_model.dart';
import '../../../../services/location_service.dart';

class PresensiRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocationService _locationService;

  PresensiRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _locationService = locationService ?? LocationService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if today is a working day (Monday-Friday)
  bool isWorkingDay(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  // Get start and end of day
  Map<String, DateTime> getDayRange(DateTime date) {
    return {
      'start': DateTime(date.year, date.month, date.day, 0, 0, 0),
      'end': DateTime(date.year, date.month, date.day, 23, 59, 59),
    };
  }

  // Check if user has already checked in today
  Future<PresensiModel?> getTodayPresensi() async {
    final user = currentUser;
    if (user == null) return null;

    final today = DateTime.now();

    try {
      final snapshot = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isEmpty) return null;

      for (var doc in snapshot.docs) {
        final presensi = PresensiModel.fromFirestore(doc);
        
        if (presensi.tanggal.year == today.year &&
            presensi.tanggal.month == today.month &&
            presensi.tanggal.day == today.day) {
          return presensi;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data presensi hari ini: $e');
    }
  }

  // Determine status based on check-in time and day
  String determineStatus(DateTime checkInDateTime) {
    if (!isWorkingDay(checkInDateTime)) {
      return 'Hadir';
    }

    final checkInTime = TimeOfDay.fromDateTime(checkInDateTime);
    const lateTimeLimit = TimeOfDay(hour: 8, minute: 0);

    final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
    final lateMinutes = lateTimeLimit.hour * 60 + lateTimeLimit.minute;

    return checkInMinutes > lateMinutes ? 'Terlambat' : 'Hadir';
  }

  // Validate location before check-in/check-out
  Future<LocationData> validateLocation() async {
    try {
      // Check if within hospital area
      final isWithinArea = await _locationService.isWithinHospitalArea();
      
      if (!isWithinArea) {
        final distance = await _locationService.getDistanceFromHospital();
        final formattedDistance = _locationService.formatDistance(distance);
        throw Exception(
          'Anda berada di luar area rumah sakit.\nJarak Anda: $formattedDistance dari RS',
        );
      }

      // Get location data
      return await _locationService.getLocationData();
    } catch (e) {
      if (e.toString().contains('Anda berada di luar area')) {
        rethrow;
      }
      throw Exception('Gagal mendapatkan lokasi: ${e.toString()}');
    }
  }

  // Create new presensi (check-in) with location validation
  Future<PresensiModel> checkIn() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    // Check if already checked in today
    final existingPresensi = await getTodayPresensi();
    if (existingPresensi != null) {
      throw Exception('Anda sudah melakukan presensi hari ini');
    }

    // Validate location
    final locationData = await validateLocation();

    final now = DateTime.now();
    final status = determineStatus(now);

    final presensi = PresensiModel(
      userId: user.uid,
      userEmail: user.email ?? '',
      tanggal: now,
      checkIn: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      status: status,
      checkInLocation: locationData,
      createdAt: now,
    );

    try {
      final docRef = await _firestore
          .collection('presensi')
          .add(presensi.toFirestore());

      return presensi.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Gagal melakukan check-in: $e');
    }
  }

  // Update presensi (check-out) with location validation
  Future<PresensiModel> checkOut(String presensiId) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    // Validate location
    final locationData = await validateLocation();

    final now = DateTime.now();
    final checkOutTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    try {
      await _firestore.collection('presensi').doc(presensiId).update({
        'checkOut': checkOutTime,
        'checkOutLocation': locationData.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _firestore.collection('presensi').doc(presensiId).get();
      return PresensiModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal melakukan check-out: $e');
    }
  }

  // Get presensi statistics
  Future<PresensiStats> getStats() async {
    final user = currentUser;
    if (user == null) {
      return PresensiStats.empty();
    }

    try {
      final snapshot = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: user.uid)
          .get();

      int hadir = 0;
      int terlambat = 0;
      int absen = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] ?? '';
        switch (status) {
          case 'Hadir':
            hadir++;
            break;
          case 'Terlambat':
            terlambat++;
            break;
          case 'Absent':
            absen++;
            break;
        }
      }

      return PresensiStats(
        hadirCount: hadir,
        terlambatCount: terlambat,
        absenCount: absen,
      );
    } catch (e) {
      throw Exception('Gagal memuat statistik: $e');
    }
  }

  // Get presensi history
  Future<List<PresensiModel>> getHistory({int limit = 5}) async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: user.uid)
          .get();

      final presensiList = snapshot.docs
          .map((doc) => PresensiModel.fromFirestore(doc))
          .toList();

      presensiList.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      return presensiList.take(limit).toList();
    } catch (e) {
      throw Exception('Gagal memuat riwayat presensi: $e');
    }
  }

  // Get location service instance (for UI to check distance)
  LocationService get locationService => _locationService;
}