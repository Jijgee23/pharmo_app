import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
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
  TextStyle style =
      const TextStyle(color: black, fontSize: Sizes.mediumFontSize - 2);
  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, pp, child) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                cursorColor: Colors.black,
                cursorHeight: Sizes.bigFontSize,
                cursorWidth: .8,
                style: style,
                onChanged: (value) => _onSearch(value, pp),
                decoration: _formStyle(),
              ),
            ),
            InkWell(
              onTap: () => _setFilter(),
              child: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
            ),
          ],
        ),
      ),
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
                  fontWeight: FontWeight.bold, fontSize: 12, color: black),
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
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintText: '$selectedFilter хайх',
        hintStyle: style);
  }
}

selectedCustomer(HomeProvider home) {
  const textStyle = TextStyle(
      color: white,
      fontSize: 14.0,
      letterSpacing: 0.3,
      fontWeight: FontWeight.bold);
  return home.selectedCustomerId == 0
      ? const Text('Харилцагч сонгоно уу!', style: textStyle)
      : TextButton(
          onPressed: () => home.changeIndex(0),
          child: RichText(
            text: TextSpan(
              text: 'Сонгосон харилцагч: ',
              style: textStyle,
              children: [
                TextSpan(
                  text: home.selectedCustomerName,
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        );
}
