import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/customer.dart';
import 'package:pharmo_app/screens/PA_SCREENS/pharma_home_page.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerCustomerPage extends StatefulWidget {
  const SellerCustomerPage({super.key});
  @override
  State<SellerCustomerPage> createState() => _SellerCustomerPageState();
}

class _SellerCustomerPageState extends State<SellerCustomerPage> {
  String email = '';
  String role = '';
  List<Customer> customerList = <Customer>[];
  List<Customer> filteredItems = <Customer>[];
  List<Customer> displayItems = <Customer>[];
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    getCustomers();
    setState(() {
      displayItems = customerList;
    });
    getUserInfo();
    super.initState();
  }

  getCustomers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      prefs.remove('customerId');
      final response = await http.get(
        Uri.parse('http://192.168.88.39:8000/api/v1/seller/customer_list/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> customers = res['customers'];
        customerList.clear();
        setState(() {
          for (int i = 0; i < customers.length; i++) {
            customerList.add(Customer.fromJson((customers[i])));
          }
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
    }
  }

  void searchCustomer(String searchQuery) {
    filteredItems.clear();
    setState(() {
      searchQuery = _searchController.text;
    });
    for (int i = 0; i < customerList.length; i++) {
      if (searchQuery.isNotEmpty &&
          customerList[i]
              .customer
              .name
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        filteredItems.add(
          Customer(
              id: customerList[i].id,
              customer: customerList[i].customer,
              isBad: customerList[i].isBad,
              badCnt: customerList[i].badCnt,
              debt: customerList[i].debt,
              debtLimit: customerList[i].debtLimit),
        );
        setState(() {
          displayItems = filteredItems;
        });
      }
      if (searchQuery.isEmpty) {
        setState(() {
          displayItems = customerList;
        });
      }
    }
  }

  void getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? useremail = prefs.getString('useremail');
    String? userRole = prefs.getString('userrole');
    setState(() {
      email = useremail.toString();
      role = userRole.toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      
      appBar: AppBar(
        centerTitle: true,
        title: CustomSearchBar(
          searchController: _searchController,
          title: 'Хайх',
          onChanged: searchCustomer,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.all(size.width * 0.05),
              curve: Curves.easeInOut,
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Бүртгэл',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    width: size.width * 0.1,
                    height: size.width * 0.1,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.secondary,
                      size: size.width * 0.1,
                    ),
                  ),
                  Text(
                    'Имейл хаяг: $email',
                    style: TextStyle(
                        color: Colors.white, fontSize: size.height * 0.015),
                  ),
                  Text(
                    'Хэрэглэгчийн төрөл: $role',
                    style: TextStyle(
                        color: Colors.white, fontSize: size.height * 0.015),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Захиалга'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Тохиргоо'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Гарах'),
              onTap: () {
                showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: ListView.builder(
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString(
                      'customerId', displayItems[index].customer.id.toString());
                  String? customerId = prefs.getString('customerId');
                  print(customerId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Home(),
                    ),
                  );
                },
                leading: const Icon(
                  Icons.person,
                  color: AppColors.secondary,
                ),
                title: Text(displayItems[index].customer.name.toString()),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            );
          },
        ),
      ),
    );
  }
}
