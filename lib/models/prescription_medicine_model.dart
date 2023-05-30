class PrescriptionMedicine {
  final String id;
  final String name;
  final num price;
  int quantity;
  String doctorInstructions;

  PrescriptionMedicine({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.doctorInstructions,
  });

  factory PrescriptionMedicine.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedicine(
      id: json['medicineId'],
      name: json['medicineName'],
      price: json['price'],
      quantity: int.parse(json['quantity']),
      doctorInstructions: json['doctorInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': id,
      'medicineName': name,
      'price': price,
      'quantity': quantity,
      'doctorInstructions': doctorInstructions,
    };
  }
}
