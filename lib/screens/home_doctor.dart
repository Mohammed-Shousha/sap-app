import 'package:flutter/material.dart';
import 'package:sap/screens/prescriptions.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/screens/add_prescription.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/widgets/link_list_tile.dart';
import 'package:sap/widgets/logout_list_tile.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return GradientScaffold(
      appBar: AppBar(
        title: Text('Welcome, ${userProvider.user?.name}'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          LinkListTile(
            titleText: 'Create new prescription',
            leadingIcon: Icons.add,
            route: AddPrescriptionForm(),
          ),
          LinkListTile(
            titleText: 'View prescription history',
            leadingIcon: Icons.history,
            route: PrescriptionsScreen(),
          ),
          LogoutListTile(),
        ],
      ),
    );
  }
}
