import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class CardProvider with ChangeNotifier {
  List<CreditCard> _cards = [];

  List<CreditCard> get cards => _cards;

  CardProvider() {
    _loadCards();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cardsJson = prefs.getString('cards');
    if (cardsJson != null) {
      final List<dynamic> decodedList = json.decode(cardsJson);
      _cards = decodedList.map((item) => CreditCard.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(_cards.map((card) => card.toJson()).toList());
    await prefs.setString('cards', encodedList);
  }

  Future<void> addCard(CreditCard card) async {
    _cards.add(card);
    await _saveCards();
    notifyListeners();
  }

  Future<void> removeCard(String id) async {
    _cards.removeWhere((card) => card.id == id);
    await _saveCards();
    notifyListeners();
  }

  CreditCard? getCardById(String id) {
    try {
      return _cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }
}
