class PrescriptionModel {
  final String id;
  final String doctorName;
  final String patientName;
  final DateTime date;
  final bool? isPaid;
  final bool? isReceived;
  final List<PrescriptionMedicine>? medicines;

  PrescriptionModel({
    required this.id,
    required this.doctorName,
    required this.patientName,
    required this.date,
    this.isPaid,
    this.isReceived,
    this.medicines,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['_id'],
      doctorName: json['doctorName'],
      patientName: json['patientName'],
      date: DateTime.parse(json['date']),
      isPaid: json['isPaid'],
      isReceived: json['isReceived'],
      medicines: ((json['medicines'] ?? []) as List<dynamic>)
          .map((medicine) => PrescriptionMedicine(
                id: medicine['medicineId'],
                name: medicine['medicineName'],
                quantity: medicine['quantity'],
                price: medicine['price'],
                doctorInstructions: medicine['doctorInstructions'],
              ))
          .toList(),
    );
  }
}

class PrescriptionMedicine {
  final String id;
  final String name;
  final int quantity;
  final num price;
  final String doctorInstructions;

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
