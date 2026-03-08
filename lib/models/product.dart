class Product {
  final int id;
  final String name;
  final String description;
  final double priceSmall;
  final double priceMedium;
  final double priceLarge;
  final String imagePath;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceSmall,
    required this.priceMedium,
    required this.priceLarge,
    required this.imagePath,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceSmall: double.parse(json['price_small'].toString()),
      priceMedium: double.parse(json['price_medium'].toString()),
      priceLarge: double.parse(json['price_large'].toString()),
      imagePath: json['image_path'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_small': priceSmall,
      'price_medium': priceMedium,
      'price_large': priceLarge,
      'image_path': imagePath,
      'is_active': isActive ? 1 : 0,
    };
  }

  double getPrice(String size) {
    switch (size) {
      case 'Small':
        return priceSmall;
      case 'Medium':
        return priceMedium;
      case 'Large':
        return priceLarge;
      default:
        return priceSmall;
    }
  }
}
