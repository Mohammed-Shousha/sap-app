import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/prescriptions_provider.dart';
import 'package:sap/utils/dialogs/error_dialog.dart';
import 'package:sap/utils/dialogs/success_dialog.dart';
import 'package:sap/utils/format_datetime.dart';
import 'package:sap/screens/qr.dart';
import 'package:sap/utils/palette.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/error_text.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/utils/stripe_payment.dart';

class PrescriptionDetailsScreen extends StatefulWidget {
  final String prescriptionId;
  final bool isPatientPrescription;

  const PrescriptionDetailsScreen({
    super.key,
    required this.prescriptionId,
    required this.isPatientPrescription,
  });

  @override
  State<PrescriptionDetailsScreen> createState() =>
      _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPrescription(widget.prescriptionId);
  }

  void _loadPrescription(prescriptionId) async {
    await Provider.of<PrescriptionsProvider>(context, listen: false)
        .getPrescriptionDetails(
      prescriptionId,
    );
  }

  Future<void> _completePayment(
    num prescriptionTotal,
    String prescriptionId,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    bool ispaymentCompleted = false;

    try {
      ispaymentCompleted = await makePayment(prescriptionTotal, prescriptionId);
    } catch (e) {
      if (mounted) showErrorDialog(context, 'Payment failed');
    }

    setState(() {
      _isProcessing = false;
    });

    if (ispaymentCompleted) {
      if (mounted) showSuccessDialog(context, 'Payment completed!');

      _loadPrescription(widget.prescriptionId);
    }
  }

  void _handlePayment(prescriptionTotal) async {
    await _completePayment(
      prescriptionTotal,
      widget.prescriptionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionProvider = Provider.of<PrescriptionsProvider>(context);

    final prescription = prescriptionProvider.prescription;

    final prescriptionTotal = prescriptionProvider.prescriptionTotal;

    final isLoading = prescriptionProvider.isLoading;

    final errorMessage = prescriptionProvider.errorMessage;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          widget.isPatientPrescription &&
                  !prescription!.isReceived! &&
                  !isLoading &&
                  errorMessage.isEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.qr_code,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodeScreen(
                          id: widget.prescriptionId,
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: ErrorText(text: errorMessage),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'ID: ${prescription!.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor: ${prescription.doctorName}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Patient: ${prescription.patientName}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${formatDateTime(prescription.date)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Received: ${prescription.isReceived! ? 'Yes' : 'No'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      widget.isPatientPrescription
                          ? Text(
                              'Paid: ${prescription.isPaid! ? 'Yes' : 'No'}',
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
                        itemCount: prescription.medicines!.length,
                        itemBuilder: (context, index) {
                          final medicine = prescription.medicines![index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            shadowColor: Palette.primary,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicine.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    medicine.doctorInstructions,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${medicine.quantity} pack(s)',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      widget.isPatientPrescription
                                          ? Text(
                                              '${medicine.price * medicine.quantity} EGP',
                                              style:
                                                  const TextStyle(fontSize: 16),
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
                      widget.isPatientPrescription && !prescription.isPaid!
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Total: $prescriptionTotal EGP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  text: "Pay",
                                  onPressed: () {
                                    _handlePayment(prescriptionTotal);
                                  },
                                  isLoading: _isProcessing,
                                ),
                                const SizedBox(height: 16),
                              ],
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
    );
  }
}
