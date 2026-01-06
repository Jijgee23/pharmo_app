import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';

class DefInputContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final Function()? ontap;
  final double? width;
  const DefInputContainer({super.key, required this.child, this.ontap, this.title, this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Column(
        children: [
          if (title != null) SmallText(title!),
          Container(
            margin: EdgeInsets.only(top: title != null ? 10 : 0),
            decoration: BoxDecoration(
              border: Border.all(color: theme.primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            width: width,
            padding: const EdgeInsets.all(Sizes.smallFontSize),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}
