class Prescription {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime date;
  final bool isPaid;
  final bool isReceived;
  final List<Medicine> medicines;

  Prescription({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.isPaid,
    required this.isReceived,
    required this.medicines,
  });
}

class Medicine {
  final String id;
  final int quantity;
  final String doctorInstructions;

  Medicine({
    required this.id,
    required this.quantity,
    required this.doctorInstructions,
  });
}
