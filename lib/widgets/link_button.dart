import 'package:flutter/material.dart';
import 'package:sap/widgets/custom_button.dart';

class LinkButton extends StatelessWidget {
  final String text;
  final Widget route;

  const LinkButton({
    super.key,
    required this.text,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => route,
          ),
        );
      },
    );
  }
}
