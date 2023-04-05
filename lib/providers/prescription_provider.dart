import 'package:flutter/foundation.dart';
import 'package:sap/models/prescription_model.dart';

class PrescriptionProvider with ChangeNotifier {
  final List<Prescription> _prescriptions = [];

  List<Prescription> get prescriptions => _prescriptions;

  void addPrescription(Prescription prescription) {
    _prescriptions.add(prescription);
    notifyListeners();
  }

  void updatePrescription(int id, Prescription updatedPrescription) {
    final index =
        _prescriptions.indexWhere((prescription) => prescription.id == id);
    if (index != -1) {
      _prescriptions[index] = updatedPrescription;
      notifyListeners();
    }
  }

  void deletePrescription(int id) {
    _prescriptions.removeWhere((prescription) => prescription.id == id);
    notifyListeners();
  }
}
