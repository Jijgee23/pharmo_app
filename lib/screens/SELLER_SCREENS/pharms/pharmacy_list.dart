// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/models/pharm.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharms/customer_details_paga.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharms/resgister_pharm.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
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
  int? selectedCustomer = -1;
  List<Pharm> filteredItems = [];
  List<Pharm> _displayItems = [];
  List<Pharm> isCustomer = [];
  Position? _currentLocation;
  late LocationPermission permission;
  late bool servicePermission = false;
  String latitude = '';
  String longitude = '';
  List<Customer> customerList = <Customer>[];
  List<Customer> displayItems = <Customer>[];
  bool isChecked = false;
  Color activeColor = AppColors.primary;
  @override
  void initState() {
    getPharmacyList();
    setState(() {
      _displayItems = _pharmList;
    });
    getSelectedIndex();
    getPosition();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  getSelectedIndex() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? sIndex = prefs.getInt('selectedIndex');
    setState(() {
      selectedCustomer = sIndex;
    });
  }

  getCustomers() {
    filteredItems.clear();
    for (int i = 0; i < _pharmList.length; i++) {
      if (_pharmList[i].isCustomer) {
        filteredItems.add(_pharmList[i]);
      }
      setState(() {
        _displayItems = filteredItems;
      });
    }
  }

  getPharmacies() {
    filteredItems.clear();
    for (int i = 0; i < _pharmList.length; i++) {
      if (!_pharmList[i].isCustomer) {
        filteredItems.add(_pharmList[i]);
      }
      setState(() {
        _displayItems = filteredItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _displayItems.sort((a, b) => a.name.compareTo(b.name));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: false,
          automaticallyImplyLeading: false,
          title: CustomSearchBar(
            searchController: _searchController,
            title: 'Хайх',
            onChanged: (value) {
              filteredItems.clear();
              searchPharmacy(value);
            },
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  if (isChecked == false) {
                    isChecked = true;
                    activeColor = AppColors.secondary;
                    getPharmacies();
                  } else {
                    isChecked = false;
                    activeColor = AppColors.primary;
                    getCustomers();
                  }
                });
              },
              icon: Icon(
                Icons.check_box,
                color: activeColor,
              ),
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
        _displayItems.isEmpty
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
                          goto(const RegisterPharmPage(), context);
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
            : SliverList.builder(
                itemCount: _displayItems.length,
                itemBuilder: ((context, index) {
                  return Card(
                    color: AppColors.primary,
                    child: InkWell(
                      onTap: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setInt('pharmId', _displayItems[index].id);
                        prefs.setString(
                            'selectedPharmName', _displayItems[index].name);
                        prefs.setInt('selectedIndex', index);
                        setState(() {
                          selectedCustomer = index;
                        });
                        showSuccessMessage(
                            message:
                                'Та: ${_displayItems[index].name}-г сонголоо',
                            context: context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    selectedCustomer == index
                                        ? const Icon(
                                            Icons.check,
                                            color: AppColors.succesColor,
                                          )
                                        : const Text(''),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      _displayItems[index].name,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (_displayItems[index].isCustomer) {
                                      goto(
                                          CustomerDetailsPage(
                                            customerId: _displayItems[index].id,
                                            custName: _displayItems[index].name,
                                          ),
                                          context);
                                    } else {
                                      showFailedMessage(
                                          message: 'Харилцагч биш',
                                          context: context);
                                    }
                                  },
                                  child: Text(
                                    _displayItems[index].isCustomer
                                        ? 'Дэлгэрэнгүй харах'
                                        : '',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _displayItems[index].isCustomer
                                  ? 'Харилцагч'
                                  : 'Эмийн сан',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
      ],
    );
  }

  getPharmacyList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['SERVER_URL']}seller/pharmacy_list/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> pharms = data['pharmacies'];
      _pharmList.clear();
      for (int i = 0; i < pharms.length; i++) {
        setState(() {
          _pharmList.add(Pharm(
              pharms[i]['id'], pharms[i]['name'], pharms[i]['isCustomer']));
        });
      }
    }
  }

  searchPharmacy(String searchQuery) {
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
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  Future getPosition() async {
    _currentLocation = await _getCurrentLocation();
    setState(() {
      latitude = _currentLocation!.latitude.toString();
      longitude = _currentLocation!.longitude.toString();
    });
  }

  searchByLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.post(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}seller/search_by_location/'),
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
