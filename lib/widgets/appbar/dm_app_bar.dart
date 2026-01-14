// import 'package:flutter/material.dart';
// import 'package:pharmo_app/application/utilities/colors.dart';
// import 'package:pharmo_app/controller/providers/basket_provider.dart';
// import 'package:provider/provider.dart';

// class DMAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final VoidCallback? leadingOnTap;
//   final bool showIcon;
//   final String title;
//   final List<Widget>? actions;
//   final IconData? icon;

//   const DMAppBar({
//     super.key,
//     this.leadingOnTap,
//     this.showIcon = false,
//     this.title = "",
//     this.icon,
//     this.actions,
//   }) : preferredSize = const Size.fromHeight(kToolbarHeight);

//   @override
//   final Size preferredSize;

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => BasketProvider(),
//       child: PreferredSize(
//         // preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: AppBar(
//           leading: SizedBox(),
//           centerTitle: false,
//           title: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: black,
//             ),
//           ),
//           actions: actions,
//         ),
//       ),
//     );
//   }
// }
