class MedicineModel {
  final String id;
  final String name;
  final int availableQuantity;
  final bool otc;
  final Map<String, dynamic> position;

  MedicineModel({
    required this.id,
    required this.name,
    required this.availableQuantity,
    required this.otc,
    required this.position,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['_id'],
      name: json['name'],
      availableQuantity: json['availableQuantity'],
      otc: json['otc'],
      position: json['position'],
    );
  }
}
