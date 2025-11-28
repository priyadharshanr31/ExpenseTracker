import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'name': 'Housing', 'value': 1200.0, 'color': const Color(0xFF6366F1)},
      {'name': 'Food', 'value': 380.0, 'color': const Color(0xFFEC4899)},
      {'name': 'Education', 'value': 200.0, 'color': const Color(0xFFF59E0B)},
      {'name': 'Shopping', 'value': 120.0, 'color': const Color(0xFF10B981)},
      {'name': 'Transport', 'value': 110.0, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Entertainment', 'value': 40.0, 'color': const Color(0xFFEF4444)},
      {'name': 'Health', 'value': 30.0, 'color': const Color(0xFF3B82F6)},
    ];

    final total = data.fold(0.0, (sum, item) => sum + (item['value'] as double));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text('Nov 2025', style: TextStyle(fontSize: 12, color: Colors.grey[800])),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Category Spending Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // Pie Chart
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: data.map((item) {
                      return PieChartSectionData(
                        value: item['value'] as double,
                        color: item['color'] as Color,
                        radius: 80,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Breakdown Table
              ...data.map((item) {
                final value = item['value'] as double;
                final percentage = (value / total * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                      Text('\$${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 40,
                        child: Text('$percentage%', style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
