import 'package:flutter/material.dart';
import 'package:sap/models/prescription_model.dart';
import 'package:sap/models/user_model.dart';
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
  // @override
  // void initState() {
  //   super.initState();
  //   getUserPrescriptions();
  // }

  // void getUserPrescriptions() async {
  //   final user = Provider.of<UserProvider>(context, listen: false).user!;
  //   await Provider.of<PrescriptionsProvider>(context, listen: false)
  //       .getUserPrescriptions(user.id);
  // }

  bool _isLoading = true;
  String _errorMessage = '';
  List<PrescriptionModel> _prescriptions = [];
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  void _loadPrescriptions() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      final prescriptionsProvider =
          Provider.of<PrescriptionsProvider>(context, listen: false);

      await prescriptionsProvider.getUserPrescriptions(user.id);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _prescriptions = prescriptionsProvider.prescriptions;
          _isLoading = prescriptionsProvider.isLoading;
          _errorMessage = prescriptionsProvider.errorMessage;
          _user = user;
        });
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserProvider>(context).user!;
    // final prescriptionsProvider = Provider.of<PrescriptionsProvider>(context);

    // final List<PrescriptionModel> prescriptions =
    //     prescriptionsProvider.prescriptions;

    // final isLoading = prescriptionsProvider.isLoading;

    // final errorMessage = prescriptionsProvider.errorMessage;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _prescriptions.isEmpty
              ? ErrorText(
                  text: _errorMessage.isNotEmpty
                      ? _errorMessage
                      : 'No prescriptions found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = _prescriptions[index];
                    return CustomListTile(
                      titleText: 'Prescription',
                      subtitleText:
                          'Date: ${formatDateTime(prescription.date)}\n'
                          '${_user!.isDoctor ? 'Patient: ${prescription.patientName}' : 'Doctor: ${prescription.doctorName}'}',
                      leadingIcon: Icons.medication_outlined,
                      trailingIcon: Icons.arrow_forward,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrescriptionDetailsScreen(
                              prescriptionId: prescription.id,
                              isPatientPrescription: !_user!.isDoctor,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
