import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';
import '../../controllers/home_provider.dart';

class BottomBar extends StatelessWidget {
  final List<String> icons;
  final List<String> labels;
  const BottomBar({super.key, required this.icons, required this.labels});

  final Duration duration = const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isPortrait =
        (MediaQuery.of(context).orientation == Orientation.portrait);
    final size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    getMargin() {
      if (icons.length == 2) {
        return .15;
      } else if (icons.length == 3) {
        return .1;
      } else if (icons.length == 4) {
        return .05;
      } else {
        return .005;
      }
    }

    return Consumer<HomeProvider>(builder: (context, home, child) {
      double symmetricMargin = width * (getMargin());
      return AnimatedContainer(
        duration: duration,
        height: isPortrait ? height * 0.07 : height * .18,
        margin: EdgeInsets.only(
            bottom: 10, right: symmetricMargin, left: symmetricMargin),
        padding: EdgeInsets.symmetric(
            vertical: width * 0.01, horizontal: width * 0.01),
        decoration: BoxDecoration(
            color: theme.bottomNavigationBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(width * .1),
            boxShadow:const [ BoxShadow(color: Colors.grey, blurRadius: 10)]),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: labels
                .map(
                  (l) => BottomBarItem(
                    label: l,
                    icon: icons[labels.indexOf(l)],
                    index: labels.indexOf(l),
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
  final String label;
  final String icon;
  final int index;
  const BottomBarItem({
    super.key,
    required this.label,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Duration duration = const Duration(milliseconds: 500);
    final size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    bool isPortrait =
        (MediaQuery.of(context).orientation == Orientation.portrait);
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        bool selected = (index == home.currentIndex);
        return InkWell(
          onTap: () => home.changeIndex(index),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            width: selected ? width * 0.35 : width * 0.2,
            duration: duration,
            decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).primaryColor.withOpacity(.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(width * .1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/icons_2/$icon.png',
                  height: 20,
                  width: 20,
                  color: black,
                ),
                if (selected)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isPortrait ? height * .013 : 12,
                      fontWeight: FontWeight.bold
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
