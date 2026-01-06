import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';

class NoResult extends StatelessWidget {
  const NoResult({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Sizes.height * .3),
          Text(
            'Үр дүн олдсонгүй',
            style: TextStyle(
              fontSize: Sizes.mediumFontSize,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor
            ),
          ),
          SizedBox(height: Sizes.bigFontSize),
          Image.asset(
            'assets/icons/not-found.png',
            width: Sizes.width * 0.3,
          ),
        ],
      ),
    );
  }
}
