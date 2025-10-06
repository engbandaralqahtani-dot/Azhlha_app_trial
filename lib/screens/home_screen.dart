import 'package:flutter/material.dart';
import '../widgets/service_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/active_order_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: تحديث البيانات
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF00543C), Color(0xFF003828)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مرحباً بك في ازهلها',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'منصتك المتكاملة لإدارة حوادث المركبات',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'عسير - المنطقة التجريبية',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Vision 2030 Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD1FAE5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '2030',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'متوافق مع رؤية 2030',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'متكامل مع نجم وشركات التأمين',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Stats
                const Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        value: '2,400+',
                        label: 'طلب مكتمل',
                        color: Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        value: '98%',
                        label: 'رضا العملاء',
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        value: '15 د',
                        label: 'متوسط الوصول',
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Services Section
                const Text(
                  'خدماتنا',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: const [
                    ServiceCard(
                      id: 'towing',
                      icon: Icons.car_crash,
                      title: 'سحب المركبة',
                      description: 'خدمة سحب سريعة وآمنة',
                      color: Color(0xFF10B981),
                    ),
                    ServiceCard(
                      id: 'repair',
                      icon: Icons.build,
                      title: 'صيانة فورية',
                      description: 'إصلاح طارئ على الطريق',
                      color: Color(0xFF3B82F6),
                    ),
                    ServiceCard(
                      id: 'assessment',
                      icon: Icons.description,
                      title: 'تقدير الأضرار',
                      description: 'تقييم احترافي للأضرار',
                      color: Color(0xFF8B5CF6),
                    ),
                    ServiceCard(
                      id: 'comprehensive',
                      icon: Icons.car_repair,
                      title: 'إصلاح شامل',
                      description: 'ورش معتمدة ومضمونة',
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Active Orders
                const ActiveOrderCard(),
                const SizedBox(height: 24),

                // Emergency Contact
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'حالة طارئة؟',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7F1D1D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اتصل بنا فوراً على 920000000',
                              style: TextStyle(
                                color: Colors.red[900],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.red[900],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
