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
  Map pharmacyInfo = {};
  String selectedRadioValue = 'A';
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

  @override
  Widget build(BuildContext context) {
    _displayItems.sort((a, b) => a.name.compareTo(b.name));
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          title: CustomSearchBar(
            searchController: _searchController,
            title: 'Хайх',
            onChanged: (value) {
              filteredItems.clear();
              searchPharmacy(value);
            },
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
        SliverAppBar(
          pinned: false,
          automaticallyImplyLeading: false,
          toolbarHeight: 30,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    radioText('Бүгд'),
                    Radio(
                      value: 'A',
                      groupValue: selectedRadioValue,
                      onChanged: (value) {
                        setState(() {
                          selectedRadioValue = value!;
                          getPharmacyList();
                          _displayItems = _pharmList;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    radioText('Харилцагч'),
                    Radio(
                      value: 'C',
                      groupValue: selectedRadioValue,
                      onChanged: (value) {
                        setState(() {
                          selectedRadioValue = value!;
                        });
                        getCustomers();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    radioText('Эмийн сан'),
                    Radio(
                      value: 'P',
                      groupValue: selectedRadioValue,
                      onChanged: (value) {
                        setState(() {
                          selectedRadioValue = value!;
                        });
                        getPharmacies();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                    child: InkWell(
                      onTap: () async {
                        await getPharmacyinfo(_displayItems[index].id);
                        if (pharmacyInfo['isBad'] == true) {
                          showFailedMessage(
                              context: context,
                              message: 'Найдваргүй харилцагч байна!');
                        } else {
                          if (pharmacyInfo['debt'] != 0 &&
                              pharmacyInfo['debtLimit'] != 0 &&
                              pharmacyInfo['debt'] >=
                                  pharmacyInfo['debtLimit']) {
                            showFailedMessage(
                                context: context,
                                message: 'Зээлийн хэмжээ хэтэрсэн байна!');
                          } else {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setInt('pharmId', _displayItems[index].id);
                            prefs.setString(
                                'selectedPharmName', _displayItems[index].name);
                            prefs.setInt('selectedIndex', index);
                            setState(() {
                              selectedCustomer = _displayItems[index].id;
                            });
                          }
                        }
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
                                    selectedCustomer == _displayItems[index].id
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
                                      
                                    }
                                  },
                                  child: Text(
                                    _displayItems[index].isCustomer
                                        ? 'Дэлгэрэнгүй харах'
                                        : 'Найдваргүй индекс: ${_displayItems[index].badCnt.toString()} ',
                                    style: const TextStyle(
                                        color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _displayItems[index].isCustomer
                                  ? 'Харилцагч'
                                  : 'Эмийн сан',
                              style: const TextStyle(color: AppColors.primary),
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

  Widget mText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget radioText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14),
    );
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
            pharms[i]['id'],
            pharms[i]['name'],
            pharms[i]['isCustomer'],
            pharms[i]['badCnt'],
          ));
        });
      }
    }
  }

  getPharmacyinfo(int pharmId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['SERVER_URL']}seller/get_debt_info/?userId=$pharmId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        pharmacyInfo.clear();
        setState(() {
          pharmacyInfo = res;
        });
      }
    } catch (e) {
      showFailedMessage(message: 'Мэдээлэл олдсонгүй', context: context);
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
            _pharmList[i].id, _pharmList[i].name,
            _pharmList[i].isCustomer, _pharmList[i].badCnt));
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

    if (!servicePermission) {}
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
          Uri.parse('${dotenv.env['SERVER_URL']}seller/search_by_location/'),
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
