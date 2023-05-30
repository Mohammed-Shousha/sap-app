import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/models/user_model.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/utils/graphql_queries.dart';
import 'package:sap/utils/shared_preferences_service.dart';

class UserProvider extends ChangeNotifier {
  final GraphQLClient client;

  UserProvider({
    required this.client,
  });

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = '';

    String userId = await getUserId();

    if (userId.isEmpty) {
      _isLoading = false;
      _errorMessage = 'User not found';
      return;
    }

    if (userId == 'admin') {
      await adminLogin('admin', 'admin');
      _isLoading = false;
      return;
    }

    UserModel user;

    try {
      user = await _getUserById(userId);
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      return;
    }

    _isLoading = false;
    _user = user;

    notifyListeners();
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
      await setUserId(_user!.id);
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
      await setUserId(_user!.id);
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
      await setUserId(_user!.id);
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
      setUserId('admin');
    } else {
      _errorMessage = 'Invalid credentials';
    }

    _isLoading = false;
    notifyListeners();
  }

  void logout() async {
    _user = null;

    await removeUserId();

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
