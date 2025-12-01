import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _allTransactions = [];
  List<Transaction> _userTransactions = [];
  String? _userId;

  List<Transaction> get transactions => List.unmodifiable(_userTransactions);

  void updateUserId(String? userId) {
    _userId = userId;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (_userId == null) {
      _userTransactions = [];
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> decodedList = json.decode(transactionsJson);
      _allTransactions = decodedList.map((item) => Transaction.fromJson(item)).toList();
      
      // Filter for current user
      _userTransactions = _allTransactions.where((t) => t.userId == _userId).toList();
    } else {
      _allTransactions = [];
      _userTransactions = [];
    }
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(_allTransactions.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', encodedList);
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (_userId == null) return;
    
    // Ensure the transaction has the correct userId
    final t = Transaction(
      id: transaction.id,
      name: transaction.name,
      category: transaction.category,
      date: transaction.date,
      amount: transaction.amount,
      type: transaction.type,
      cardId: transaction.cardId,
      userId: _userId!,
    );

    _allTransactions.insert(0, t);
    _userTransactions.insert(0, t);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    _allTransactions.removeWhere((t) => t.id == id);
    _userTransactions.removeWhere((t) => t.id == id);
    await _saveTransactions();
    notifyListeners();
  }
}
