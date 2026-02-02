import 'package:flutter/material.dart';
import 'package:pharmo_app/application/context/size/sizes.dart';
import 'package:provider/provider.dart';
import '../../controller/providers/home_provider.dart';

class BottomBar extends StatelessWidget {
  final List<String> icons;
  final List<String> labels; // Текст нэмэхийн тулд нэмэлт жагсаалт

  const BottomBar({super.key, required this.icons, required this.labels});

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            // Notch-той утсанд зориулсан хамгаалалт
            top: false,
            child: Container(
              height: isPortrait ? 70 : 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(icons.length, (index) {
                  return BottomBarItem(
                    icon: icons[index],
                    label: labels.length > index ? labels[index] : '',
                    index: index,
                    isSelected: home.currentIndex == index,
                    onTap: () => home.changeIndex(index),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BottomBarItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = theme.primaryColor;
    final Color inactiveColor = Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Икон хэсэг
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: activeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Image.asset(
                    'assets/icons_2/$icon.png',
                    height: 24,
                    width: 24,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // 2. Текст болон Indicator
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                width: isSelected ? 12 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
