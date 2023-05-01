import 'package:logger/logger.dart';
import 'package:sap/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/utils/graphql_queries.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final GraphQLClient client;
  final SharedPreferences prefs;

  UserProvider({
    required this.client,
    required this.prefs,
  });

  UserModel? get user => _user;

  Future<void> init() async {
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      String id = prefs.getString('userId') ?? '';

      final result = await client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUser),
          variables: {
            'userId': id,
          },
        ),
      );

      if (result.hasException) {
        Logger().e(result.exception?.graphqlErrors[0].message);
      } else {
        Logger().i(result.data);
        _user = UserModel.fromJson(result.data!['user']);
        notifyListeners();
      }
    }
  }

  void login(
    String id,
    String name,
    String email,
    bool isDoctor,
  ) async {
    _user = UserModel(
      id: id,
      name: name,
      email: email,
      isDoctor: isDoctor,
    );

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', id);

    notifyListeners();
  }

  void logout() async {
    _user = null;

    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');

    notifyListeners();
  }
}
