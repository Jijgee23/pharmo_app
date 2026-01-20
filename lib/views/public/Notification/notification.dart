// import 'package:pharmo_app/application/application.dart';

// class NotificationPage extends StatelessWidget {
//   const NotificationPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomAppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(
//             Icons.chevron_left,
//           ),
//         ),
//         title: const Text('Мэдэгдэлүүд'),
//       ),
//       body: Container(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 20,
//                 shrinkWrap: true,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     padding: const EdgeInsets.all(10),
//                     margin: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: Colors.grey,
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text('Гарчиг'),
//                         ),
//                         Container(
//                           margin: const EdgeInsets.symmetric(
//                               vertical: 5, horizontal: 3),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 5, vertical: 5),
//                           child: const Text(
//                               'This implementation uses a custom SnackBar with a SlideTransition animation to create a sliding effect when the SnackBar appears and disappears. '),
//                         )
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
