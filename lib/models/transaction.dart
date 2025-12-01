class Transaction {
  final String id;
  final String name;
  final String category;
  final String date;
  final double amount;
  final String type;
  final String? cardId;
  final String userId;

  Transaction({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
    this.cardId,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'date': date,
    'amount': amount,
    'type': type,
    'cardId': cardId,
    'userId': userId,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'].toString(),
    name: json['name'] as String,
    category: json['category'] as String,
    date: json['date'] as String,
    amount: (json['amount'] as num).toDouble(),
    type: json['type'] as String,
    cardId: json['cardId'] as String?,
    userId: json['userId'] as String? ?? 'default', // Backward compatibility
  );
}
