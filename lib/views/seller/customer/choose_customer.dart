import 'package:pharmo_app/application/application.dart';

class ChooseCustomer extends StatefulWidget {
  const ChooseCustomer({super.key});

  @override
  State<ChooseCustomer> createState() => _ChooseCustomerState();
}

class _ChooseCustomerState extends State<ChooseCustomer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PharmProvider>().getCustomers(1, 100, context);
    });
  }

  TextEditingController query = TextEditingController();
  String selectedFilter = 'Нэрээр';
  String filter = 'name';

  void setFilter(String v) {
    setState(() {
      selectedFilter = v;
      filter =
          v == 'Нэрээр' ? 'name' : (v == 'Утасны дугаараар' ? 'phone' : 'rn');
    });
  }

  List<String> filters = ['Нэрээр', 'Утасны дугаараар', 'Регистрийн дугаараар'];

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black87, size: 20),
            ),
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _buildSearchField(provider),
            ),
          ),
          body: Column(
            children: [
              // Сонгосон шүүлтүүрийг харуулах жижиг Badge
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Text(
                  'Шүүлтүүр: $selectedFilter',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: provider.filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final e = provider.filteredCustomers[index];
                          return _buildCustomerItem(e);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Хайлтын талбар
  Widget _buildSearchField(PharmProvider provider) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: query,
        onChanged: (v) => provider.filtCustomers(filter, v),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: '$selectedFilter хайх...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, size: 20, color: primary),
            onPressed: () => _showFilterMenu(),
          ),
        ),
      ),
    );
  }

  // Харилцагчийн мөр (Item)
  Widget _buildCustomerItem(Customer e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: () => Navigator.pop(context, e),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: primary.withOpacity(0.1),
          child: Text(
            (e.name ?? '?').substring(0, 1).toUpperCase(),
            style: const TextStyle(color: primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          e.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          'РД: ${e.rn ?? "-"}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Харилцагч олдсонгүй',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    mySheet(
      title: 'Хайлтын төрөл сонгоно уу',
      children: [
        ...filters.map(
          (e) => SelectedFilter(
            selected: selectedFilter == e,
            caption: e,
            onSelect: () => setFilter(e),
          ),
        )
      ],
    );
  }
}
