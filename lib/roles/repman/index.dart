import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/repman/home.dart';
import 'package:pharmo_app/roles/repman/see_map.dart';
import 'package:pharmo_app/views/profile/profile.dart';

class IndexRep extends StatefulWidget {
  const IndexRep({super.key});

  @override
  State<IndexRep> createState() => _IndexRepState();
}

class _IndexRepState extends State<IndexRep> {
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
          body: Stack(
            children: [
              pages[homeProvider.currentIndex],
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomBar(
                  icons: icons,
                  labels: ['Нүүр', 'Профайл'],
                ),
              ),
            ],
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
          if (!mounted) return;
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
