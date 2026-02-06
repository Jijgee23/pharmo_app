import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/REPMAN/home.dart';
import 'package:pharmo_app/views/profile/profile.dart';
import 'package:pharmo_app/views/REPMAN/see_map.dart';

class IndexRep extends StatefulWidget {
  const IndexRep({super.key});

  @override
  State<IndexRep> createState() => _IndexRepState();
}

class _IndexRepState extends State<IndexRep> {
  // @override
  // void initState() {
  //   super.initState();
  // }

  List<Widget> pages = [RepHome(), Profile()];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: 'indexVISITER',
            onPressed: () => addVisit(),
            child: Icon(Icons.add, color: Colors.white),
          ),
          extendBody: true,
          appBar: CustomAppBar(
            title: appBarSingleText('Миний профайл'),
            actions: [
              IconButton(
                onPressed: () => goto(SeeMap()),
                icon: Icon(Icons.location_on),
                color: Colors.indigo,
              ),
            ],
          ),
          body: pages[homeProvider.currentIndex],
          bottomNavigationBar: BottomBar(
            icons: icons,
            labels: ['Нүүр', 'Профайл'],
          ),
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
    return Text(v,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  List<String> icons = [AssetIcon.category, AssetIcon.user];
}
