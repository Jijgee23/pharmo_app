// import 'package:pharmo_app/controller/providers/a_controlller.dart';
// import 'package:pharmo_app/widgets/inputs/custom_button.dart';

// class Driver extends StatefulWidget {
//   const Driver({super.key});

//   @override
//   State<Driver> createState() => _DriverState();
// }

// class _DriverState extends State<Driver> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<JaggerProvider>(
//       builder: (context, jagger, child) {
//         return Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               if (jagger.subscription != null) Text('listening'),
//               CustomButton(
//                 text: 'end',
//                 ontap: () => jagger.stopDemo(),
//               ),
//               CustomButton(
//                 text: 'start',
//                 ontap: () => jagger.demoTrackStart(),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
