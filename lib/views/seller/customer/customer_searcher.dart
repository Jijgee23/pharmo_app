import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/SELLER/customer/add_customer.dart';

class CustomerSearcher extends StatefulWidget {
  const CustomerSearcher({super.key});

  @override
  State<CustomerSearcher> createState() => _CustomerSearcherState();
}

class _CustomerSearcherState extends State<CustomerSearcher> {
  String selectedFilter = 'Нэрээр';
  String filter = 'name';
  setFilter(v) {
    setState(
      () {
        selectedFilter = v;
        if (v == 'Нэрээр') {
          filter = 'name';
        } else if (v == 'Утасны дугаараар') {
          filter = 'phone';
        } else {
          filter = 'rn';
        }
      },
    );
  }

  List<String> filters = ['Нэрээр', 'Утасны дугаараар', 'Регистрийн дугаараар'];
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<PharmProvider, HomeProvider>(
      builder: (context, pp, home, child) => Row(
        spacing: 10,
        children: [
          ModernField(
            controller: controller,
            onChanged: (v) => _onSearch(v, pp),
            hint: '$selectedFilter хайх',
            suffixIcon: IconButton(
              onPressed: _setFilter,
              icon: Icon(Icons.settings),
            ),
          ),
          ModernIcon(
            iconData: Icons.add_rounded,
            onPressed: () async {
              await Get.bottomSheet(
                const AddCustomerSheet(),
                isScrollControlled: true,
              );
            },
          ),
          // CartIcon()
        ],
      ),
    );
  }

  _setFilter() {
    mySheet(
      isDismissible: true,
      title: 'Хайлтын төрөл сонгоно уу?',
      children: [
        ...filters.map(
          (e) {
            bool selected = e == selectedFilter;
            return SelectedFilter(
              selected: selected,
              caption: e,
              onSelect: () => setFilter(e),
            );
          },
        )
      ],
    );
  }

  void _onSearch(String value, PharmProvider pp) {
    WidgetsBinding.instance.addPostFrameCallback(
      (cb) async {
        if (value.isEmpty) {
          await pp.getCustomers(1, 100, context);
        } else {
          await pp.filtCustomers(filter, controller.text);
        }
      },
    );
  }
}
