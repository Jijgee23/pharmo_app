import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/utilities/a_utils.dart';

class ChooseCustomer extends StatefulWidget {
  const ChooseCustomer({super.key});

  @override
  State<ChooseCustomer> createState() => _ChooseCustomerState();
}

class _ChooseCustomerState extends State<ChooseCustomer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PharmProvider>().getCustomers(1, 100, context);
    });
  }

  TextEditingController query = TextEditingController();
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
  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.chevron_left, color: black),
            ),
            shadowColor: grey200,
            elevation: 1,
            surfaceTintColor: white,
            backgroundColor: white,
            title: TextFormField(
              controller: query,
              onChanged: (v) => value.filtCustomers(filter, v),
              style: TextStyle(color: black, fontSize: 14),
              cursorHeight: 14,
              cursorColor: black,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: black),
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: selectedFilter,
                hintStyle: TextStyle(color: black, fontSize: 14),
                filled: true,
                fillColor: primary.withAlpha(30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: InkWell(
                  onTap: () => _setFilter(),
                  child: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ...value.filteredCustomers.map(
                  (e) => Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade500),
                      ),
                    ),
                    child: ListTile(
                      onTap: () async => Get.back(result: e),
                      dense: true,
                      title: Text(
                        e.name ?? '',
                        style: TextStyle(color: black),
                      ),
                      subtitle: Text(
                        e.rn ?? '',
                        style: TextStyle(color: black),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: black,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _setFilter() {
    showMenu(
      color: Colors.white,
      context: context,
      shadowColor: Colors.grey.shade500,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        ...filters.map(
          (f) => PopupMenuItem(
            child: Text(
              f,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: black,
              ),
            ),
            onTap: () => setFilter(f),
          ),
        )
      ],
    );
  }
}
