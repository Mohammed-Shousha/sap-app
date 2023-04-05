import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';

class AddPrescriptionForm extends StatefulWidget {
  const AddPrescriptionForm({super.key});

  @override
  State<AddPrescriptionForm> createState() => _AddPrescriptionFormState();
}

class _AddPrescriptionFormState extends State<AddPrescriptionForm> {
  final TextEditingController _patientNameController = TextEditingController();
  // final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  String _patientId = '';

  final List<Map<String, dynamic>> _medications = [];

  String? selectedMedicineId;
  String? selectedMedicineName;

  Future<void> _scanQrCode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#FF0000',
      'Cancel',
      true,
      ScanMode.QR,
    );

    if (context.mounted) {
      final result = await GraphQLProvider.of(context).value.query(QueryOptions(
            document: gql(r'''
              query User($userId: ID!){
                user(id: $userId) {
                  _id
                  name
                }
              }
            '''),
            variables: {
              'userId': barcodeScanRes,
            },
          ));

      if (result.hasException && context.mounted) {
        Logger().e(result.exception);
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              '${result.exception?.graphqlErrors[0].message}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      setState(() {
        _patientNameController.text = result.data!['user']['name'];
        _patientId = result.data!['user']['_id'];
      });
    }
  }

  void _addMedication() {
    // final medicine = _medicineController.text.trim();
    final medicineId = selectedMedicineId;
    final medicineName = selectedMedicineName;
    final quantity = _quantityController.text.trim();
    final instructions = _instructionsController.text.trim();

    if (medicineId!.isNotEmpty && quantity.isNotEmpty) {
      final newMedication = {
        'medicineId': medicineId,
        'medicineName': medicineName,
        'quantity': quantity,
        'instructions': instructions
      };
      setState(() {
        _medications.add(newMedication);
        // _medicineController.clear();
        selectedMedicineId = null;
        _quantityController.clear();
        _instructionsController.clear();
      });
    }
  }

  void handleSubmit() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final doctorId = userProvider.user?.id;
    final medicines = _medications
        .map((medication) => {
              'medicineId': medication['medicineId'],
              'medicineName': medication['medicineName'],
              'quantity': int.parse(medication['quantity']),
              'doctorInstructions': medication['instructions'],
            })
        .toList();

    final result = await GraphQLProvider.of(context).value.mutate(
          MutationOptions(
            document: gql(r'''
              mutation AddPrescription($patientId: ID!, $doctorId: ID!, $medicines: [PrescriptionMedicineInput!]!){
                addPrescription(patientId: $patientId, doctorId: $doctorId, medicines: $medicines) {
                  _id
                  patientId
                  doctorId
                  medicines {
                    medicineId
                    quantity
                    doctorInstructions
                  }
                  date
                  isPaid
                  isRecived
                }
              }
            '''),
            variables: {
              'patientId': _patientId,
              'doctorId': doctorId,
              'medicines': medicines.isNotEmpty ? medicines : null,
            },
          ),
        );

    if (result.hasException && context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text(
            '${result.exception?.graphqlErrors[0].message}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Prescription'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _scanQrCode,
                child: const Text('Scan QR Code'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient ID',
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Query(
                options: QueryOptions(
                  document: gql('''
                    query Medicines{
                      medicines {
                        _id
                        name
                      }
                    }
                  '''),
                ),
                builder: (QueryResult result,
                    {Refetch? refetch, FetchMore? fetchMore}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  // if (result.isLoading) {
                  //   return const CircularProgressIndicator();
                  // }

                  final medicinesOptions = result.data!['medicines'];

                  return DropdownButtonFormField(
                    value: selectedMedicineId,
                    items: medicinesOptions
                        .map<DropdownMenuItem<String>>((medicineOption) {
                      return DropdownMenuItem<String>(
                        value: medicineOption['_id'],
                        child: Text(medicineOption['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMedicineId = value!;
                        selectedMedicineName = medicinesOptions.firstWhere(
                            (medicineOption) =>
                                medicineOption['_id'] == value)['name'];
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Medicine',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addMedication,
                child: const Text('Add Medication'),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final medication = _medications[index];
                  return Card(
                    child: ListTile(
                      title: Text(medication['medicineName']),
                      subtitle: Text(medication['quantity']),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _medications.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  handleSubmit();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
