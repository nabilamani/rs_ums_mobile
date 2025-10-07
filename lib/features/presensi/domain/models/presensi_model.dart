// lib/features/presensi/domain/models/presensi_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PresensiModel {
  final String? id;
  final String userId;
  final String userEmail;
  final DateTime tanggal;
  final String checkIn;
  final String? checkOut;
  final String status;
  final LocationData? checkInLocation;
  final LocationData? checkOutLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PresensiModel({
    this.id,
    required this.userId,
    required this.userEmail,
    required this.tanggal,
    required this.checkIn,
    this.checkOut,
    required this.status,
    this.checkInLocation,
    this.checkOutLocation,
    this.createdAt,
    this.updatedAt,
  });

  factory PresensiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PresensiModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      checkIn: data['checkIn'] ?? '',
      checkOut: data['checkOut'],
      status: data['status'] ?? '',
      checkInLocation: data['checkInLocation'] != null
          ? LocationData.fromMap(data['checkInLocation'])
          : null,
      checkOutLocation: data['checkOutLocation'] != null
          ? LocationData.fromMap(data['checkOutLocation'])
          : null,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'tanggal': Timestamp.fromDate(tanggal),
      'checkIn': checkIn,
      'checkOut': checkOut,
      'status': status,
      'checkInLocation': checkInLocation?.toMap(),
      'checkOutLocation': checkOutLocation?.toMap(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PresensiModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    DateTime? tanggal,
    String? checkIn,
    String? checkOut,
    String? status,
    LocationData? checkInLocation,
    LocationData? checkOutLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PresensiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      tanggal: tanggal ?? this.tanggal,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String address;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.address,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'address': address,
    };
  }
}

class PresensiStats {
  final int hadirCount;
  final int terlambatCount;
  final int absenCount;

  PresensiStats({
    required this.hadirCount,
    required this.terlambatCount,
    required this.absenCount,
  });

  factory PresensiStats.empty() {
    return PresensiStats(
      hadirCount: 0,
      terlambatCount: 0,
      absenCount: 0,
    );
  }
}