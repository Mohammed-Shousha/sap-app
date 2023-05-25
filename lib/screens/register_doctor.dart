import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/screens/home_doctor.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/utils/dialogs/error_dialog.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/custom_text_field.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/models/user_model.dart';

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _licenseController = TextEditingController();

  void handleRegister() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String license = _licenseController.text.trim();

    final result = await GraphQLProvider.of(context).value.mutate(
          MutationOptions(
            document: gql(GraphQLMutations.registerDoctor),
            variables: {
              'name': name,
              'email': email,
              'password': password,
              'licenseNumber': license,
            },
          ),
        );
    if (result.hasException && mounted) {
      showErrorDialog(context, result.exception!.graphqlErrors.first.message);
    } else {
      final user = UserModel.fromJson(result.data!['registerDoctor']);

      if (mounted) {
        final UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);

        userProvider.login(user);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorHomeScreen(),
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
        title: const Text('Register Doctor'),
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
            label: 'License Number',
            controller: _licenseController,
            keyboardType: TextInputType.number,
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
