import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/seller/customer/add_customer.dart';

class CustomerSearcher extends StatefulWidget {
  const CustomerSearcher({super.key});

  @override
  State<CustomerSearcher> createState() => _CustomerSearcherState();
}

class _CustomerSearcherState extends State<CustomerSearcher> {
  String selectedFilter = 'Нэрээр';
  String filter = 'name';
  final TextEditingController controller = TextEditingController();
  final List<String> filters = ['Нэрээр', 'Утасны дугаараар', 'Регистрийн дугаараар'];

  void setFilter(String v) {
    setState(() {
      selectedFilter = v;
      filter = v == 'Нэрээр' ? 'name' : (v == 'Утасны дугаараар' ? 'phone' : 'rn');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, pp, _) => Row(
        spacing: 10,
        children: [
          Expanded(
            child: ModernField(
              controller: controller,
              onChanged: (v) => _onSearch(v, pp),
              hint: '$selectedFilter хайх',
              suffixIcon: IconButton(
                onPressed: _setFilter,
                icon: const Icon(Icons.tune_rounded, size: 18),
              ),
            ),
          ),
          ModernIcon(
            iconData: Icons.person_add_alt_1_rounded,
            color: const Color(0xFF00897B),
            onPressed: () => goto(AddCustomerScreen()),
          ),
        ],
      ),
    );
  }

  void _setFilter() {
    mySheet(
      isDismissible: true,
      title: 'Хайлтын төрөл сонгоно уу',
      children: filters
          .map((e) => SelectedFilter(
                selected: e == selectedFilter,
                caption: e,
                onSelect: () => setFilter(e),
              ))
          .toList(),
    );
  }

  void _onSearch(String value, PharmProvider pp) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (value.isEmpty) {
        await pp.fetchCustomers();
      } else {
        await pp.fetchCustomers(type: filter, value: value);
      }
    });
  }
}
