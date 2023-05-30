import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/models/prescription_model.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/utils/graphql_queries.dart';

class PrescriptionsProvider extends ChangeNotifier {
  final GraphQLClient client;

  PrescriptionsProvider({
    required this.client,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<PrescriptionModel> _prescriptions = [];
  List<PrescriptionModel> get prescriptions => _prescriptions;

  PrescriptionModel? _prescription;
  PrescriptionModel? get prescription => _prescription;

  num? get prescriptionTotal => _prescription?.medicines!
      .map((medicine) => medicine.price)
      .reduce((value, element) => value + element);

  Future<void> getUserPrescriptions(String userId) async {
    _isLoading = true;
    _errorMessage = '';

    final result = await client.query(
      QueryOptions(
        document: gql(
          GraphQLQueries.getUserPrescriptions,
        ),
        variables: {
          'userId': userId,
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      _isLoading = false;
      _errorMessage = 'Error fetching prescriptions';
    } else {
      _isLoading = false;
      _prescriptions = (result.data!['prescriptionsByUser'] as List)
          .map((prescription) => PrescriptionModel.fromJson(prescription))
          .toList();
    }

    notifyListeners();
  }

  Future<void> getPrescriptionDetails(prescriptionId) async {
    _isLoading = true;
    _errorMessage = '';

    final result = await client.query(
      QueryOptions(
        document: gql(
          GraphQLQueries.getPrescriptionDetails,
        ),
        variables: {
          'id': prescriptionId,
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      _isLoading = false;
      _errorMessage = 'Error fetching prescription details';
    } else {
      _isLoading = false;
      _prescription =
          PrescriptionModel.fromJson(result.data!['prescriptionById']);
    }

    notifyListeners();
  }

  Future<void> addPrescription(
    String patientId,
    String doctorId,
    List<PrescriptionMedicine> medicines,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await client.mutate(
      MutationOptions(
        document: gql(
          GraphQLMutations.addPrescription,
        ),
        variables: {
          'patientId': patientId,
          'doctorId': doctorId,
          'medicines': medicines.map((medicine) => medicine.toJson()).toList(),
        },
      ),
    );

    if (result.hasException) {
      _errorMessage = result.exception!.graphqlErrors.first.message;
    }

    _isLoading = false;

    notifyListeners();
  }
}
