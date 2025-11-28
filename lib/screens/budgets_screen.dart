import 'package:flutter/material.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = [
      {'category': 'Food', 'spent': 380.0, 'total': 500.0, 'icon': Icons.restaurant, 'color': Colors.indigo},
      {'category': 'Transportation', 'spent': 110.0, 'total': 150.0, 'icon': Icons.directions_bus, 'color': Colors.blue},
      {'category': 'Entertainment', 'spent': 40.0, 'total': 200.0, 'icon': Icons.movie, 'color': Colors.purple},
      {'category': 'Housing', 'spent': 1200.0, 'total': 1200.0, 'icon': Icons.home, 'color': Colors.amber},
      {'category': 'Shopping', 'spent': 120.0, 'total': 250.0, 'icon': Icons.shopping_bag, 'color': Colors.pink},
      {'category': 'Health', 'spent': 30.0, 'total': 100.0, 'icon': Icons.favorite, 'color': Colors.red},
      {'category': 'Education', 'spent': 200.0, 'total': 300.0, 'icon': Icons.book, 'color': Colors.green},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final spent = budget['spent'] as double;
          final total = budget['total'] as double;
          final percentage = (spent / total).clamp(0.0, 1.0);
          final color = budget['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(budget['icon'] as IconData, color: Colors.grey[700], size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(budget['category'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          Text(
                            '\$${(total - spent).toStringAsFixed(2)} remaining',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${spent.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('/ \$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[100],
                    color: color,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
