import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/repman/visit_card.dart';
import 'package:pharmo_app/roles/repman/visit_note_sheet.dart';

/// Widest a single-column content area is allowed to grow on tablets/large
/// screens — mirrors the same cap used on [RepHome].
const double _kMaxContentWidth = 640;

class Visits extends StatefulWidget {
  const Visits({super.key});

  @override
  State<Visits> createState() => _VisitsState();
}

class _VisitsState extends State<Visits> {
  @override
  void initState() {
    super.initState();
    // Reachable directly from Profile, not only through RepHome, so the
    // active visiting session may not have been fetched yet.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    await context.read<RepProvider>().getActiveVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RepProvider>(
      builder: (context, rep, child) {
        final visits = rep.visiting?.visits ?? [];
        return DataScreen(
          appbar: const CustomAppBar(
            title: Text('Өнөөдрийн уулзалтууд'),
            leading: ChevronBack(),
          ),
          loading: rep.loading,
          onRefresh: _refresh,
          empty: visits.isEmpty,
          customEmpty: NoResult(
            message: 'Өнөөдөр бүртгэсэн уулзалт алга',
            subMessage: 'Идэвхтэй уулзалт эхлээгүй эсвэл уулзалт бүртгээгүй байна.',
            onRefresh: _refresh,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  children: visits
                      .map(
                        (visit) => VisitCard(
                          visit: visit,
                          onEdit: () => _editVisit(rep, visit),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _editVisit(RepProvider rep, Visit visit) {
    showVisitNoteSheet(context, rep: rep, visit: visit);
  }
}
