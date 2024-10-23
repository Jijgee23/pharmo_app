import 'package:flutter/material.dart';

import '../utilities/colors.dart';
import 'others/chevren_back.dart';

class DefaultBox extends StatelessWidget {
  final String title;
  final Widget child;
  const DefaultBox({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: size.height * 0.1,
          decoration: const BoxDecoration(color: AppColors.primary),
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
                  SizedBox(width: size.width * 0.08)
                ],
              ),
            ),
          ),
        ),
        Container(
          height: size.height * 0.9,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(size.width * 0.05),
              topLeft: Radius.circular(size.width * 0.05),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}
