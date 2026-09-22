import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/repman/visit_card.dart';

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

  final _noteController = TextEditingController();

  void _editVisit(RepProvider rep, Visit visit) {
    _noteController.text = visit.note;
    mySheet(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            const Text('Уулзалтын мэдээлэл засах', style: TextStyle(fontSize: 16)),
            IconButton(
              onPressed: () async {
                await rep.deleteVisit(visit.id);
                if (!mounted) return;
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_forever),
              color: Colors.red,
            ),
          ],
        ),
        CustomTextField(controller: _noteController),
        CustomButton(
          text: 'Хадгалах',
          ontap: () async {
            await rep.editVisit(visit.id, _noteController.text);
            if (!mounted) return;
            Navigator.pop(context);
          },
        ),
        const SizedBox(),
      ],
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
