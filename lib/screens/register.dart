import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/home.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/custom_text_field.dart';
import 'package:sap/widgets/gradient_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isValidPassword(String password) {
    RegExp regex = RegExp(r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{8,}$');
    return regex.hasMatch(password);
  }

  void handleRegister() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    final result = await GraphQLProvider.of(context).value.mutate(
          MutationOptions(
            document: gql(GraphQLMutations.registerUser),
            variables: {
              'name': name,
              'email': email,
              'password': password,
            },
          ),
        );
    if (result.hasException) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Register Error'),
            content: const Text('User already exists'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      final Map<String, dynamic> userData = result.data!['registerUser'];
      final String userId = userData['_id'];
      final String userName = userData['name'];
      final bool isDoctor = userData['isDoctor'];

      if (context.mounted) {
        final UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);

        userProvider.login(userId, userName, email, isDoctor);

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
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Name',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            label: 'Email',
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16.0),
          CustomButton(
            onPressed: () => handleRegister(),
            text: 'Register',
          ),
        ],
      ),
    );
  }
}
