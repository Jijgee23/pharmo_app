import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/repman/rep_session_card.dart';
import 'package:pharmo_app/roles/repman/see_map.dart';
import 'package:pharmo_app/roles/repman/visit_card.dart';
import 'package:pharmo_app/roles/repman/visit_note_sheet.dart';

/// Widest a single-column content area is allowed to grow on tablets/large
/// screens — keeps line lengths and tap targets comfortable instead of
/// stretching a phone-oriented layout edge to edge.
const double _kMaxContentWidth = 640;

class RepHome extends StatefulWidget {
  const RepHome({super.key});

  @override
  State<RepHome> createState() => _RepHomeState();
}

class _RepHomeState extends State<RepHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refresh());
  }

  Future<void> refresh() async {
    final rep = context.read<RepProvider>();
    await rep.getActiveVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RepProvider>(
      builder: (context, rep, child) {
        final visiting = rep.visiting;
        final hasVisiting = visiting != null;
        // Clears the floating BottomBar (index.dart) plus this device's own
        // bottom safe-area inset, instead of a fixed magic number that can
        // under-clear on devices with a tall gesture-navigation inset.
        final bottomClearance = MediaQuery.of(context).padding.bottom + 100;
        return DataScreen(
          loading: rep.loading,
          onRefresh: refresh,
          empty: !hasVisiting,
          customEmpty: NoResult(
            message: 'Идэвхтэй уулзалт алга',
            subMessage: 'Доод буланд байрлах товчоор шинэ уулзалт бүртгэнэ үү.',
            onRefresh: refresh,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owns its own header (title + map action) instead of relying
              // on a Scaffold-level appbar — matches ReadyOrders'/other role
              // tabs' convention, and avoids IndexRep stacking a second
              // header on top of Profile's own SliverAppBar on that tab.
              SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Миний хуваарь',
                        style: context.theme.appBarTheme.titleTextStyle,
                      ),
                    ),
                    IconButton(
                      onPressed: () => goto(const SeeMap()),
                      icon: const Icon(Icons.location_on_outlined),
                      color: primary,
                      tooltip: 'Газрын зураг',
                    ),
                  ],
                ).paddingAll(10),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasVisiting)
                              RepSessionCard(
                                visiting: visiting,
                                isTracking: rep.isTracking,
                                onStart: () => _askStart(rep),
                                onShareLocation: () => rep.startTracking(),
                                onEnd: () => _askEnd(rep),
                              ),
                            if (hasVisiting && (visiting.visits?.isNotEmpty ?? false)) ...[
                              Text(
                                'Уулзалтууд',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              ...?visiting.visits?.map(
                                (visit) => VisitCard(
                                  visit: visit,
                                  onEdit: () => _editVisit(visit),
                                ),
                              ),
                            ],
                            SizedBox(height: bottomClearance),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Rep tracking is foreground-only on both platforms (RepProvider has no
  // native background service behind it — see RepProvider.startTracking's
  // comment), so this warning applies to iOS just as much as Android.
  static const _foregroundOnlyWarning =
      'Апп-аас гарах үед байршил дамжуулахгүй болохыг анхаарна уу!';

  Future<void> _askStart(RepProvider rep) async {
    bool confirmed = await confirmDialog(
      title: 'Уулзалтыг эхлэх үү?',
      attentionText: _foregroundOnlyWarning,
      message: 'Уулзалтын үед таны байршлыг хянахыг анхаарна уу!',
    );
    if (confirmed) rep.start();
  }

  Future<void> _askEnd(RepProvider rep) async {
    bool confirmed = await confirmDialog(
      title: 'Уулзалтыг дуусгах уу?',
      attentionText: _foregroundOnlyWarning,
      message: 'Уулзалтын үед таны байршлыг хянахыг анхаарна уу!',
    );
    if (confirmed) rep.endVisiting();
  }

  void _editVisit(Visit visit) {
    final rep = context.read<RepProvider>();
    showVisitNoteSheet(context, rep: rep, visit: visit);
  }
}
