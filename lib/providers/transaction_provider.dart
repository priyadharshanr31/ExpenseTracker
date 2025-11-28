import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [
    Transaction(id: '1', name: 'Groceries', category: 'Food', date: '11/25/2025', amount: -150.00, type: 'Expense'),
    Transaction(id: '2', name: 'Bus Pass', category: 'Transportation', date: '11/22/2025', amount: -60.00, type: 'Expense'),
    Transaction(id: '3', name: 'Online Course', category: 'Education', date: '11/20/2025', amount: -200.00, type: 'Expense'),
    Transaction(id: '4', name: 'Freelance Project', category: 'Income', date: '11/18/2025', amount: 750.00, type: 'Income'),
    Transaction(id: '5', name: 'Lunch', category: 'Food', date: '11/15/2025', amount: -20.00, type: 'Expense'),
  ];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction); // Add at the beginning (most recent first)
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
