import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class CardProvider with ChangeNotifier {
  List<CreditCard> _allCards = [];
  List<CreditCard> _userCards = [];
  String? _userId;

  List<CreditCard> get cards => _userCards;

  void updateUserId(String? userId) {
    _userId = userId;
    _loadCards();
  }

  Future<void> _loadCards() async {
    if (_userId == null) {
      _userCards = [];
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? cardsJson = prefs.getString('cards');
    if (cardsJson != null) {
      final List<dynamic> decodedList = json.decode(cardsJson);
      _allCards = decodedList.map((item) => CreditCard.fromJson(item)).toList();
      _userCards = _allCards.where((c) => c.userId == _userId).toList();
      notifyListeners();
    }
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(_allCards.map((card) => card.toJson()).toList());
    await prefs.setString('cards', encodedList);
  }

  Future<void> addCard(CreditCard card) async {
    if (_userId == null) return;

    final newCard = CreditCard(
      id: card.id,
      name: card.name,
      last4: card.last4,
      balance: card.balance,
      monthlyLimit: card.monthlyLimit,
      colorValue: card.colorValue,
      userId: _userId!,
    );

    _allCards.add(newCard);
    _userCards.add(newCard);
    await _saveCards();
    notifyListeners();
  }

  Future<void> updateCardBalance(String cardId, double amount) async {
    final index = _allCards.indexWhere((c) => c.id == cardId);
    print('Updating balance for card $cardId. Amount: $amount. Index: $index');
    if (index != -1) {
      final oldCard = _allCards[index];
      // Update balance (spent amount)
      // If amount is negative (expense), we ADD to spent (balance)
      // If amount is positive (income/refund), we SUBTRACT from spent
      // Wait, usually "Balance" on a credit card is what you OWE.
      // So Expense (-100) -> Balance increases by 100.
      // Income (+100) -> Balance decreases by 100.
      // Let's assume amount passed here is the transaction amount (-ve for expense).
      
      double newBalance = oldCard.balance + (amount < 0 ? amount.abs() : -amount);
      
      _allCards[index] = CreditCard(
        id: oldCard.id,
        name: oldCard.name,
        last4: oldCard.last4,
        balance: newBalance,
        monthlyLimit: oldCard.monthlyLimit,
        colorValue: oldCard.colorValue,
        userId: oldCard.userId,
      );
      
      // Update user cards list too
      _userCards = _allCards.where((c) => c.userId == _userId).toList();
      
      await _saveCards();
      notifyListeners();
    }
  }

  Future<void> removeCard(String id) async {
    _allCards.removeWhere((card) => card.id == id);
    _userCards.removeWhere((card) => card.id == id);
    await _saveCards();
    notifyListeners();
  }

  CreditCard? getCardById(String id) {
    try {
      return _userCards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }
}
