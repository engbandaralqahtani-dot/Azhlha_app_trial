import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/accident_report.dart';

class AccidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> createReport(
      AccidentReport report, List<String> imagePaths) async {
    try {
      // Upload images
      List<String> imageUrls = [];
      for (String path in imagePaths) {
        String fileName =
            'accidents/${report.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref = _storage.ref().child(fileName);
        await ref.putFile(File(path));
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Create report with image URLs
      final reportWithImages = AccidentReport(
        id: report.id,
        userId: report.userId,
        description: report.description,
        timestamp: report.timestamp,
        latitude: report.latitude,
        longitude: report.longitude,
        images: imageUrls,
        status: 'pending',
        statusTimeline: {
          'reported': DateTime.now(),
        },
      );

      await _firestore
          .collection('accidents')
          .doc(report.id)
          .set(reportWithImages.toMap());

      return report.id;
    } catch (e) {
      throw Exception('فشل في إنشاء البلاغ: $e');
    }
  }

  Future<AccidentReport> getReport(String reportId) async {
    try {
      final doc = await _firestore.collection('accidents').doc(reportId).get();
      if (!doc.exists) {
        throw Exception('البلاغ غير موجود');
      }
      return AccidentReport.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('فشل في جلب البلاغ: $e');
    }
  }

  Future<List<AccidentReport>> getUserReports(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('accidents')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AccidentReport.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب البلاغات: $e');
    }
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    try {
      await _firestore.collection('accidents').doc(reportId).update({
        'status': status,
        'statusTimeline.$status': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('فشل في تحديث حالة البلاغ: $e');
    }
  }

  Stream<AccidentReport> streamReport(String reportId) {
    return _firestore
        .collection('accidents')
        .doc(reportId)
        .snapshots()
        .map((doc) => AccidentReport.fromMap(doc.data()!));
  }

  Future<void> assignTowTruck(String reportId, String towTruckId) async {
    try {
      await _firestore.collection('accidents').doc(reportId).update({
        'towTruckId': towTruckId,
        'status': 'assigned',
        'statusTimeline.assigned': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('فشل في تعيين سيارة السحب: $e');
    }
  }

  Future<void> assignRepairShop(String reportId, String repairShopId) async {
    try {
      await _firestore.collection('accidents').doc(reportId).update({
        'repairShopId': repairShopId,
        'status': 'in_repair',
        'statusTimeline.in_repair': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('فشل في تعيين ورشة الإصلاح: $e');
    }
  }
}
