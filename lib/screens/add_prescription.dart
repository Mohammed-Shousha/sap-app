import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/custom_text_field.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/utils/graphql_queries.dart';

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

  final List<Map<String, dynamic>> _medications = [];

  String? selectedMedicineId;
  String? selectedMedicineName;
  num? selectedMedicinePrice;

  final _scrollController = ScrollController();

  Future<void> _scanQrCode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    );

    if (context.mounted) {
      final result = await GraphQLProvider.of(context).value.query(QueryOptions(
            document: gql(GraphQLQueries.getUser),
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
    final medicineId = selectedMedicineId;
    final medicineName = selectedMedicineName;
    final quantity = _quantityController.text.trim();
    final instructions = _instructionsController.text.trim();
    final price = selectedMedicinePrice;

    if (medicineId!.isNotEmpty && quantity.isNotEmpty) {
      final newMedication = {
        'medicineId': medicineId,
        'medicineName': medicineName,
        'quantity': quantity,
        'instructions': instructions,
        'price': price,
      };
      setState(() {
        _medications.add(newMedication);
        _quantityController.clear();
        _instructionsController.clear();
        selectedMedicineId = null;
      });
    }
  }

  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent +
          80, // 80 is the height of the card
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
              'price': medication['price'],
            })
        .toList();

    final result = await GraphQLProvider.of(context).value.mutate(
          MutationOptions(
            document: gql(GraphQLMutations.addPrescription),
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
                text: 'Scan QR Code',
                onPressed: _scanQrCode,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _patientNameController,
                label: 'Patient Name',
                enabled: false,
              ),
              const SizedBox(height: 16),
              Query(
                options: QueryOptions(
                  document: gql(GraphQLQueries.getMedicines),
                ),
                builder: (QueryResult result,
                    {Refetch? refetch, FetchMore? fetchMore}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  if (result.isLoading) {
                    return const CircularProgressIndicator();
                  }

                  final medicinesOptions = result.data!['medicines'];
                  Logger().i(medicinesOptions);

                  return DropdownButtonFormField(
                    value: selectedMedicineId,
                    items: medicinesOptions
                        .map<DropdownMenuItem<String>>((medicineOption) {
                      return DropdownMenuItem<String>(
                        value: medicineOption['_id'],
                        child: Text(
                          medicineOption['name'],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMedicineId = value!;
                        selectedMedicineName = medicinesOptions.firstWhere(
                            (medicineOption) =>
                                medicineOption['_id'] == value)['name'];
                        selectedMedicinePrice = medicinesOptions.firstWhere(
                            (medicineOption) =>
                                medicineOption['_id'] == value)['price'];
                        Logger().i(selectedMedicinePrice);
                      });
                    },
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black87,
                      fontFamily: 'Montserrat',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Medicine',
                      labelStyle: TextStyle(fontSize: 20.0),
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
                onPressed: () => {
                  _addMedication(),
                  scrollToEnd(),
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
                          subtitle: Text(medication['quantity']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => setState(() {
                              _medications.removeAt(index);
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Submit',
                onPressed: () => handleSubmit(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
