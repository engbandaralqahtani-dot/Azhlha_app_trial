import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/accident_report.dart';
import '../providers/accident_provider.dart';

class ReportDetailsSheet extends StatelessWidget {
  final String reportId;

  const ReportDetailsSheet({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: StreamBuilder<AccidentReport>(
            stream:
                context.read<AccidentReportProvider>().streamReport(reportId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('حدث خطأ: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final report = snapshot.data!;
              return ListView(
                controller: controller,
                children: [
                  _buildHeader(report),
                  const SizedBox(height: 24),
                  _buildStatusTimeline(report),
                  const SizedBox(height: 24),
                  _buildDetails(report),
                  const SizedBox(height: 24),
                  if (report.images.isNotEmpty) ...[
                    _buildImages(report),
                    const SizedBox(height: 24),
                  ],
                  _buildLocationMap(report),
                  const SizedBox(height: 24),
                  _buildActions(context, report),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(AccidentReport report) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          'بلاغ #${report.id}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(AccidentReport report) {
    final statuses = [
      {'key': 'reported', 'title': 'تم الإبلاغ', 'icon': Icons.report},
      {
        'key': 'assigned',
        'title': 'تم تعيين سيارة سحب',
        'icon': Icons.local_shipping
      },
      {'key': 'picked_up', 'title': 'تم السحب', 'icon': Icons.car_crash},
      {'key': 'in_repair', 'title': 'في الورشة', 'icon': Icons.build},
      {'key': 'completed', 'title': 'اكتمل', 'icon': Icons.check_circle},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'حالة البلاغ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(statuses.length, (index) {
          final status = statuses[index];
          final isCompleted = report.statusTimeline.containsKey(status['key']);
          final isLast = index == statuses.length - 1;

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status['icon'] as IconData,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: isCompleted ? Colors.green : Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (isCompleted)
                      Text(
                        _formatTimestamp(report.statusTimeline[status['key']]!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    SizedBox(height: isLast ? 0 : 16),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDetails(AccidentReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل الحادث',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(report.description),
          ],
        ),
      ),
    );
  }

  Widget _buildImages(AccidentReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الصور',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: report.images.length,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(report.images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMap(AccidentReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الموقع',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(report.latitude, report.longitude),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('accident'),
                  position: LatLng(report.latitude, report.longitude),
                ),
              },
              liteModeEnabled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AccidentReport report) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.phone),
            label: const Text('اتصال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat),
            label: const Text('محادثة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
