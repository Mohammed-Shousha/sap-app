class MedicineModel {
  final String id;
  final String name;
  final num? price;
  final int? availableQuantity;
  final Map<String, dynamic>? position;

  MedicineModel({
    required this.id,
    required this.name,
    this.price,
    this.availableQuantity,
    this.position,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      availableQuantity: json['availableQuantity'],
      position: json['position'],
    );
  }
}
