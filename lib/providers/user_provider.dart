import 'package:logger/logger.dart';
import 'package:sap/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserProvider({required this.client});

  UserModel? get user => _user;

  final GraphQLClient client;

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      String id = prefs.getString('userId') ?? '';

      final result = await client.query(
        QueryOptions(
          document: gql(r'''
                    query user($id: ID!) {
                      user(id: $id) {
                        _id
                        name
                        email
                        isDoctor
                      }
                    }
                  '''),
          variables: {
            'id': id,
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('userId', id);

    notifyListeners();
  }

  void logout() async {
    _user = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('userId');

    notifyListeners();
  }
}
