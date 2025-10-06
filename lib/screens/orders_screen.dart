import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/accident_report.dart';
import '../providers/accident_provider.dart';
import '../widgets/report_details_sheet.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: const TabBar(
                tabs: [
                  Tab(text: 'الحالية'),
                  Tab(text: 'المكتملة'),
                  Tab(text: 'الملغاة'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrdersList(context, _OrderFilter.active),
                  _buildOrdersList(context, _OrderFilter.completed),
                  _buildOrdersList(context, _OrderFilter.cancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, _OrderFilter filter) {
    return Consumer<AccidentReportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = provider.reports
            .where((report) => _matchesFilter(report, filter))
            .toList();

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد طلبات في هذه القائمة حالياً',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final chipData = _buildStatusChip(report.status);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'بلاغ #${report.id.substring(0, report.id.length > 6 ? 6 : report.id.length)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: chipData.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                chipData.icon,
                                color: chipData.color,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                chipData.label,
                                style: TextStyle(
                                  color: chipData.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(report.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.image_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${report.images.length} صور',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              provider.setCurrentReport(report);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => ReportDetailsSheet(
                                  reportId: report.id,
                                ),
                              );
                            },
                            child: const Text('تفاصيل البلاغ'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (filter == _OrderFilter.active)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: تتبع الطلب عبر الخريطة أو شاشة التتبع
                              },
                              child: const Text('تتبع الطلب'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _matchesFilter(AccidentReport report, _OrderFilter filter) {
    switch (filter) {
      case _OrderFilter.active:
        return {
          'pending',
          'in_progress',
          'assigned',
          'in_repair',
        }.contains(report.status);
      case _OrderFilter.completed:
        return {'completed', 'closed', 'resolved'}.contains(report.status);
      case _OrderFilter.cancelled:
        return {'cancelled', 'rejected'}.contains(report.status);
    }
  }

  _StatusChipData _buildStatusChip(String status) {
    switch (status) {
      case 'pending':
        return const _StatusChipData(
          label: 'قيد المراجعة',
          color: Color(0xFFF59E0B),
          icon: Icons.schedule,
        );
      case 'in_progress':
      case 'assigned':
      case 'in_repair':
        return const _StatusChipData(
          label: 'قيد التنفيذ',
          color: Color(0xFF2563EB),
          icon: Icons.directions_car,
        );
      case 'completed':
      case 'closed':
      case 'resolved':
        return const _StatusChipData(
          label: 'مكتمل',
          color: Color(0xFF16A34A),
          icon: Icons.check_circle,
        );
      case 'cancelled':
      case 'rejected':
        return const _StatusChipData(
          label: 'ملغي',
          color: Color(0xFFDC2626),
          icon: Icons.cancel,
        );
      default:
        return const _StatusChipData(
          label: 'غير معروف',
          color: Color(0xFF6B7280),
          icon: Icons.help_outline,
        );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    }
    return 'الآن';
  }
}

enum _OrderFilter { active, completed, cancelled }

class _StatusChipData {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChipData({
    required this.label,
    required this.color,
    required this.icon,
  });
}