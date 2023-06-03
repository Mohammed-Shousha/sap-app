import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sap/models/medicine_model.dart';
import 'package:sap/models/prescription_medicine_model.dart';
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
  final _patientNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _scrollController = ScrollController();

  String _patientId = '';
  Medicine? _selectedMedicine;
  final List<PrescriptionMedicine> _medicines = [];

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
      User? user;

      try {
        user = await Provider.of<UserProvider>(context, listen: false)
            .getUser(userQrCode);
      } catch (e) {
        showErrorDialog(context, e.toString());

        setState(() {
          _patientId = '';
          _patientNameController.clear();
        });
      }

      setState(() {
        _patientNameController.text = user!.name;
        _patientId = user.id;
      });
    }
  }

  void _handleSubmit() async {
    if (_medicines.isEmpty) {
      showErrorDialog(context, 'Please add at least one medication');
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final doctorId = userProvider.user?.id;
    final medicines = _medicines;

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

  void _addMedicine() {
    final medicineId = _selectedMedicine?.id;
    final quantity = _quantityController.text.trim();
    final instructions = _instructionsController.text.trim();

    if (medicineId == null ||
        quantity.isEmpty ||
        instructions.isEmpty ||
        _patientId.isEmpty) {
      showErrorDialog(context, 'Please fill in all fields');
      return;
    }

    PrescriptionMedicine? selectedMedicine;
    for (var medication in _medicines) {
      if (medication.id == medicineId) {
        selectedMedicine = medication;
        break;
      }
    }

    if (selectedMedicine != null) {
      selectedMedicine.quantity += int.tryParse(quantity) ?? 0;
      selectedMedicine.doctorInstructions = instructions;
      _clearPrescriptionFields();
      return;
    }

    final newMedication = PrescriptionMedicine(
      id: medicineId,
      name: _selectedMedicine!.name,
      quantity: int.parse(quantity),
      doctorInstructions: instructions,
      price: _selectedMedicine!.price!,
    );

    _clearPrescriptionFields();

    setState(() {
      _medicines.add(newMedication);
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
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

  void _clearAllFields() {
    _clearPrescriptionFields();
    setState(() {
      _patientId = '';
      _patientNameController.clear();
      _medicines.clear();
    });
  }

  void _clearPrescriptionFields() {
    setState(() {
      _selectedMedicine = null;
      _quantityController.clear();
      _instructionsController.clear();
    });
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
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return CustomButton(
                    text: 'Scan Patient QR Code',
                    onPressed: _scanUserQrCode,
                    isLoading: userProvider.isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _patientNameController,
                label: 'Patient Name',
                enabled: false,
              ),
              const SizedBox(height: 16),
              Consumer<MedicinesProvider>(
                builder: (context, medicinesProvider, _) {
                  final medicines = medicinesProvider.medicines;

                  final medicinesDropdownItems = medicines
                      .map(
                        (medicine) => DropdownMenuItem(
                          value: medicine,
                          child: Text(medicine.name),
                        ),
                      )
                      .toList();

                  final isLoading = medicinesProvider.isLoading;

                  final errorMessage = medicinesProvider.errorMessage;

                  return DropdownButtonFormField<Medicine>(
                    value: _selectedMedicine,
                    items: medicinesDropdownItems,
                    onChanged: medicines.isNotEmpty
                        ? (Medicine? value) {
                            setState(() {
                              _selectedMedicine = value;
                            });
                          }
                        : null,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black87,
                      fontFamily: 'Montserrat',
                    ),
                    decoration: InputDecoration(
                      labelText: isLoading
                          ? 'Loading...'
                          : errorMessage.isNotEmpty
                              ? errorMessage
                              : medicines.isEmpty
                                  ? 'No medicines found'
                                  : 'Medicine',
                      labelStyle: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  );
                },
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
                  _addMedicine();
                  if (_medicines.length > 1) _scrollToEnd();
                },
                text: 'Add Medication',
              ),
              const SizedBox(height: 16),
              if (_medicines.isNotEmpty)
                SizedBox(
                  height: _medicines.length == 1 ? 80.0 : 160.0,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 0),
                    controller: _scrollController,
                    itemCount: _medicines.length,
                    itemBuilder: (context, index) {
                      final medication = _medicines[index];
                      return Card(
                        child: ListTile(
                          title: Text(medication.name),
                          subtitle: Text(
                              '${medication.quantity} pack(s)\n${medication.doctorInstructions}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeMedicine(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Consumer<PrescriptionsProvider>(
                builder: (context, prescriptionsProvider, _) {
                  return CustomButton(
                    text: 'Submit',
                    onPressed: _handleSubmit,
                    isLoading: prescriptionsProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
