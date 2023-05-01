import 'package:flutter/material.dart';
import 'package:sap/utils/palette.dart';

class CustomListTile extends StatelessWidget {
  final String titleText;
  final String subtitleText;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  const CustomListTile({
    Key? key,
    required this.titleText,
    this.subtitleText = '',
    this.leadingIcon,
    this.trailingIcon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          leadingIcon,
        ),
        trailing: Icon(
          trailingIcon,
        ),
        iconColor: Palette.primary,
        title: Text(
          titleText,
        ),
        subtitle: subtitleText.isNotEmpty ? Text(subtitleText) : null,
        onTap: onTap,
      ),
    );
  }
}
