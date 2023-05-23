import 'package:flutter/material.dart';
import 'package:sap/utils/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Logout',
    content: 'Are you sure you want to logout?',
    optionsBuilder: () => {
      'Logout': true,
      'Cancel': false,
    },
  ).then(
    (value) => value ?? false,
  );
}
