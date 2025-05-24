import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Title and Profile
                    _buildHeader(),

                    // User Management Section
                    _buildUserManagementSection(),

                    // Stats Cards
                    _buildStatsCardsSection(),

                    // Line Chart Section
                    _buildLineChartSection(),

                    // Pie Charts Section
                    _buildPieChartsSection(),
                  ],
                ),
              ),
            ),);
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Overview",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.more_vert),
          ],
        ),
      ],
    );
  }

  Widget _buildUserManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Last updated 1 hour ago",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        UserManagementCard(
          title: "User Management",
          viewAllAction: () {
            // Handle view all action
          },
        ),
      ],
    );
  }

  Widget _buildStatsCardsSection() {
    return Column(
      children: [
        StatsCard(
          title: "2K",
          subtitle: "Total subscription",
          iconBackgroundColor: Colors.amber.shade100,
          iconData: Icons.people_outline,
          value: "50",
          showPlus: true,
        ),
        const SizedBox(height: 10),
        StatsCard(
          title: "3M",
          subtitle: "Revenue",
          iconBackgroundColor: Colors.red.shade300,
          iconData: Icons.attach_money,
          value: "800K",
          showPlus: true,
        ),
      ],
    );
  }

  Widget _buildLineChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chart",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Lorem ipsum dolor sit amet, consectetur",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "496",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: const Text("Save Report"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                side: BorderSide(color: Colors.blue.shade300),
                foregroundColor: Colors.blue.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: LineChartWidget(),
        ),
      ],
    );
  }

  Widget _buildPieChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pie Chart",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PieChartWidget(
              percentage: 81,
              title: "Total Sales",
              color: Colors.red.shade300,
            ),
            PieChartWidget(
              percentage: 23,
              title: "Customer Growth",
              color: Colors.green.shade300,
            ),
            PieChartWidget(
              percentage: 62,
              title: "Total Revenue",
              color: Colors.blue.shade300,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartLegend("Chart"),
            const SizedBox(width: 20),
            _buildChartLegend("Show Value"),
          ],
        ),
      ],
    );
  }

  Widget _buildChartLegend(String title) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey),
          ),
          child: title == "Chart"
              ? const Icon(Icons.check, size: 12, color: Colors.black)
              : null,
        ),
        const SizedBox(width: 5),
        Text(title),
      ],
    );
  }
}

class UserManagementCard extends StatelessWidget {
  final String title;
  final VoidCallback viewAllAction;

  const UserManagementCard({
    super.key,
    required this.title,
    required this.viewAllAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: viewAllAction,
                child: const Text(
                  "View all",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.person, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color iconBackgroundColor;
  final IconData iconData;
  final String value;
  final bool showPlus;

  const StatsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconBackgroundColor,
    required this.iconData,
    required this.value,
    this.showPlus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: iconBackgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBackgroundColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  showPlus ? "+$value" : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: iconBackgroundColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_upward,
                  size: 14,
                  color: iconBackgroundColor.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 100,
              reservedSize: 40,
              getTitlesWidget: leftTitleWidgets,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 500,
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 150),
              FlSpot(1, 200),
              FlSpot(2, 350),
              FlSpot(3, 250),
              FlSpot(4, 400),
              FlSpot(5, 300),
              FlSpot(6, 410),
            ],
            isCurved: true,
            color: Colors.blue.shade400,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.shade100.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black54,
      fontSize: 10,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Sunday', style: style);
        break;
      case 1:
        text = const Text('Monday', style: style);
        break;
      case 2:
        text = const Text('Tuesday', style: style);
        break;
      case 3:
        text = const Text('Wednesday', style: style);
        break;
      case 4:
        text = const Text('Thursday', style: style);
        break;
      case 5:
        text = const Text('Friday', style: style);
        break;
      case 6:
        text = const Text('Saturday', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      meta: meta,
      // axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black54,
      fontSize: 10,
    );

    return SideTitleWidget(
      // axisSide: meta.axisSide,
      meta: meta,
      child: Text('${value.toInt()}', style: style),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final int percentage;
  final String title;
  final Color color;

  const PieChartWidget({
    super.key,
    required this.percentage,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 30,
              sections: [
                PieChartSectionData(
                  color: color,
                  value: percentage.toDouble(),
                  title: '$percentage%',
                  radius: 15,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.grey.shade300,
                  value: (100 - percentage).toDouble(),
                  title: '',
                  radius: 15,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}