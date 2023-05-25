import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/screens/home_doctor.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/utils/graphql_mutations.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/custom_text_field.dart';
import 'package:sap/widgets/gradient_scaffold.dart';

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
    if (result.hasException) {
      final GraphQLError error = result.exception!.graphqlErrors.first;
      final String errorMessage = error.message;

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Register Error'),
            content: Text(errorMessage),
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
      final Map<String, dynamic> userData = result.data!['registerDoctor'];
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
            controller: _nameController,
            label: 'Name',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _licenseController,
            label: 'License Number',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 16.0),
          CustomButton(
            onPressed: () {
              handleRegister();
            },
            text: 'Register',
          ),
        ],
      ),
    );
  }
}
