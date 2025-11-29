import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> decodedList = json.decode(transactionsJson);
      _transactions = decodedList.map((item) => Transaction.fromJson(item)).toList();
    } else {
      // Initial dummy data
      _transactions = [
        Transaction(id: '1', name: 'Groceries', category: 'Food', date: '11/25/2025', amount: -150.00, type: 'Expense'),
        Transaction(id: '2', name: 'Bus Pass', category: 'Transportation', date: '11/22/2025', amount: -60.00, type: 'Expense'),
        Transaction(id: '3', name: 'Online Course', category: 'Education', date: '11/20/2025', amount: -200.00, type: 'Expense'),
        Transaction(id: '4', name: 'Freelance Project', category: 'Income', date: '11/18/2025', amount: 750.00, type: 'Income'),
        Transaction(id: '5', name: 'Lunch', category: 'Food', date: '11/15/2025', amount: -20.00, type: 'Expense'),
      ];
      _saveTransactions();
    }
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', encodedList);
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.insert(0, transaction); // Add at the beginning (most recent first)
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveTransactions();
    notifyListeners();
  }
}
