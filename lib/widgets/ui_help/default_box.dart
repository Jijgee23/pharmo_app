import 'package:flutter/material.dart';

import '../../utilities/colors.dart';
import '../others/chevren_back.dart';

class DefaultBox extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const DefaultBox(
      {super.key, required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.primaryColor,
      body: Column(
        children: [
          Container(
            height: size.height * 0.1,
            decoration: BoxDecoration(color: theme.primaryColor),
            child: Center(
              child: Container(
                margin: EdgeInsets.only(top: size.height * 0.032),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ChevronBack(
                      color: Colors.white,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, letterSpacing: 2),
                    ),
                    action ?? SizedBox(width: size.width * 0.08),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: size.height * 0.9,
            padding: EdgeInsets.symmetric(
                vertical: size.height * 0.006, horizontal: size.width * 0.006),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.height * 0.02),
                topLeft: Radius.circular(size.height * 0.02),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
