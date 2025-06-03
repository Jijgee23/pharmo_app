import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/rep_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/inputs/ibtn.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:provider/provider.dart';

class RepHome extends StatefulWidget {
  const RepHome({super.key});

  @override
  State<RepHome> createState() => _RepHomeState();
}

class _RepHomeState extends State<RepHome> {
  @override
  void initState() {
    super.initState();
    refresh();
  }

  refresh() async {
    final rep = context.read<RepProvider>();
    await rep.getActiveVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RepProvider>(builder: (context, rep, child) {
      final hasVisit = rep.visiting != null;
      return DataScreen(
        loading: rep.loading,
        onRefresh: () async => await refresh(),
        empty: !hasVisit,
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasVisit && rep.visiting!.outOn == null)
                CustomButton(
                    text: 'Уулзалтанд гарах', ontap: () => askStart(rep)),
              if (hasVisit)
                ...rep.visiting!.visits!.map((e) => visitBuilder(e)),
              if (hasVisit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        text: 'Байршил дамжуулах',
                        ontap: () async => rep.startTracking()),
                    CustomButton(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        text: 'Уулзалт дуусгах',
                        ontap: () async => askEnd(rep)),
                  ],
                ),
              SizedBox(height: kTextTabBarHeight * 3),
            ],
          ),
        ),
      );
    });
  }

  askStart(RepProvider rep) {
    askDialog(
      context,
      () async {
        rep.start();
        Navigator.pop(context);
      },
      'Уулзалтыг эхлүүлэх үү?',
      [],
    );
  }

  askEnd(RepProvider rep) {
    askDialog(
      context,
      () async {
        rep.endVisiting();
        Navigator.pop(context);
      },
      'Уулзалтыг дуусгах уу?',
      [],
    );
  }

  visitBuilder(Visit visit) {
    final rep = context.read<RepProvider>();
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blue.withAlpha(70),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(visit.note, style: TextStyle(color: black)),
                  Text(visit.createdAt.substring(0, 10),
                      style: TextStyle(
                        color: grey600,
                        fontSize: 12,
                      )),
                ],
              ),
              Ibtn(
                onTap: () => editVisit(visit),
                icon: Icons.edit,
                color: Colors.green,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              btn('Ирсэн', () async => await rep.comedVisit(visit.id)),
              btn('Явсан', () async => await rep.leftVisit(visit.id)),
            ],
          )
        ],
      ),
    );
  }

  // continiuSharing() async {
  //   final pref = await SharedPreferences.getInstance();
  //   int? vId = pref.getInt('visitId');
  //   // LocationService().startTracking(vId!);
  // }

  final note = TextEditingController();
  editVisit(Visit visit) {
    final rep = context.read<RepProvider>();
    setState(() {
      note.text = visit.note;
    });
    mySheet(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Text('Уулзалтын мэдээлэл засах', style: TextStyle(fontSize: 16)),
          Ibtn(
              onTap: () async {
                await rep.deleteVisit(visit.id);
                Navigator.pop(context);
              },
              icon: Icons.delete,
              color: Colors.white,
              bColor: Colors.red),
        ],
      ),
      CustomTextField(controller: note),
      CustomButton(
        text: 'Хадгалах',
        ontap: () async {
          await rep.editVisit(visit.id, note.text);
          Navigator.pop(context);
        },
      ),
      SizedBox()
    ]);
  }

  btn(String title, Function() ontap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
            10,
          ))),
      onPressed: ontap,
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: white),
        ),
      ),
    );
  }
}
