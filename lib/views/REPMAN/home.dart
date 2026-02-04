import 'dart:io';
import 'package:pharmo_app/application/application.dart';

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

  askStart(RepProvider rep) async {
    bool confirmed = await confirmDialog(
      context: context,
      title: 'Уулзалтыг эхлэх үү?',
      attentionText: Platform.isAndroid
          ? 'Апп-аас гарах үед байршил дамжуулахгүй болохыг анхаарна уу!'
          : null,
      message: 'Уулзалтын үед таны байршлыг хянахыг анхаарна уу!',
    );
    if (confirmed) rep.start();
  }

  askEnd(RepProvider rep) async {
    bool confirmed = await confirmDialog(
      context: context,
      title: 'Уулзалтыг дуусгах уу?',
      attentionText: Platform.isAndroid
          ? 'Апп-аас гарах үед байршил дамжуулахгүй болохыг анхаарна уу!'
          : null,
      message: 'Уулзалтын үед таны байршлыг хянахыг анхаарна уу!',
    );
    if (confirmed) rep.endVisiting();
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
              IconButton(
                onPressed: () => editVisit(visit),
                icon: Icon(Icons.edit),
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
          IconButton(
            onPressed: () async {
              await rep.deleteVisit(visit.id);
              Navigator.pop(context);
            },
            icon: Icon(Icons.delete_forever),
            color: Colors.red,
          ),
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
