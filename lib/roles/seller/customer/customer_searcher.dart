import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/seller/customer/add_customer.dart';
import 'package:pharmo_app/roles/seller/customer/customer_listing.dart';

/// Search box of the customers tab. Its text and search type are the tab's
/// [PharmProvider.customers] search, so they come back with the tab.
class CustomerSearcher extends StatefulWidget {
  const CustomerSearcher({super.key});

  @override
  State<CustomerSearcher> createState() => _CustomerSearcherState();
}

class _CustomerSearcherState extends State<CustomerSearcher> {
  late final CustomerListing _listing;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    _listing = context.read<PharmProvider>().customers;
    controller = TextEditingController(text: _listing.searchValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
              onChanged: _onSearch,
              hint: '${CustomerListing.searchTypes[_listing.searchType]} хайх',
              keyboardType:
                  _listing.searchType == 'name' ? TextInputType.text : TextInputType.number,
              suffixIcon: IconButton(
                onPressed: _setFilter,
                icon: const Icon(Icons.tune_rounded, size: 18),
              ),
            ),
          ),
          ModernIcon(
            iconData: Icons.person_add_alt_1_rounded,
            color: const Color(0xFF00897B),
            onPressed: () => goto(const CustomerFormScreen()),
          ),
        ],
      ),
    );
  }

  void _setFilter() {
    mySheet(
      isDismissible: true,
      title: 'Хайлтын төрөл сонгоно уу',
      children: [
        for (final MapEntry(key: type, value: label) in CustomerListing.searchTypes.entries)
          SelectedFilter(
            selected: type == _listing.searchType,
            caption: label,
            onSelect: () {
              if (_listing.searchValue.trim().isEmpty) {
                // Nothing to search by yet: only the box's label changes.
                setState(() => _listing.searchType = type);
              } else {
                _listing.search(type: type);
              }
            },
          ),
      ],
    );
  }

  void _onSearch(String value) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _listing.search(value: value));
  }
}
