// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/models/pharm.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharms/resgister_pharm.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../models/customer.dart';

class PharmacyList extends StatefulWidget {
  const PharmacyList({super.key});

  @override
  State<PharmacyList> createState() => _PharmacyListState();
}

class _PharmacyListState extends State<PharmacyList> {
  final List<Pharm> _pharmList = <Pharm>[];
  final _searchController = TextEditingController();
  String pharmId = '';
  String searchQuery = '';
  int? selectedIndex = -1;
  List<Pharm> filteredItems = [];
  List<Pharm> _displayItems = [];
  String searchType = 'Нэрээр';
  Map company = {};
  List<dynamic> branches = [];
  List<dynamic> manager = [];
  Position? _currentLocation;
  late LocationPermission permission;
  late bool servicePermission = false;
  String latitude = '';
  String longitude = '';
  List<Customer> customerList = <Customer>[];
  List<Customer> displayItems = <Customer>[];
  @override
  void initState() {
    getPharmacyList();
    getCustomers();
    getLocatiion();
    _getCurrentLocation();
    setState(() {
      _displayItems = _pharmList;
    });
    getSelectedIndex();
    super.initState();
  }

  getSelectedIndex() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? sIndex = prefs.getInt('selectedIndex');
    setState(() {
      selectedIndex = sIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    _displayItems.sort((a, b) => a.name.compareTo(b.name));
    Set<int> uniqueIds = {};
    List<Pharm> uniqueItems = _displayItems.where((pharm) {
      if (!uniqueIds.contains(pharm.id)) {
        uniqueIds.add(pharm.id);
        return true;
      }
      return false;
    }).toList();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: false,
          automaticallyImplyLeading: false,
          title: CustomSearchBar(
            searchController: _searchController,
            title: '$searchType хайх',
            onChanged: (value) {
              if (searchQuery == 'Нэрээр') {
                searchPharmacy;
              } else {
                if (value.length == 7) {
                  setState(() {
                    value = _searchController.text;
                  });
                  fetchData(value);
                } else {
                  setState(() {
                    company.clear();
                    branches.clear();
                  });
                }
              }
            },
            suffix: IconButton(
              onPressed: () {
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(150, 20, 0, 0),
                  items: <PopupMenuEntry>[
                    PopupMenuItem(
                      value: 'item1',
                      onTap: () {
                        setState(() {
                          searchType = 'Нэрээр';
                        });
                      },
                      child: const Text('Нэрээр'),
                    ),
                    PopupMenuItem(
                      value: 'item2',
                      onTap: () {
                        setState(() {
                          searchType = 'РД-аар';
                        });
                      },
                      child: const Text('PД-аар'),
                    ),
                  ],
                ).then((value) {});
              },
              icon: const Icon(Icons.change_circle),
            ),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.only(right: 5),
              width: 40,
              child: FloatingActionButton(
                shape: const CircleBorder(
                  side: BorderSide(
                    width: 1,
                    color: AppColors.secondary,
                  ),
                ),
                backgroundColor: AppColors.primary,
                onPressed: () {
                  searchByLocation();
                },
                child: const Icon(Icons.location_on, color: Colors.blue),
              ),
            ),
          ],
        ),
        uniqueItems.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'Эмийн сан олдсонгүй.',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.secondary,
                        ),
                      ),
                      OutlinedButton.icon(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(AppColors.primary),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPharmPage()));
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Бүртгэх',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : searchType == 'Нэрээр'
                ? SliverList.builder(
                    itemCount: uniqueItems.length,
                    itemBuilder: ((context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            print(uniqueItems[index].id);
                            print(uniqueItems[index].name);
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setInt('pharmId', uniqueItems[index].id);
                            prefs.setString(
                                'selectedPharmName', uniqueItems[index].name);
                            prefs.setInt('selectedIndex', index);
                            setState(() {
                              selectedIndex = index;
                            });
                            showSuccessMessage(
                                message:
                                    'Та: ${uniqueItems[index].name}-г сонголоо',
                                context: context);
                            // Navigator.push(
                            //  context,
                            // MaterialPageRoute(
                            //    builder: (_) => CustomerBranchList(
                            //       customerId: uniqueItems[index].id,
                            //       custName: uniqueItems[index].name,
                            //     ),
                            //   ),
                            //  );
                          },
                          leading: Icon(
                            uniqueItems[index].isCustomer
                                ? Icons.medical_services
                                : Icons.store,
                            color: uniqueItems[index].isCustomer
                                ? Colors.green
                                : Colors.red,
                            size: 30,
                          ),
                          title: Text(uniqueItems[index].name),
                          trailing: selectedIndex == index
                              ? const Icon(Icons.check)
                              : null,
                        ),
                      );
                    }),
                  )
                : SliverFillRemaining(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: company.isEmpty
                            ? const Text('РД оруулна уу')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _searchController.text.length != 7
                                      ? const Text('РД оруулна уу')
                                      : Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Эмийн сангийн нэр: ${company['name']}'),
                                                Text(
                                                    'Регистрийн дугаар: ${company['rd']}'),
                                                Text(
                                                    'Имейл хаяг: ${company['email']}'),
                                                Text(
                                                    'Утасны дугаар: ${company['phone']}'),
                                                Text(
                                                    'Батлагаажсан эсэх: ${company['is_verified'] ? 'Тийм' : 'Үгүй'}'),
                                                Text(
                                                    'Бүртгэсэн хэрэглэгч: ${company['addedBy']}'),
                                              ],
                                            ),
                                          ),
                                        ),
                                  _searchController.text.length != 7
                                      ? const Text('')
                                      : Expanded(
                                          flex: 2,
                                          child: ListView.builder(
                                            itemCount: branches.length,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Нэр: ${branches[index]['branch']['name']}'),
                                                      Text(
                                                          'Хаяг: ${branches[index]['branch']['address']}'),
                                                      Text(
                                                          'Менежерийн имейл: ${branches[index]['manager']['email']}'),
                                                      Text(
                                                          'Утас: ${branches[index]['manager']['phone']}'),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                ],
                              ),
                      ),
                    ),
                  ),
      ],
    );
  }

  getPharmacyList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('http://192.168.88.39:8000/api/v1/seller/pharmacy_list/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> pharms = data['pharmacies'];
      for (int i = 0; i < pharms.length; i++) {
        setState(() {
          _pharmList.add(Pharm(pharms[i]['id'], pharms[i]['name'], false));
        });
      }
    }
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
        setState(() {
          for (int i = 0; i < customers.length; i++) {
            _pharmList.add(Pharm(customers[i]['customer']['id'],
                customers[i]['customer']['name'], true));
          }
        });
      }
    } catch (e) {
      showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
    }
  }

  fetchData(String cRd) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.post(
          Uri.parse('http://192.168.88.39:8000/api/v1/seller/search_pharmacy/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'cRd': cRd}));
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> br = res['branches'];
        branches.clear();
        setState(() {
          company = res['company'];
          branches = br;
        });
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }

  void searchPharmacy(String searchQuery) {
    filteredItems.clear();
    setState(() {
      searchQuery = _searchController.text;
    });
    for (int i = 0; i < _pharmList.length; i++) {
      if (searchQuery.isNotEmpty &&
          _pharmList[i]
              .name
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        filteredItems.add(Pharm(
            _pharmList[i].id, _pharmList[i].name, _pharmList[i].isCustomer));
        setState(() {
          _displayItems = filteredItems;
        });
      }
      if (searchQuery.isEmpty) {
        setState(() {
          _displayItems = _pharmList;
        });
      }
    }
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

  getLocatiion() async {
    _currentLocation = await _getCurrentLocation();
    setState(() {
      latitude = _currentLocation!.latitude.toString().substring(0, 7);
      longitude = _currentLocation!.longitude.toString().substring(0, 7);
    });
    print('lat: $latitude, long: $longitude');
  }

  searchByLocation() async {
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
}
