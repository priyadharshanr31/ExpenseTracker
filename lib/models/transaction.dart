class Transaction {
  final String id;
  final String name;
  final String category;
  final String date;
  final double amount;
  final String type;

  Transaction({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'date': date,
    'amount': amount,
    'type': type,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'].toString(),
    name: json['name'] as String,
    category: json['category'] as String,
    date: json['date'] as String,
    amount: (json['amount'] as num).toDouble(),
    type: json['type'] as String,
  );
}
