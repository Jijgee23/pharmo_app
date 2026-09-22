import 'dart:io';

import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/repman/visit_card.dart';

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
        final hasVisit = rep.visiting != null;
        // Clears the floating BottomBar (index.dart) plus this device's own
        // bottom safe-area inset, instead of a fixed magic number that can
        // under-clear on devices with a tall gesture-navigation inset.
        final bottomClearance = MediaQuery.of(context).padding.bottom + 100;
        return DataScreen(
          loading: rep.loading,
          onRefresh: refresh,
          empty: !hasVisit,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasVisit && rep.visiting!.outOn == null)
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Уулзалтанд гарах',
                          ontap: () => _askStart(rep),
                        ),
                      ),
                    if (hasVisit)
                      ...?rep.visiting!.visits?.map(
                        (visit) => VisitCard(
                          visit: visit,
                          onEdit: () => _editVisit(visit),
                        ),
                      ),
                    if (hasVisit)
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Байршил дамжуулах',
                              ontap: () => rep.startTracking(),
                            ),
                          ),
                          Expanded(
                            child: CustomButton(
                              text: 'Уулзалт дуусгах',
                              ontap: () => _askEnd(rep),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: bottomClearance),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _askStart(RepProvider rep) async {
    bool confirmed = await confirmDialog(
      title: 'Уулзалтыг эхлэх үү?',
      attentionText: Platform.isAndroid
          ? 'Апп-аас гарах үед байршил дамжуулахгүй болохыг анхаарна уу!'
          : null,
      message: 'Уулзалтын үед таны байршлыг хянахыг анхаарна уу!',
    );
    if (confirmed) rep.start();
  }

  Future<void> _askEnd(RepProvider rep) async {
    bool confirmed = await confirmDialog(
      title: 'Уулзалтыг дуусгах уу?',
      attentionText: Platform.isAndroid
          ? 'Апп-аас гарах үед байршил дамжуулахгүй болохыг анхаарна уу!'
          : null,
      message: 'Уулзалтын үед таны байршлыг хянахыг анхаарна уу!',
    );
    if (confirmed) rep.endVisiting();
  }

  final _noteController = TextEditingController();

  void _editVisit(Visit visit) {
    final rep = context.read<RepProvider>();
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
