import 'package:pharmo_app/application/application.dart';

/// Shown right after a successful Pharmacist (PA) login when the staff
/// member belongs to more than one branch — picks the branch to act as via
/// PATCH select_branch/, which swaps the stored access token for one
/// scoped to that branch. Blocking (no back button/swipe-to-dismiss): a
/// branch must be chosen before the app can proceed to the home screen.
class SelectBranchPage extends StatefulWidget {
  const SelectBranchPage({super.key});

  @override
  State<SelectBranchPage> createState() => _SelectBranchPageState();
}

class _SelectBranchPageState extends State<SelectBranchPage> {
  bool _submitting = false;

  Future<void> _select(HomeProvider home, Sector sector) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final ok = await home.selectBranch(sector.id);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Салбараа сонгоно уу'),
            ),
            body: SafeArea(
              child: _submitting
                  ? const Center(child: PharmoIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: home.branches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final sector = home.branches[index];
                        return InkWell(
                          onTap: () => _select(home, sector),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.home_work_outlined, color: primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    sector.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
