import 'package:flutter/material.dart';
import 'package:sap/widgets/custom_list_tile.dart';

class LinkListTile extends StatelessWidget {
  final String titleText;
  final IconData leadingIcon;
  final Widget route;

  const LinkListTile({
    super.key,
    required this.titleText,
    required this.leadingIcon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      titleText: titleText,
      leadingIcon: leadingIcon,
      onTap: () {
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
