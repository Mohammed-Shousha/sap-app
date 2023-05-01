import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/utils/format_datetime.dart';
import 'package:sap/screens/qr.dart';
import 'package:sap/utils/palette.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/utils/stripe_payment.dart';
import 'package:sap/utils/graphql_queries.dart';

class PrescriptionDetailsScreen extends StatefulWidget {
  final String prescriptionId;
  final bool isPatientPrescription;

  const PrescriptionDetailsScreen({
    Key? key,
    required this.prescriptionId,
    required this.isPatientPrescription,
  }) : super(key: key);

  @override
  State<PrescriptionDetailsScreen> createState() =>
      _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  bool _paymentCompleted = false;

  num calculatePrescriptionTotal(List prices) {
    return prices.reduce((total, price) => total + price);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          widget.isPatientPrescription
              ? IconButton(
                  icon: const Icon(
                    Icons.qr_code,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRCodeScreen(
                        id: widget.prescriptionId,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
      body: Column(
        children: [
          Query(
            options: QueryOptions(
              document: gql(GraphQLQueries.getPrescription),
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

              final prescriptionPrices = prescription['medicines']
                  .map((medicine) => medicine['price'] * medicine['quantity'])
                  .toList();

              final prescriptionTotal =
                  calculatePrescriptionTotal(prescriptionPrices);

              if (prescription == null) {
                return const Text('Prescription not found.');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'ID: ${prescription['_id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Doctor: ${prescription['doctorName']}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patient: ${prescription['patientName']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${formatDateTime(prescription['date'])}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Received: ${prescription['isRecived'] ? 'Yes' : 'No'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  widget.isPatientPrescription
                      ? Text(
                          'Paid: ${prescription['isPaid'] || _paymentCompleted ? 'Yes' : 'No'}',
                          style: const TextStyle(fontSize: 16),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 20),
                  const Text(
                    'Medicines:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prescription['medicines'].length,
                    itemBuilder: (context, index) {
                      final medicine = prescription['medicines'][index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        shadowColor: Palette.primary,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${medicine['medicineName']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${medicine['doctorInstructions']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${medicine['quantity']} back(s)',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  widget.isPatientPrescription
                                      ? Text(
                                          '${medicine['price']} EGP',
                                          style: const TextStyle(fontSize: 16),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  widget.isPatientPrescription &&
                          !_paymentCompleted &&
                          !prescription['isPaid']
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Total: $prescriptionTotal ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                                text: "Pay",
                                onPressed: () async {
                                  final ispaymentCompleted = await makePayment(
                                    prescriptionTotal,
                                    widget.prescriptionId,
                                  );

                                  if (ispaymentCompleted) {
                                    setState(() {
                                      _paymentCompleted = true;
                                    });
                                  }
                                }),
                          ],
                        )
                      : const SizedBox(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
