import 'dart:io';

import 'package:flutter/material.dart';
import '../../controllers/home_provider.dart';
import '../../utilities/colors.dart';

class BottomBar extends StatefulWidget {
  final HomeProvider homeProvider;
  final List<String> listOfIcons;
  final List<String> labels;
  const BottomBar(
      {super.key,
      required this.homeProvider,
      required this.listOfIcons,
      required this.labels});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    return SafeArea(
      top: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: EdgeInsets.symmetric(
            vertical: Platform.isIOS ? 0 : 10,
            horizontal: (orientation == Orientation.portrait)
                ? size.width * 0.25
                : size.width / 3),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade500, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
              currentIndex: widget.homeProvider.currentIndex,
              backgroundColor: Colors.white,
              useLegacyColorScheme: false,
              showUnselectedLabels: false,
              showSelectedLabels: true,
              selectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              onTap: widget.homeProvider.changeIndex,
              items: widget.listOfIcons
                  .map(
                    (i) => BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons_2/$i.png',
                        height: 20,
                        color: widget.homeProvider.currentIndex ==
                                widget.listOfIcons.indexOf(i)
                            ? AppColors.primary.withOpacity(0.9)
                            : AppColors.primary.withOpacity(.3),
                      ),
                      label: widget.labels[widget.listOfIcons.indexOf(i)],
                    ),
                  )
                  .toList()),
        ),
      ),
    );
  }
}
