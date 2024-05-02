// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/customer.dart';
import 'package:pharmo_app/models/favorite.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/order/favorites.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/order/orderHistoryList.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
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
  List<Favorite> favoriteList = <Favorite>[];
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  

  @override
  void initState() {
    setState(() {
      displayItems = customerList;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomSearchBar(
          searchController: _searchController,
          title: 'Хайх',
          onChanged: (value) {
            searchCustomer(value);
          },
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
                      builder: (_) => const SellerHomePage(),
                    ),
                  );
                },
                leading: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderhistoryListPage(
                          customerId: displayItems[index].customer.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.work_history_outlined,
                    color: Colors.blue,
                  ),
                ),
                title: Text(displayItems[index].customer.name.toString()),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FavoriteList(
                          customerId: displayItems[index].customer.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  

  searchCustomer(String searchQuery) {
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


  
}
