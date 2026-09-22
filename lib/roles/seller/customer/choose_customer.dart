import 'package:pharmo_app/application/application.dart';

class ChooseCustomer extends StatefulWidget {
  const ChooseCustomer({super.key});

  @override
  State<ChooseCustomer> createState() => _ChooseCustomerState();
}

class _ChooseCustomerState extends State<ChooseCustomer> {
  final TextEditingController query = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String selectedFilter = 'Нэрээр';
  String filter = 'name';

  final List<String> filters = ['Нэрээр', 'Утасны дугаараар', 'Регистрийн дугаараар'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PharmProvider>().fetchCustomers();
    });
  }

  @override
  void dispose() {
    query.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<PharmProvider>().fetchMoreCustomers();
    }
  }

  void setFilter(String v) {
    setState(() {
      selectedFilter = v;
      filter = v == 'Нэрээр' ? 'name' : (v == 'Утасны дугаараар' ? 'phone' : 'rn');
    });
  }

  void _onSearch(String v, PharmProvider pp) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (v.isEmpty) {
        await pp.fetchCustomers();
      } else {
        await pp.fetchCustomers(type: filter, value: v);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, provider, _) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ModernField(
              controller: query,
              onChanged: (v) => _onSearch(v, provider),
              hint: '$selectedFilter хайх',
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune_rounded, size: 18),
                onPressed: _showFilterMenu,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Active filter badge
            if (selectedFilter != 'Нэрээр')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF00897B).withOpacity(0.06),
                child: Row(
                  spacing: 6,
                  children: [
                    Icon(Icons.filter_alt_outlined, size: 14, color: const Color(0xFF00897B)),
                    Text(
                      selectedFilter,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: provider.filteredCustomers.isEmpty && !provider.fetchingMore
                  ? _emptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: provider.filteredCustomers.length + 1,
                      itemBuilder: (context, index) {
                        if (index == provider.filteredCustomers.length) {
                          return _footer(provider);
                        }
                        return _customerItem(provider.filteredCustomers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerItem(Customer e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBF2F1)),
      ),
      child: ListTile(
        onTap: () => Navigator.pop(context, e),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF00897B).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (e.name ?? '?').substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF00897B),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        title: Text(
          e.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          'РД: ${e.rn ?? "-"}',
          style: const TextStyle(color: Color(0xFF6B8280), fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFD0DCDB), size: 20),
      ),
    );
  }

  Widget _footer(PharmProvider pp) {
    if (pp.fetchingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (!pp.hasMore && pp.filteredCustomers.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Нийт ${pp.totalCount} харилцагч',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Icon(Icons.person_off_outlined, size: 56, color: Colors.grey.shade300),
          Text(
            'Харилцагч олдсонгүй',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    mySheet(
      title: 'Хайлтын төрөл сонгоно уу',
      children: filters
          .map((e) => SelectedFilter(
                selected: selectedFilter == e,
                caption: e,
                onSelect: () => setFilter(e),
              ))
          .toList(),
    );
  }
}
