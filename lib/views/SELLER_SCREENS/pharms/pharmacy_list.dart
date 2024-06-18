import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/pharms/customer_details_paga.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/pharms/register_pharm.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

class PharmacyList extends StatefulWidget {
  const PharmacyList({super.key});

  @override
  State<PharmacyList> createState() => _PharmacyListState();
}

class _PharmacyListState extends State<PharmacyList> {
  final _searchController = TextEditingController();
  List<PharmFullInfo> filteredItems = [];
  List<PharmFullInfo> _displayItems = [];
  bool onSearch = false;
  Color activeColor = AppColors.primary;
  Map pharmacyInfo = {};
  String selectedRadioValue = 'A';
  late HomeProvider homeProvider;
  late PharmProvider pharmProvider;
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    pharmProvider = Provider.of<PharmProvider>(context, listen: false);
    pharmProvider.getPharmacyList();
    homeProvider.getPosition();
    _displayItems = pharmProvider.fullList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _displayItems.sort((a, b) => a.name.compareTo(b.name));
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (_, homeProvider, pp, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              onSearch
                  ? const SliverAppBar(
                      toolbarHeight: 0,
                    )
                  : SliverAppBar(
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
                              homeProvider.searchByLocation(context);
                            },
                            child: const Icon(Icons.location_on,
                                color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
              SliverAppBar( 
                pinned: false,
                automaticallyImplyLeading: false,
                title: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    return true;
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      children: [
                        custRadio('A', 'Бүгд', pp.fullList),
                        Row(
                          children: [
                            Radio(
                              value: 'C',
                              groupValue: selectedRadioValue,
                              onChanged: (value) {
                                filteredItems.clear();
                                setState(() {
                                  onSearch = true;
                                  for (int i = 0;
                                      i < pharmProvider.fullList.length;
                                      i++) {
                                    if (pharmProvider.fullList[i].isCustomer) {
                                      filteredItems
                                          .add(pharmProvider.fullList[i]);
                                      selectedRadioValue = value!;
                                    }
                                  }
                                  _displayItems = filteredItems;
                                });
                              },
                            ),
                            radioText('Харилцагч'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'P',
                              groupValue: selectedRadioValue,
                              onChanged: (value) {
                                filteredItems.clear();
                                setState(() {
                                  onSearch = true;
                                  for (int i = 0;
                                      i < pharmProvider.fullList.length;
                                      i++) {
                                    if (!pharmProvider.fullList[i].isCustomer) {
                                      filteredItems
                                          .add(pharmProvider.fullList[i]);
                                      selectedRadioValue = value!;
                                    }
                                  }
                                  _displayItems = filteredItems;
                                });
                              },
                            ),
                            radioText('Эмийн сан'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'G',
                              groupValue: selectedRadioValue,
                              onChanged: (value) {
                                filteredItems.clear();
                                setState(() {
                                  onSearch = true;
                                  for (int i = 0;
                                      i < pharmProvider.fullList.length;
                                      i++) {
                                    if (pharmProvider.fullList[i].isBad) {
                                    } else {
                                      if (!pharmProvider.fullList[i].isBad &&
                                          pharmProvider
                                              .fullList[i].isCustomer) {
                                        if (pharmProvider.fullList[i].debt !=
                                                0 &&
                                            pharmProvider
                                                    .fullList[i].debtLimit !=
                                                0 &&
                                            pharmProvider.fullList[i].debt >=
                                                pharmProvider
                                                    .fullList[i].debtLimit) {
                                        } else {
                                          filteredItems
                                              .add(pharmProvider.fullList[i]);
                                          selectedRadioValue = value!;
                                        }
                                      }
                                    }
                                  }
                                  _displayItems = filteredItems;
                                });
                              },
                            ),
                            radioText('Найдвартай'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'B',
                              groupValue: selectedRadioValue,
                              onChanged: (value) {
                                filteredItems.clear();
                                setState(() {
                                  onSearch = true;
                                  for (int i = 0;
                                      i < pharmProvider.fullList.length;
                                      i++) {
                                    if (pharmProvider.fullList[i].isBad &&
                                        pharmProvider.fullList[i].isCustomer) {
                                      filteredItems
                                          .add(pharmProvider.fullList[i]);
                                      selectedRadioValue = value!;
                                    }
                                  }
                                  _displayItems = filteredItems;
                                });
                              },
                            ),
                            radioText('Найдваргүй'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'L',
                              groupValue: selectedRadioValue,
                              onChanged: (value) {
                                filteredItems.clear();
                                setState(() {
                                  onSearch = true;
                                  for (int i = 0;
                                      i < pharmProvider.fullList.length;
                                      i++) {
                                    if (!pharmProvider.fullList[i].isBad &&
                                        pharmProvider.fullList[i].isCustomer) {
                                      if (pharmProvider.fullList[i].debt != 0 &&
                                          pharmProvider.fullList[i].debtLimit !=
                                              0 &&
                                          pharmProvider.fullList[i].debt >=
                                              pharmProvider
                                                  .fullList[i].debtLimit) {
                                        filteredItems
                                            .add(pharmProvider.fullList[i]);
                                        selectedRadioValue = value!;
                                      }
                                    }
                                  }
                                  _displayItems = filteredItems;
                                });
                              },
                            ),
                            radioText('Зээл хэтэрсэн'),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.primary),
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
                              if (_displayItems[index].isBad == true) {
                                showFailedMessage(
                                    context: context,
                                    message: 'Найдваргүй харилцагч байна!');
                              } else {
                                if (_displayItems[index].debt != 0 &&
                                    _displayItems[index].debtLimit != 0 &&
                                    _displayItems[index].debt >=
                                        _displayItems[index].debtLimit) {
                                  showFailedMessage(
                                      context: context,
                                      message:
                                          'Зээлийн хэмжээ хэтэрсэн байна!');
                                } else {
                                  setState(() {
                                    homeProvider.selectedCustomerId =
                                        _displayItems[index].id;
                                    homeProvider.selectedCustomerName =
                                        _displayItems[index].name;
                                    homeProvider.getSelectedUser(
                                        _displayItems[index].id,
                                        _displayItems[index].name);
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          homeProvider.selectedCustomerId ==
                                                  _displayItems[index].id
                                              ? const Icon(
                                                  Icons.check,
                                                  color: AppColors.succesColor,
                                                )
                                              : const Text(''),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          RichText(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            text: TextSpan(
                                              text: _displayItems[index].name,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: _displayItems[index]
                                                          .isBad
                                                      ? Colors.red
                                                      : _displayItems[index]
                                                                      .debt !=
                                                                  0 &&
                                                              _displayItems[
                                                                          index]
                                                                      .debtLimit !=
                                                                  0 &&
                                                              _displayItems[
                                                                          index]
                                                                      .debt >=
                                                                  _displayItems[
                                                                          index]
                                                                      .debtLimit
                                                          ? AppColors
                                                              .failedColor
                                                          : AppColors.primary,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (_displayItems[index].isCustomer) {
                                            goto(
                                                CustomerDetailsPage(
                                                  customerId:
                                                      _displayItems[index].id,
                                                  custName:
                                                      _displayItems[index].name,
                                                ),
                                                context);
                                          } else {}
                                        },
                                        child: Text(
                                          _displayItems[index].isCustomer
                                              ? 'Дэлгэрэнгүй'
                                              : 'Найдваргүй: ${_displayItems[index].badCnt.toString() == 'null' ? 0 : _displayItems[index].badCnt.toString()} ',
                                          style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _displayItems[index].isCustomer
                                        ? 'Харилцагч'
                                        : 'Эмийн сан',
                                    style: const TextStyle(
                                        color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
            ],
          ),
        );
      },
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

  Widget custRadio(String value, String title, List<PharmFullInfo> viewList) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: selectedRadioValue,
          onChanged: (value) {
            setState(() {
              onSearch = false;
              selectedRadioValue = value!;
              _displayItems = viewList;
            });
          },
        ),
        radioText(title),
      ],
    );
  }

  searchPharmacy(String searchQuery) {
    filteredItems.clear();
    setState(() {
      searchQuery = _searchController.text;
    });
    for (int i = 0; i < pharmProvider.fullList.length; i++) {
      if (searchQuery.isNotEmpty &&
          pharmProvider.fullList[i].name
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        filteredItems.add(
          PharmFullInfo(
            pharmProvider.fullList[i].id,
            pharmProvider.fullList[i].name,
            pharmProvider.fullList[i].isCustomer,
            pharmProvider.fullList[i].badCnt,
            pharmProvider.fullList[i].isBad,
            pharmProvider.fullList[i].debt,
            pharmProvider.fullList[i].debtLimit,
          ),
        );

        setState(() {
          _displayItems = filteredItems;
        });
      }
      if (searchQuery.isEmpty) {
        setState(() {
          _displayItems = pharmProvider.fullList;
        });
      }
    }
  }
}


