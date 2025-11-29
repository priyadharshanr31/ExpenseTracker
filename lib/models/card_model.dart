import 'package:flutter/material.dart';

class CreditCard {
  final String id;
  final String name;
  final String last4;
  final double balance;
  final int colorValue;

  CreditCard({
    required this.id,
    required this.name,
    required this.last4,
    this.balance = 0.0,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last4': last4,
      'balance': balance,
      'colorValue': colorValue,
    };
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'],
      name: json['name'],
      last4: json['last4'],
      balance: json['balance'] ?? 0.0,
      colorValue: json['colorValue'],
    );
  }
}
