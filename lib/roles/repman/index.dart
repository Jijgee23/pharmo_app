import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/repman/home.dart';
import 'package:pharmo_app/roles/repman/visit_note_sheet.dart';
import 'package:pharmo_app/views/profile/profile.dart';

class IndexRep extends StatefulWidget {
  const IndexRep({super.key});
  @override
  State<IndexRep> createState() => _IndexRepState();
}

class _IndexRepState extends State<IndexRep> {
  static const List<Widget> _pages = [RepHome(), Profile()];
  static const List<String> _icons = [AssetIcon.category, AssetIcon.user];
  static const List<String> _labels = ['Нүүр', 'Профайл'];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        return Scaffold(
          extendBody: true,
          // No Scaffold-level appBar — matches IndexDriver/VanSalesIndex:
          // each tab owns its own header. RepHome has its own title row;
          // Profile is a full Scaffold with its own SliverAppBar, and
          // stacking a second fixed appbar above it used to show two
          // headers at once on that tab.
          body: Stack(
            children: [
              // IndexedStack keeps each tab's scroll position/state alive
              // across switches instead of rebuilding it from scratch.
              IndexedStack(index: home.currentIndex, children: _pages),
              // Not Scaffold.floatingActionButton — the bottom bar below is
              // a Stack overlay, not wired into Scaffold's bottomNavigationBar
              // slot, so Scaffold has no way to know its height and would
              // place a real FAB right on top of it. Positioning it here,
              // well above the bar, matches VanSalesIndex's convention.
              if (home.currentIndex == 0)
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: SafeArea(
                    child: FloatingActionButton(
                      heroTag: 'indexVISITER',
                      onPressed: _addVisit,
                      backgroundColor: primary,
                      child: const Icon(Icons.add, color: white),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomBar(icons: _icons, labels: _labels),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addVisit() {
    final rep = context.read<RepProvider>();
    showVisitNoteSheet(context, rep: rep);
  }
}
