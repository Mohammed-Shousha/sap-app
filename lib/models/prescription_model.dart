import 'package:sap/models/prescription_medicine_model.dart';

class Prescription {
  final String id;
  final String doctorName;
  final String patientName;
  final DateTime date;
  final bool? isPaid;
  final bool? isReceived;
  final List<PrescriptionMedicine>? medicines;

  Prescription({
    required this.id,
    required this.doctorName,
    required this.patientName,
    required this.date,
    this.isPaid,
    this.isReceived,
    this.medicines,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
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
