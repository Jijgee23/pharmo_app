import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/home_provider.dart';

// class BottomBar extends StatefulWidget {
//   final HomeProvider homeProvider;
//   final List<String> listOfIcons;
//   final List<String> labels;
//   const BottomBar(
//       {super.key,
//       required this.homeProvider,
//       required this.listOfIcons,
//       required this.labels});

//   @override
//   State<BottomBar> createState() => _BottomBarState();
// }

// class _BottomBarState extends State<BottomBar> {
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var theme = Theme.of(context);
//     var orientation = MediaQuery.of(context).orientation;
//     var margin = EdgeInsets.symmetric(
//         vertical: Platform.isIOS ? 0 : 10,
//         horizontal: (orientation == Orientation.portrait)
//             ? size.width * 0.25
//             : size.width / 3);
//     var boxDecoration = BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         color: theme.cardColor,
//         border: Border.all(color: Colors.white)
//         );
//     return SafeArea(
//       top: true,
//       child: Container(
//         margin: margin,
//         decoration: boxDecoration,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BottomNavigationBar(
//             currentIndex: widget.homeProvider.currentIndex,
//             useLegacyColorScheme: false,
//             showUnselectedLabels: false,
//             showSelectedLabels: true,
//             selectedFontSize: 10,
//             type: BottomNavigationBarType.fixed,
//             onTap: widget.homeProvider.changeIndex,
//             items: _buildBarItems(context),
//           ),
//         ),
//       ),
//     );
//   }

//   List<BottomNavigationBarItem> _buildBarItems(BuildContext context) {
//     var theme = Theme.of(context);
//     return widget.listOfIcons.map((i) {
//       int index = widget.listOfIcons.indexOf(i);
//       return BottomNavigationBarItem(
//         icon: Image.asset(
//           'assets/icons_2/$i.png',
//           height: 20,
//           color: theme.bottomNavigationBarTheme.selectedItemColor,
//         ),
//         label: widget.labels[index],
//       );
//     }).toList();
//   }
// }

class BottomBar extends StatelessWidget {
  final List<String> icons;
  final List<String> labels;
  const BottomBar({super.key, required this.icons, required this.labels});

  // List<String> labels = ['Home', 'Favorites', 'Search', 'Cart'];
  final Duration duration = const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isPortrait =
        (MediaQuery.of(context).orientation == Orientation.portrait);
    final size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return AnimatedContainer(
      duration: duration,
      height: isPortrait ? height * 0.07 : height * .18,
      margin:
          EdgeInsets.only(bottom: 10, right: width * (0.1), left: width * 0.1),
      padding: EdgeInsets.symmetric(
          vertical: width * 0.01, horizontal: width * 0.01),
      decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(width * .1),
          border: Border.all(color: Colors.grey.shade300)),
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
            width: selected ? width * 0.3 : width * 0.2,
            duration: duration,
            decoration: BoxDecoration(
                color: selected ? Colors.grey.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(width * .1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/icons_2/$icon.png',
                  height: 20,
                  width: 20,
                  color: Colors.black,
                ),
                if (selected)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isPortrait ? height * .013 : 12,
                      fontWeight: FontWeight.w500,
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
