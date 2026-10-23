import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';

/// Shown right after a successful Pharmacist (PA) login when the staff
/// member belongs to more than one branch — picks the branch to act as via
/// PATCH select_branch/, which swaps the stored access token for one
/// scoped to that branch. Blocking (not dismissible, no drag/back): a
/// branch must be chosen before the app can proceed to the home screen.
Future<void> showSelectBranchSheet() {
  return Get.bottomSheet(
    const SelectBranchSheet(),
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
  );
}

class SelectBranchSheet extends StatefulWidget {
  const SelectBranchSheet({super.key});

  @override
  State<SelectBranchSheet> createState() => _SelectBranchSheetState();
}

class _SelectBranchSheetState extends State<SelectBranchSheet> {
  int? _submittingId;

  Future<void> _select(HomeProvider home, Sector sector) async {
    if (_submittingId != null) return;
    setState(() => _submittingId = sector.id);
    final ok = await home.selectBranch(sector.id);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _submittingId = null);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer<HomeProvider>(
        builder: (context, home, child) => Container(
          constraints: BoxConstraints(maxHeight: context.height * .8),
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Row(
                    children: [
                      const AuthIconTile(icon: Icons.storefront_rounded, size: 56),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AuthText('Салбар сонгох', fontSize: 22),
                            const SizedBox(height: 4),
                            AuthSubtitle(
                              'Та ${home.branches.length} салбарт харьяалагддаг. Аль салбараар ажиллахаа сонгоно уу.',
                              fontSize: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: home.branches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final sector = home.branches[index];
                      return _BranchTile(
                        sector: sector,
                        loading: _submittingId == sector.id,
                        enabled: _submittingId == null,
                        onTap: () => _select(home, sector),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  final Sector sector;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _BranchTile({
    required this.sector,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    final phone = sector.phone;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || loading ? 1 : 0.5,
      child: Material(
        color: loading ? primaryColor.withValues(alpha: 0.06) : grey100,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: loading ? primaryColor : grey200, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.home_work_outlined, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              sector.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                          if (sector.isMain) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Үндсэн',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (phone != null && phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(phone, style: TextStyle(color: grey500, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: primaryColor),
                      )
                    : Icon(Icons.chevron_right_rounded, color: grey400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
