import 'package:flutter/material.dart';
import 'package:sap/providers/prescriptions_provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/prescription_details.dart';
import 'package:provider/provider.dart';
import 'package:sap/widgets/custom_list_tile.dart';
import 'package:sap/widgets/error_text.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/utils/format_datetime.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  void _loadPrescriptions() async {
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    await Provider.of<PrescriptionsProvider>(context, listen: false)
        .getUserPrescriptions(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionsProvider = Provider.of<PrescriptionsProvider>(context);

    final prescriptions = prescriptionsProvider.prescriptions;

    final isLoading = prescriptionsProvider.isLoading;

    final errorMessage = prescriptionsProvider.errorMessage;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : prescriptions.isEmpty
              ? ErrorText(
                  text: errorMessage.isNotEmpty
                      ? errorMessage
                      : 'No prescriptions found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = prescriptions[index];
                    return Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return CustomListTile(
                          titleText: 'Prescription',
                          subtitleText:
                              'Date: ${formatDateTime(prescription.date)}\n'
                              '${userProvider.user!.isDoctor ? 'Patient: ${prescription.patientName}' : 'Doctor: ${prescription.doctorName}'}',
                          leadingIcon: Icons.medication_outlined,
                          trailingIcon: Icons.arrow_forward,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrescriptionDetailsScreen(
                                  prescriptionId: prescription.id,
                                  isPatientPrescription:
                                      !userProvider.user!.isDoctor,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}
