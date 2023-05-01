import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/prescription_details.dart';
import 'package:provider/provider.dart';
import 'package:sap/utils/graphql_queries.dart';
import 'package:sap/widgets/custom_list_tile.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/utils/format_datetime.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Query(
      options: QueryOptions(
        document: gql(
          GraphQLQueries.getPrescriptions,
        ),
        variables: {
          'userId': userProvider.user!.id,
        },
      ),
      builder: (
        QueryResult result, {
        Refetch? refetch,
        FetchMore? fetchMore,
      }) {
        if (result.hasException) {
          return Center(
            child: Text(
              'Error: ${result.exception.toString()}',
            ),
          );
        }

        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final prescriptions = result.data!['prescriptionsByUser'];

        return GradientScaffold(
          appBar: AppBar(
            title: const Text('Prescriptions'),
          ),
          body: prescriptions.isEmpty
              ? const Center(
                  child: Text(
                    'No prescriptions found',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = prescriptions[index];
                    return CustomListTile(
                      titleText: 'Prescription',
                      subtitleText:
                          'Date: ${formatDateTime(prescription['date'])}\n'
                          '${userProvider.user!.isDoctor ? 'Patient: ${prescription['patientName']}' : 'Doctor: ${prescription['doctorName']}'}',
                      leadingIcon: Icons.medication_outlined,
                      trailingIcon: Icons.arrow_forward,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrescriptionDetailsScreen(
                            prescriptionId: prescription['_id'],
                            isPatientPrescription: !userProvider.user!.isDoctor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
