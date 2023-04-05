import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/screens/payment.dart';
import 'package:sap/utils/format_datetime.dart';
import 'package:sap/screens/qr.dart';

class PrescriptionDetailsScreen extends StatefulWidget {
  final String prescriptionId;
  final bool patientPrescription;

  const PrescriptionDetailsScreen({
    Key? key,
    required this.prescriptionId,
    required this.patientPrescription,
  }) : super(key: key);

  @override
  State<PrescriptionDetailsScreen> createState() =>
      _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          widget.patientPrescription
              ? IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QRCodeScreen(
                                id: widget.prescriptionId,
                              )),
                    );
                  },
                )
              : const SizedBox(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Query(
              options: QueryOptions(
                document: gql(r'''
                  query PrescriptionById($id: ID!){
                    prescriptionById(id: $id) {
                      _id
                      patientName
                      doctorName
                      date
                      isPaid
                      isRecived
                      medicines {
                        medicineName
                        quantity
                        doctorInstructions
                      }
                    }
                  }
                '''),
                variables: {
                  'id': widget.prescriptionId,
                },
              ),
              builder: (QueryResult result,
                  {Refetch? refetch, FetchMore? fetchMore}) {
                if (result.hasException) {
                  return Text(result.exception.toString());
                }

                if (result.isLoading) {
                  return const CircularProgressIndicator();
                }

                final prescription = result.data?['prescriptionById'];

                if (prescription == null) {
                  return const Text('Prescription not found.');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text('Doctor: ${prescription['doctorName']}'),
                    const SizedBox(height: 8),
                    Text('Patient: ${prescription['patientName']}'),
                    const SizedBox(height: 8),
                    Text('Date: ${formatDateTime(prescription['date'])}'),
                    const SizedBox(height: 8),
                    Text(
                        'Recived: ${prescription['isRecived'] ? 'Yes' : 'No'}'),
                    const SizedBox(height: 8),
                    widget.patientPrescription
                        ? Text('Paid: ${prescription['isPaid'] ? 'Yes' : 'No'}')
                        : const SizedBox(),
                    const SizedBox(height: 16),
                    const Text(
                      'Medicines:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: prescription['medicines'].length,
                      itemBuilder: (context, index) {
                        final medicine = prescription['medicines'][index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${medicine['medicineName']}'),
                            const SizedBox(height: 4),
                            Text('Quantity: ${medicine['quantity']}'),
                            const SizedBox(height: 4),
                            Text(
                                'Instructions: ${medicine['doctorInstructions']}'),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                    widget.patientPrescription
                        ? ElevatedButton(
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ),
                              )
                            },
                            child: const Text("Pay"),
                          )
                        : const SizedBox(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
