import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sap/widgets/custom_list_tile.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/start.dart';
import 'package:sap/utils/dialogs/logout_dialog.dart';

class LogoutListTile extends StatelessWidget {
  const LogoutListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return CustomListTile(
      titleText: 'Logout',
      leadingIcon: Icons.logout,
      onTap: () async {
        final shouldLogout = await showLogoutDialog(context);

        if (shouldLogout && context.mounted) {
          userProvider.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const StartScreen(),
            ),
            (route) => false,
          );
        }
      },
    );
  }
}
