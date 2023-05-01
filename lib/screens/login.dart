import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/medicine_position.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    //admin login
    if (email == 'admin' && password == 'admin') {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const MedicinePosition(),
          ),
          (route) => false,
        );
      }
      return;
    }

    final result = await GraphQLProvider.of(context).value.mutate(
          MutationOptions(
            document: gql(GraphQLMutations.login),
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
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            // autofocus: true,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 32.0),
          CustomButton(
            onPressed: () => handleLogin(),
            text: 'Login',
          ),
        ],
      ),
    );
  }
}
