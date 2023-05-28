import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sap/models/prescription_model.dart';
import 'package:sap/models/user_model.dart';
import 'package:sap/providers/medicines_provider.dart';
import 'package:sap/providers/prescriptions_provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/utils/dialogs/error_dialog.dart';
import 'package:sap/utils/dialogs/success_dialog.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/custom_text_field.dart';
import 'package:sap/widgets/gradient_scaffold.dart';

class AddPrescriptionForm extends StatefulWidget {
  const AddPrescriptionForm({super.key});

  @override
  State<AddPrescriptionForm> createState() => _AddPrescriptionFormState();
}

class _AddPrescriptionFormState extends State<AddPrescriptionForm> {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  String _patientId = '';
  String? _selectedMedicineId;
  String? _selectedMedicineName;
  num? _selectedMedicinePrice;

  final List<Map<String, dynamic>> _medications = [];

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getMedicines();
  }

  void getMedicines() async {
    MedicinesProvider medicinesProvider =
        Provider.of<MedicinesProvider>(context, listen: false);

    await medicinesProvider.getMedicines();
  }

  Future<void> _scanUserQrCode() async {
    String userQrCode = await FlutterBarcodeScanner.scanBarcode(
      '#3BBDB1',
      'Cancel',
      true,
      ScanMode.QR,
    );

    if (userQrCode == '-1') {
      return;
    }

    if (mounted) {
      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);

      UserModel? user = await userProvider.getUser(userQrCode);

      final errorMessage = userProvider.errorMessage;

      if (errorMessage.isNotEmpty && mounted) {
        setState(() {
          _patientId = '';
          _patientNameController.clear();
        });
        showErrorDialog(context, errorMessage);
      } else {
        setState(() {
          _patientNameController.text = user!.name;
          _patientId = user.id;
        });
      }
    }
  }

  void _clearAllFields() {
    _clearPrescriptionFields();
    setState(() {
      _patientId = '';
      _patientNameController.clear();
      _medications.clear();
    });
  }

  void _clearPrescriptionFields() {
    setState(() {
      _selectedMedicineId = null;
      _quantityController.clear();
      _instructionsController.clear();
    });
  }

  void _addMedication() {
    final medicineId = _selectedMedicineId;
    final medicineName = _selectedMedicineName;
    final quantity = _quantityController.text.trim();
    final instructions = _instructionsController.text.trim();
    final price = _selectedMedicinePrice;

    if (medicineId == null ||
        quantity.isEmpty ||
        instructions.isEmpty ||
        _patientId.isEmpty) {
      showErrorDialog(context, 'Please fill in all fields');
      return;
    }

    final selectedMedicine = _medications.firstWhere(
      (medication) => medication['medicineId'] == medicineId,
      orElse: () => {},
    );

    if (_medications.contains(selectedMedicine)) {
      selectedMedicine['quantity'] =
          (int.parse(selectedMedicine['quantity']) + int.parse(quantity))
              .toString();
      selectedMedicine['instructions'] = instructions;

      _clearPrescriptionFields();
      return;
    }

    final newMedication = {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'quantity': quantity,
      'doctorInstructions': instructions,
      'price': price,
    };

    _clearPrescriptionFields();

    setState(() {
      _medications.add(newMedication);
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent +
          80, // 80 is the height of the card
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleSubmit() async {
    if (_medications.isEmpty) {
      showErrorDialog(context, 'Please add at least one medication');
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final doctorId = userProvider.user?.id;
    final medicines = _medications
        .map((medication) => PrescriptionMedicine.fromJson(medication))
        .toList();

    final PrescriptionsProvider prescriptionsProvider =
        Provider.of<PrescriptionsProvider>(context, listen: false);

    await prescriptionsProvider.addPrescription(
      _patientId,
      doctorId!,
      medicines,
    );

    final errorMessage = prescriptionsProvider.errorMessage;

    if (errorMessage.isNotEmpty && mounted) {
      showErrorDialog(context, errorMessage);
    } else {
      showSuccessDialog(context, 'Prescription added successfully');
      _clearAllFields();
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _quantityController.dispose();
    _instructionsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicinesProvider = Provider.of<MedicinesProvider>(context);

    final medicines = medicinesProvider.medicines;

    final medicinesDropdownItems = medicines
        .map(
          (medicine) => DropdownMenuItem(
            value: medicine.id,
            child: Text(medicine.name),
          ),
        )
        .toList();

    final errorMessage = medicinesProvider.errorMessage;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Add Prescription'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'Scan Patient QR Code',
                onPressed: _scanUserQrCode,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _patientNameController,
                label: 'Patient Name',
                enabled: false,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _selectedMedicineId,
                items: medicinesDropdownItems,
                onChanged: medicines.isNotEmpty
                    ? (String? value) {
                        setState(() {
                          _selectedMedicineId = value;
                          final selectedMedicine = medicines
                              .firstWhere((medicine) => medicine.id == value);
                          _selectedMedicineName = selectedMedicine.name;
                          _selectedMedicinePrice = selectedMedicine.price;
                        });
                      }
                    : null,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.black87,
                  fontFamily: 'Montserrat',
                ),
                decoration: InputDecoration(
                  labelText: errorMessage.isNotEmpty
                      ? errorMessage
                      : medicines.isNotEmpty
                          ? 'Medicine'
                          : 'No medicines found',
                  labelStyle: const TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _quantityController,
                label: 'Quantity',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Instructions',
                controller: _instructionsController,
              ),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () {
                  _addMedication();
                  _scrollToEnd();
                },
                text: 'Add Medication',
              ),
              const SizedBox(height: 16),
              if (_medications.isNotEmpty)
                SizedBox(
                  height: _medications.length == 1 ? 80.0 : 160.0,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 0),
                    controller: _scrollController,
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      final medication = _medications[index];
                      return Card(
                        child: ListTile(
                          title: Text(medication['medicineName']),
                          subtitle: Text(
                              '${medication['quantity']} pack(s)\n${medication['instructions']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeMedication(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Submit',
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
