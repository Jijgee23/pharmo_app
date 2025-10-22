import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/rep_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/rep_man/home.dart';
import 'package:pharmo_app/views/profile.dart';
import 'package:pharmo_app/views/rep_man/see_map.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/inputs/ibtn.dart';
import 'package:provider/provider.dart';

class IndexRep extends StatefulWidget {
  const IndexRep({super.key});

  @override
  State<IndexRep> createState() => _IndexRepState();
}

class _IndexRepState extends State<IndexRep> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> pages = [RepHome(), Profile()];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => addVisit(),
            child: Icon(Icons.add, color: Colors.white),
          ),
          extendBody: true,
          appBar: CustomAppBar(
            title: appBarSingleText('Миний профайл'),
            hasBasket: false,
            actions: [
              Ibtn(onTap: () => goto(SeeMap()), icon: Icons.location_on, color: Colors.indigo)
            ],
          ),
          body: pages[homeProvider.currentIndex],
          bottomNavigationBar: BottomBar(icons: icons),
        );
      },
    );
  }

  final note = TextEditingController();

  addVisit() async {
    final rep = context.read<RepProvider>();
    mySheet(title: 'Уулзалт бүртгэх', children: [
      CustomTextField(controller: note),
      CustomButton(
        text: 'Бүртгэх',
        ontap: () async {
          await rep.addVisit(note.text);
          Navigator.pop(context);
          setState(() {
            note.clear();
          });
        },
      ),
      SizedBox()
    ]);
  }

  appBarSingleText(String v) {
    return Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  List<String> icons = ['category', 'user'];
}
