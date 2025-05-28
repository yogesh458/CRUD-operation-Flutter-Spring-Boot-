class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String photoBase64;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.photoBase64,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
      photoBase64: json['photoBase64'],
    );
  }
}
