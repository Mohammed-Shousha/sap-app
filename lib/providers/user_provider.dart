import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sap/models/user_model.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/utils/graphql_queries.dart';

class UserProvider extends ChangeNotifier {
  final GraphQLClient client;
  final SharedPreferences prefs;

  UserProvider({
    required this.client,
    required this.prefs,
  });

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> init() async {
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      String id = prefs.getString('userId') ?? '';

      _isLoading = true;
      _errorMessage = '';

      UserModel user;

      try {
        user = await _getUserById(id);
      } catch (e) {
        _isLoading = false;
        _errorMessage = e.toString();
        return;
      }

      _isLoading = false;
      _user = user;

      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await client.mutate(
      MutationOptions(
          document: gql(
            GraphQLMutations.login,
          ),
          variables: {
            'email': email,
            'password': password,
          }),
    );

    if (result.hasException) {
      _isLoading = false;
      _errorMessage = result.exception!.graphqlErrors.first.message;
    } else {
      _isLoading = false;
      _user = UserModel.fromJson(result.data!['login']);
      await _setUserId(_user!.id);
    }

    notifyListeners();
  }

  Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await client.mutate(
      MutationOptions(
          document: gql(
            GraphQLMutations.registerUser,
          ),
          variables: {
            'name': name,
            'email': email,
            'password': password,
          }),
    );

    if (result.hasException) {
      _isLoading = false;
      _errorMessage = result.exception!.graphqlErrors.first.message;
    } else {
      _isLoading = false;
      _user = UserModel.fromJson(result.data!['registerUser']);
      await _setUserId(_user!.id);
    }

    notifyListeners();
  }

  Future<void> registerDoctor(
    String name,
    String email,
    String password,
    String licenseNumber,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await client.mutate(
      MutationOptions(
        document: gql(GraphQLMutations.registerDoctor),
        variables: {
          'name': name,
          'email': email,
          'password': password,
          'licenseNumber': licenseNumber,
        },
      ),
    );

    if (result.hasException) {
      _isLoading = false;
      _errorMessage = result.exception!.graphqlErrors.first.message;
    } else {
      _isLoading = false;
      _user = UserModel.fromJson(result.data!['registerDoctor']);
      await _setUserId(_user!.id);
    }

    notifyListeners();
  }

  Future<void> adminLogin(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    if (email == 'admin' && password == 'admin') {
      _user = UserModel(
        id: 'admin',
        name: 'admin',
        email: email,
        isDoctor: false,
      );
    } else {
      _errorMessage = 'Invalid credentials';
    }

    _isLoading = false;
    notifyListeners();
  }

  void logout() async {
    _user = null;

    await _removeUserId();

    notifyListeners();
  }

  Future<UserModel?> getUser(String id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    UserModel? user;

    try {
      user = await _getUserById(id);
    } catch (e) {
      _errorMessage = e.toString();
      user = null;
    }

    _isLoading = false;

    notifyListeners();
    return user;
  }

  Future<void> _setUserId(String userId) async {
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    return;
  }

  Future<void> _removeUserId() async {
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
  }

  Future<UserModel> _getUserById(String id) async {
    final result = await client.query(
      QueryOptions(
        document: gql(
          GraphQLQueries.getUser,
        ),
        variables: {
          'userId': id,
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!.graphqlErrors.first.message;
    } else {
      return UserModel.fromJson(result.data!['user']);
    }
  }
}
