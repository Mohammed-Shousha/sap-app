import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/prescription_details.dart';
import 'package:provider/provider.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Query(
      options: QueryOptions(
        document: gql(r'''
          query PrescriptionByUser($userId: ID!){
            prescriptionsByUser(userId: $userId) {
              _id
              patientName
              doctorName
              date
              isPaid
              isRecived
              medicines {
                medicineId
                quantity
                doctorInstructions
              }
            }
          }
        '''),
        variables: {'userId': userProvider.user!.id},
      ),
      builder: (QueryResult result, {Refetch? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Center(
            child: Text('Error: ${result.exception.toString()}'),
          );
        }

        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data = result.data!['prescriptionsByUser'];
        // final prescriptions = data
        //     .map((prescriptionData) => Prescription.fromMap(prescriptionData))
        //     .toList();

        final prescriptions = data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Prescriptions'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return ListTile(
                  title: Text('Prescription ${prescription['_id']}'),
                  subtitle: Text(userProvider.user!.isDoctor
                      ? 'Patient: ${prescription['patientName']}'
                      : 'Doctor: ${prescription['doctorName']}'),
                  // 'Date: ${prescription['date']}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrescriptionDetailsScreen(
                          prescriptionId: prescription['_id'],
                          patientPrescription: !userProvider.user!.isDoctor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
