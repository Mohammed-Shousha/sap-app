import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/home.dart';
import 'package:sap/utils/dialogs/error_dialog.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/custom_text_field.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    if (result.hasException && mounted) {
      showErrorDialog(context, result.exception!.graphqlErrors.first.message);
    } else {
      UserModel user = UserModel.fromJson(result.data!['registerUser']);

      if (mounted) {
        final UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);

        userProvider.login(user);

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
            label: 'Name',
            controller: _nameController,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Password',
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Register',
            onPressed: handleRegister,
          ),
        ],
      ),
    );
  }
}
