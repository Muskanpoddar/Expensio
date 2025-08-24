class Models {
  Models({
    required this.name,
    required this.amount,
    required this.category, // add this field
  });

  final String name;
  final String amount;
  final String category; // add this field

  factory Models.fromJson(Map<String, dynamic> json) => Models(
    name: json["name"],
    amount: json["amount"],
    category: json["category"] ?? "Other", // handle null safely
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "amount": amount,
    "category": category,
  };
}
