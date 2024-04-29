// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/customer.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home.dart';
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
  Position? _currentLocation;
  String latitude = '';
  String longitude = '';
  String email = '';
  String role = '';
  List<Customer> customerList = <Customer>[];
  List<Customer> filteredItems = <Customer>[];
  List<Customer> displayItems = <Customer>[];
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late bool servicePermission = false;
  late LocationPermission permission;

  @override
  void initState() {
    getCustomers();
    setState(() {
      displayItems = customerList;
    });
    getUserInfo();
    getLocatiion();
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

  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();

    if (!servicePermission) {
      print("Service Disabled");
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  void getLocatiion() async {
    _currentLocation = await _getCurrentLocation();
    setState(() {
      latitude = _currentLocation!.latitude.toString().substring(0, 7);
      longitude = _currentLocation!.longitude.toString().substring(0, 7);
    });
    print('lat: $latitude, long: $longitude');
  }

  void searchByLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.post(
          Uri.parse(
              'http://192.168.88.39:8000/api/v1/seller/search_by_location/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'lat': latitude, 'lon': longitude}));
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        if (res == 'not found') {
          showFailedMessage(message: 'Харилцагч олдсонгүй', context: context);
        } else {
          List<dynamic> customers = res['customers'];
          customerList.clear();
          setState(() {
            for (int i = 0; i < customers.length; i++) {
              customerList.add(Customer.fromJson((customers[i])));
            }
            displayItems = customerList;
          });
        }
      } else {
        showFailedMessage(message: 'Харилцагч олдсонгүй.', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomSearchBar(
          searchController: _searchController,
          title: 'Хайх',
          onChanged: searchCustomer,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          searchByLocation();
        },
        child: const Icon(Icons.location_on),
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
