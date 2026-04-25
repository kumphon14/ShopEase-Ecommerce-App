class LocalCartItem {
  final String productId;
  final int quantity;
  final DateTime updatedAt;

  const LocalCartItem({
    required this.productId,
    required this.quantity,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LocalCartItem.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'];
    final parsedQuantity = quantity is int
        ? quantity
        : int.tryParse(quantity?.toString() ?? '') ?? 0;

    return LocalCartItem(
      productId: json['productId']?.toString() ?? '',
      quantity: parsedQuantity,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
