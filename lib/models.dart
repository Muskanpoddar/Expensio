class Models {
  String name;
  String amount;
  String category;
  String? date;

  Models({
    required this.name,
    required this.amount,
    required this.category,
    this.date,
  });

  /// ✅ Convert JSON → Model
  factory Models.fromJson(Map<String, dynamic> json) {
    return Models(
      name: json['name'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      category: json['category'] ?? 'Other',
      date: json['date'], // can be null
    );
  }

  /// ✅ Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'amount': amount, 'category': category, 'date': date};
  }
}
