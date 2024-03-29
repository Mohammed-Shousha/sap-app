import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/models/medicine_model.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/utils/graphql_queries.dart';

class MedicinesProvider extends ChangeNotifier {
  final GraphQLClient client;

  MedicinesProvider({
    required this.client,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Medicine> _medicines = [];
  List<Medicine> get medicines => _medicines;

  Medicine? _medicine;
  Medicine? get medicine => _medicine;

  Future<void> getMedicines() async {
    _isLoading = true;
    _errorMessage = '';

    final result = await client.query(
      QueryOptions(
        document: gql(
          GraphQLQueries.getMedicines,
        ),
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      _errorMessage = 'Error fetching medicines';
    } else {
      final List<Medicine> medicines = (result.data?['medicines'] as List)
          .map((e) => Medicine.fromJson(e))
          .toList();

      _medicines = medicines;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getMedicine(medicineId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await client.query(
      QueryOptions(
        document: gql(
          GraphQLQueries.getMedicine,
        ),
        variables: {
          'medicineId': medicineId,
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      _errorMessage = result.exception!.graphqlErrors.first.message;
    } else {
      final Medicine medicine = Medicine.fromJson(result.data!['medicineById']);

      _medicine = medicine;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateMedicine(medicineId, addedQuantity) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await client.mutate(
      MutationOptions(
        document: gql(
          GraphQLMutations.updateMedicine,
        ),
        variables: {
          'medicineId': medicineId,
          'addedQuantity': addedQuantity,
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
