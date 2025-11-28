import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/assistant_fab.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  SummaryCard(
                    title: 'Total Income',
                    amount: '\$5,750.00',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  SummaryCard(
                    title: 'Total Expenses',
                    amount: '\$2,080.00',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                  SummaryCard(
                    title: 'Savings',
                    amount: '\$3,670.00',
                    icon: Icons.account_balance_wallet,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Income vs Spending Chart
            const Text('Income vs. Spending Flow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 4), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 2.7),
                        FlSpot(4, 1.8), FlSpot(5, 2.3), FlSpot(6, 3.4),
                      ],
                      isCurved: true,
                      color: Colors.indigo,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.indigo.withOpacity(0.1)),
                    ),
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2.4), FlSpot(1, 1.3), FlSpot(2, 9.8), FlSpot(3, 3.9),
                        FlSpot(4, 4.8), FlSpot(5, 3.8), FlSpot(6, 4.3),
                      ],
                      isCurved: true,
                      color: Colors.pink,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.pink.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Spending by Category
            const Text('Spending by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(value: 40, color: Colors.indigo, radius: 25, showTitle: false),
                          PieChartSectionData(value: 30, color: Colors.pink, radius: 25, showTitle: false),
                          PieChartSectionData(value: 15, color: Colors.amber, radius: 25, showTitle: false),
                          PieChartSectionData(value: 15, color: Colors.green, radius: 25, showTitle: false),
                        ],
                      ),
                    ),
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LegendItem(color: Colors.indigo, text: 'Housing'),
                      LegendItem(color: Colors.pink, text: 'Food'),
                      LegendItem(color: Colors.amber, text: 'Transport'),
                      LegendItem(color: Colors.green, text: 'Others'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Transactions
            const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: const [
                  TransactionTile(name: 'Groceries', category: 'Food', amount: '-\$150.00', date: '11/25'),
                  Divider(height: 1),
                  TransactionTile(name: 'Bus Pass', category: 'Transport', amount: '-\$60.00', date: '11/22'),
                  Divider(height: 1),
                  TransactionTile(name: 'Freelance', category: 'Income', amount: '+\$750.00', date: '11/18', isIncome: true),
                ],
              ),
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: const AssistantFab(),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String name;
  final String category;
  final String amount;
  final String date;
  final bool isIncome;

  const TransactionTile({
    super.key,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.black)),
          Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
