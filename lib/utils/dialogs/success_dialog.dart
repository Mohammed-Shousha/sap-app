import 'package:flutter/material.dart';
import 'package:sap/utils/dialogs/generic_dialog.dart';

Future<void> showSuccessDialog(
  BuildContext context,
  String message,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Success',
    content: message,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
