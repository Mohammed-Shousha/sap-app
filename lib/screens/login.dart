import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/utils/dropdown.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    final result = await GraphQLProvider.of(context).value.mutate(
          MutationOptions(
            document: gql(r'''
              mutation LoginUser($email: String!, $password: String!) {
                login(email: $email, password: $password) {
                  _id
                  name
                  isDoctor
                }
              }
            '''),
            variables: {
              'email': email,
              'password': password,
            },
          ),
        );

    if (result.hasException && context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Login Error'),
          content: Text(
              'Invalid email or password, ${result.exception?.graphqlErrors[0].message}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final Map<String, dynamic> userData = result.data!['login'];
      final String userId = userData['_id'];
      final String userName = userData['name'];
      final bool isDoctor = userData['isDoctor'];

      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);

      userProvider.login(userId, userName, email, isDoctor);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                handleLogin();
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
