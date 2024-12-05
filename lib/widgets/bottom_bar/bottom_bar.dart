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
    var size = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    var margin = EdgeInsets.symmetric(
        vertical: Platform.isIOS ? 0 : 10,
        horizontal: (orientation == Orientation.portrait)
            ? size.width * 0.25
            : size.width / 3);
    var boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.grey.shade500, blurRadius: 10)],
    );
    return SafeArea(
      top: true,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(5),
        decoration: boxDecoration,
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
            items: _buildBarItems(),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBarItems() {
    return widget.listOfIcons.map((i) {
      int index = widget.listOfIcons.indexOf(i);
      return BottomNavigationBarItem(
        icon: Image.asset(
          'assets/icons_2/$i.png',
          height: 20,
          color: widget.homeProvider.currentIndex == index
              ? AppColors.primary.withOpacity(0.9)
              : AppColors.primary.withOpacity(0.3),
        ),
        label: widget.labels[index],
      );
    }).toList();
  }
}
