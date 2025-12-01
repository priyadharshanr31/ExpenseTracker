import 'package:flutter/material.dart';

class CreditCard {
  final String id;
  final String name;
  final String last4;
  final double balance; // This is now "Spent Amount" effectively, or we can calculate it dynamically
  final double monthlyLimit;
  final int colorValue;
  final String userId;

  CreditCard({
    required this.id,
    required this.name,
    required this.last4,
    this.balance = 0.0,
    this.monthlyLimit = 0.0,
    required this.colorValue,
    required this.userId,
  });

  Color get color => Color(colorValue);

  // Helper to get remaining balance
  double get remainingLimit => monthlyLimit - balance;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last4': last4,
      'balance': balance,
      'monthlyLimit': monthlyLimit,
      'colorValue': colorValue,
      'userId': userId,
    };
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'],
      name: json['name'],
      last4: json['last4'],
      balance: json['balance'] ?? 0.0,
      monthlyLimit: json['monthlyLimit'] ?? 0.0,
      colorValue: json['colorValue'],
      userId: json['userId'] ?? 'default',
    );
  }
}
