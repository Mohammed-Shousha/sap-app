import 'package:flutter/material.dart';
import 'package:sap/utils/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String message,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Error',
    content: message,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
