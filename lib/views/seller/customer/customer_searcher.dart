import 'package:flutter/material.dart';
// import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/controller/providers/pharms_provider.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:provider/provider.dart';

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
  TextStyle style = const TextStyle(color: black, fontSize: 12);
  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, pp, child) => TextFormField(
        controller: controller,
        cursorColor: Colors.black,
        cursorHeight: 12,
        cursorWidth: .8,
        style: style,
        onChanged: (value) => _onSearch(value, pp),
        decoration: _formStyle(),
      ),
    );
  }

//  InkWell(
//             onTap: () => _setFilter(),
//             child: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
//           ),
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

  _formStyle() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
      ),
      hintText: '$selectedFilter хайх',
      hintStyle: style,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      filled: true,
      fillColor: card,
      suffixIcon: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _setFilter(),
        child: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
      ),
    );
  }
}
