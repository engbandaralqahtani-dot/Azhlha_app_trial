import 'package:flutter/foundation.dart';
import '../models/accident_report.dart';
import '../services/accident_service.dart';

class AccidentReportProvider extends ChangeNotifier {
  final AccidentService _accidentService = AccidentService();
  List<AccidentReport> _reports = [];
  AccidentReport? _currentReport;
  bool _isLoading = false;

  List<AccidentReport> get reports => _reports;
  AccidentReport? get currentReport => _currentReport;
  bool get isLoading => _isLoading;

  Future<void> fetchUserReports(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      _reports = await _accidentService.getUserReports(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createReport(
      AccidentReport report, List<String> imagePaths) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _accidentService.createReport(report, imagePaths);
      await fetchUserReports(report.userId);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    try {
      await _accidentService.updateReportStatus(reportId, status);
      if (_currentReport?.id == reportId) {
        _currentReport = await _accidentService.getReport(reportId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void setCurrentReport(AccidentReport report) {
    _currentReport = report;
    notifyListeners();
  }

  Stream<AccidentReport> streamReport(String reportId) {
    return _accidentService.streamReport(reportId);
  }
}
