import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Sample data - replace with your actual API data
  List<RevenueData> revenueData = [
    RevenueData(time: "01/2024", revenue: 64450),
    RevenueData(time: "02/2024", revenue: 63680),
    RevenueData(time: "03/2024", revenue: 52120),
    RevenueData(time: "04/2024", revenue: 78900),
    RevenueData(time: "05/2024", revenue: 85600),
    RevenueData(time: "06/2024", revenue: 92300),
  ];

  OverviewData overviewData = OverviewData(
    totalRevenue: 165365,
    totalTransactions: 6,
    successfulTransactions: 6,
    failedTransactions: 0,
    subscriptionStats: [
      SubscriptionStat(
        subscriptionId: "0c09447f-c97e-4503-8715-d21385be6d92",
        subscriptionName: "PremiumPlan",
        revenue: 79327,
        purchasesCount: 3,
      ),
      SubscriptionStat(
        subscriptionId: "8e269444-3ffb-4b01-b52b-04ae9c305553",
        subscriptionName: "FamilyPlan",
        revenue: 86038,
        purchasesCount: 3,
      ),
    ],
  );

  bool isLoading = false;
  DateTime startDate = DateTime(2024, 10, 1);
  DateTime endDate = DateTime(2025, 5, 1);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with your actual API calls
      // await _fetchRevenueData();
      // await _fetchOverviewData();

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatVND(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Revenue Dashboard',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF89B7C2).withOpacity(0.15),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF89B7C2),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Stats Section
                _buildOverviewSection(),
                const SizedBox(height: 24),

                // Revenue Chart Section
                _buildRevenueChartSection(),
                const SizedBox(height: 24),

                // Subscription Stats Section
                _buildSubscriptionStatsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF89B7C2), Color(0xFFA8BF8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF89B7C2).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Revenue Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  title: formatVND(overviewData.totalRevenue.toDouble()),
                  subtitle: 'Total Revenue',
                  icon: Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  title: '${overviewData.totalTransactions}',
                  subtitle: 'Total Transactions',
                  icon: Icons.receipt_long,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  title: '${overviewData.successfulTransactions}',
                  subtitle: 'Successful',
                  icon: Icons.check_circle,
                  color: const Color(0xFFA8BF8A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  title: '${overviewData.failedTransactions}',
                  subtitle: 'Failed',
                  icon: Icons.cancel,
                  color: const Color(0xFFE37083),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color ?? Colors.white,
            size: 16,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monthly revenue performance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF89B7C2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF89B7C2),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '6 months',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF89B7C2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: RevenueLineChart(data: revenueData),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Revenue breakdown by subscription plans',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: SubscriptionPieChart(
                    subscriptions: overviewData.subscriptionStats,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: overviewData.subscriptionStats.map((sub) {
                    final index = overviewData.subscriptionStats.indexOf(sub);
                    final colors = [
                      const Color(0xFFFFB876),
                      const Color(0xFF89B7C2),
                      const Color(0xFFE37083),
                      const Color(0xFFA8BF8A),
                    ];
                    final color = colors[index % colors.length];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.subscriptionName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                Text(
                                  formatVND(sub.revenue.toDouble()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${sub.purchasesCount}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RevenueLineChart extends StatelessWidget {
  final List<RevenueData> data;

  const RevenueLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.revenue.toDouble());
    }).toList();

    final maxY = data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b).toDouble();
    final minY = data.map((e) => e.revenue).reduce((a, b) => a < b ? a : b).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return SideTitleWidget(
                    space: 8,
                    meta: meta,
                    child: Text(
                      data[value.toInt()].time,
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxY - minY) / 4,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  space: 8,
                  meta: meta,
                  child: Text(
                    '${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY * 0.9,
        maxY: maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF89B7C2),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF89B7C2),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF89B7C2).withOpacity(0.3),
                  const Color(0xFF89B7C2).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPieChart extends StatelessWidget {
  final List<SubscriptionStat> subscriptions;

  const SubscriptionPieChart({super.key, required this.subscriptions});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFFB876),
      const Color(0xFF89B7C2),
      const Color(0xFFE37083),
      const Color(0xFFA8BF8A),
    ];

    final totalRevenue = subscriptions.fold(0, (sum, sub) => sum + sub.revenue);

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 30,
        sections: subscriptions.asMap().entries.map((entry) {
          final index = entry.key;
          final sub = entry.value;
          final percentage = (sub.revenue / totalRevenue * 100);

          return PieChartSectionData(
            color: colors[index % colors.length],
            value: sub.revenue.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 25,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Data Models
class RevenueData {
  final String time;
  final int revenue;

  RevenueData({required this.time, required this.revenue});
}

class OverviewData {
  final int totalRevenue;
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final List<SubscriptionStat> subscriptionStats;

  OverviewData({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.subscriptionStats,
  });
}

class SubscriptionStat {
  final String subscriptionId;
  final String subscriptionName;
  final int revenue;
  final int purchasesCount;

  SubscriptionStat({
    required this.subscriptionId,
    required this.subscriptionName,
    required this.revenue,
    required this.purchasesCount,
  });
}