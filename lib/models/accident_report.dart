class AccidentReport {
  final String id;
  final String userId;
  final String description;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String status;
  final String? towTruckId;
  final String? repairShopId;
  final Map<String, DateTime> statusTimeline;

  AccidentReport({
    required this.id,
    required this.userId,
    required this.description,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.status,
    this.towTruckId,
    this.repairShopId,
    required this.statusTimeline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'status': status,
      'towTruckId': towTruckId,
      'repairShopId': repairShopId,
      'statusTimeline': statusTimeline.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  factory AccidentReport.fromMap(Map<String, dynamic> map) {
    return AccidentReport(
      id: map['id'],
      userId: map['userId'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      images: List<String>.from(map['images']),
      status: map['status'],
      towTruckId: map['towTruckId'],
      repairShopId: map['repairShopId'],
      statusTimeline: (map['statusTimeline'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DateTime.parse(value)),
      ),
    );
  }
}
