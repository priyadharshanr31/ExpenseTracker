import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/card_provider.dart';
import '../models/transaction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final cardProvider = Provider.of<CardProvider>(context);
    
    final transactions = transactionProvider.transactions;
    final cards = cardProvider.cards;
    
    // Calculate Total Balance from Cards (Sum of Remaining Limits)
    // If no cards, default to 0.0 or maybe keep transaction sum? 
    // User asked: "total balance from all the cards the user have added"
    final totalBalance = cards.fold(0.0, (sum, card) => sum + card.remainingLimit);
    
    final expenseTransactions = transactions.where((t) => t.type == 'Expense').toList();
    
    // Group expenses by category
    final Map<String, double> categoryExpenses = {};
    for (var t in expenseTransactions) {
      categoryExpenses[t.category] = (categoryExpenses[t.category] ?? 0) + t.amount.abs();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${totalBalance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  // Profile Icon Removed as requested
                ],
              ),
              const SizedBox(height: 32),

              // Chart Section
              if (categoryExpenses.isNotEmpty) ...[
                Text(
                  'Spending by Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: categoryExpenses.entries.map((e) {
                        final color = _getCategoryColor(e.key);
                        return PieChartSectionData(
                          color: color,
                          value: e.value,
                          title: '', // Hide title on chart
                          radius: 50,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Legend
                ...categoryExpenses.entries.map((e) {
                  final totalExpense = expenseTransactions.fold(0.0, (s, t) => s + t.amount.abs());
                  final percentage = (e.value / totalExpense * 100).toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(e.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 32),
              ],

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.take(5).length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  return _TransactionTile(transaction: t);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transportation': return Colors.blue;
      case 'education': return Colors.purple;
      case 'health': return Colors.red;
      case 'shopping': return Colors.pink;
      default: return Colors.grey;
    }
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'Income';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final card = transaction.cardId != null ? cardProvider.getCardById(transaction.cardId!) : null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome 
                  ? (isDark ? Colors.green.withOpacity(0.2) : Colors.green[50])
                  : (isDark ? Colors.red.withOpacity(0.2) : Colors.red[50]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      transaction.category,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    if (card != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 4, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[500], shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.credit_card, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        card.name,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : ''}\$${transaction.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isIncome ? Colors.green : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              Text(
                transaction.date,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
