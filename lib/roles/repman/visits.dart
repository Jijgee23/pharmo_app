import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/repman/visit_card.dart';
import 'package:pharmo_app/roles/repman/visit_note_sheet.dart';

/// Widest a single-column content area is allowed to grow on tablets/large
/// screens — mirrors the same cap used on [RepHome].
const double _kMaxContentWidth = 640;

const String _title = 'Өнөөдрийн уулзалтууд';

class Visits extends StatefulWidget {
  /// true (default): pushed standalone (e.g. from Profile's menu) — shows
  /// its own AppBar with a back chevron. false: shown as an IndexRep tab —
  /// no back chevron (there's nothing to pop back to from a bottom tab),
  /// an in-body title row instead, matching RepHome's own tab header.
  final bool showAppBar;

  const Visits({super.key, this.showAppBar = true});

  @override
  State<Visits> createState() => _VisitsState();
}

class _VisitsState extends State<Visits> {
  @override
  void initState() {
    super.initState();
    // Reachable directly from Profile or as a tab, not only through
    // RepHome, so the active visiting session may not have been fetched.
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
        final list = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
            child: SingleChildScrollView(
              padding: widget.showAppBar ? EdgeInsets.zero : const EdgeInsets.all(10),
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
        );
        return DataScreen(
          appbar: widget.showAppBar
              ? const CustomAppBar(title: Text(_title), leading: ChevronBack())
              : null,
          loading: rep.loading,
          onRefresh: _refresh,
          empty: visits.isEmpty,
          customEmpty: NoResult(
            message: 'Өнөөдөр бүртгэсэн уулзалт алга',
            subMessage: 'Идэвхтэй уулзалт эхлээгүй эсвэл уулзалт бүртгээгүй байна.',
            onRefresh: _refresh,
          ),
          child: widget.showAppBar
              ? list
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: context.theme.appBarTheme.titleTextStyle,
                    ).paddingAll(10),
                    const Divider(height: 1),
                    Expanded(child: list),
                  ],
                ),
        );
      },
    );
  }

  void _editVisit(RepProvider rep, Visit visit) {
    showVisitNoteSheet(context, rep: rep, visit: visit);
  }
}
