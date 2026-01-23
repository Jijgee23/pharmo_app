import 'package:flutter/material.dart';
import 'package:pharmo_app/application/context/color/colors.dart';
import 'package:pharmo_app/application/context/size/sizes.dart';
import 'package:provider/provider.dart';
import '../../controller/providers/home_provider.dart';

class BottomBar extends StatelessWidget {
  final List<String> icons;
  const BottomBar({super.key, required this.icons});

  final Duration duration = const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        (MediaQuery.of(context).orientation == Orientation.portrait);
    double height = Sizes.height;
    return Consumer<HomeProvider>(builder: (context, home, child) {
      return AnimatedContainer(
        duration: duration,
        height: isPortrait ? height * 0.08 : height * .18,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: white,
          boxShadow: [
            BoxShadow(color: Colors.grey.shade500, blurRadius: 5),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: icons
                .map(
                  (icon) => BottomBarItem(
                    icon: icon,
                    index: icons.indexOf(icon),
                  ),
                )
                .toList(),
          ),
        ),
      );
    });
  }
}

class BottomBarItem extends StatelessWidget {
  final String icon;
  final int index;
  const BottomBarItem({
    super.key,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Duration duration = const Duration(milliseconds: 500);
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        bool selected = (index == home.currentIndex);
        return InkWell(
          onTap: () => home.changeIndex(index),
          child: AnimatedContainer(
            duration: duration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 5,
              children: [
                Image.asset(
                  'assets/icons_2/$icon.png',
                  height: 25,
                  width: 25,
                  color: theme.primaryColor.withOpacity(selected ? 1 : .6),
                ),
                AnimatedContainer(
                  duration: duration,
                  decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(selected ? 1 : .6),
                      borderRadius: BorderRadius.circular(5)),
                  height: 5,
                  width: selected ? 25 : 10,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
