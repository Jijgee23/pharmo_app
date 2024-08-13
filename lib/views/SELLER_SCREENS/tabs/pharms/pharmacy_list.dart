import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/tabs/pharms/customer_details_paga.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/tabs/pharms/register_pharm.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
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

  final filter = {};

  List<String> filters = [
    'Бүгд',
    'Харилцагч',
    'Эмийн сан',
    'Найдвартай',
    'Найдваргүй',
    'Зээл хэтэрсэн'
  ];
  List<String> radioValues = ['A', 'C', 'P', 'G', 'B', 'D'];

  @override
  Widget build(BuildContext context) {
    _displayItems.sort((a, b) => a.name.compareTo(b.name));
    List<dynamic> lists = [
      pharmProvider.fullList,
      pharmProvider.customeList,
      pharmProvider.pharmList,
      pharmProvider.goodlist,
      pharmProvider.badlist,
      pharmProvider.limitedlist,
    ];
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
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            highlightElevation: 0,
                            onPressed: () {
                              homeProvider.searchByLocation(context);
                            },
                            child: Image.asset(
                              'assets/icons/locaiton.png',
                            ),
                          ),
                        ),
                      ],
                    ),
              SliverAppBar(
                pinned: false,
                toolbarHeight: 20,
                automaticallyImplyLeading: false,
                title: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    return true;
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters
                          .map((e) => custRadio(
                              radioValues.elementAt(filters.indexOf(e)),
                              e,
                              lists[filters.indexOf(e)]))
                          .toList(),
                    ),
                  ),
                ),
              ),
              _displayItems.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Эмийн сан олдсонгүй.',
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 20),
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
                        final item = _displayItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InkWell(
                            onTap: () async {
                              if (item.isBad == true) {
                                showFailedMessage(
                                    context: context,
                                    message: 'Найдваргүй харилцагч байна!');
                              } else {
                                if (item.debt != 0 &&
                                    item.debtLimit != 0 &&
                                    item.debt >= item.debtLimit) {
                                  showFailedMessage(
                                      context: context,
                                      message:
                                          'Зээлийн хэмжээ хэтэрсэн байна!');
                                } else {
                                  setState(() {
                                    homeProvider.selectedCustomerId = item.id;
                                    homeProvider.selectedCustomerName =
                                        item.name;
                                    homeProvider.getSelectedUser(
                                        item.id, item.name);
                                  });
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primary,
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      homeProvider.selectedCustomerId == item.id
                                          ? const Icon(
                                              Icons.check,
                                              color: AppColors.succesColor,
                                            )
                                          : const Text(''),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                          text: item.name,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: item.isBad
                                                  ? Colors.red
                                                  : item.debt != 0 &&
                                                          item.debtLimit != 0 &&
                                                          item.debt >=
                                                              item.debtLimit
                                                      ? AppColors.failedColor
                                                      : AppColors.cleanBlack),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    padding: const EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    onPressed: () {
                                      if (item.isCustomer) {
                                        goto(
                                            CustomerDetailsPage(
                                              customerId: item.id,
                                              custName: item.name,
                                            ),
                                            context);
                                      } else {
                                        showFailedMessage(
                                            context: context,
                                            message:
                                                'Эмийн сангийн мэдээллийг харах боломжгүй!');
                                      }
                                    },
                                    icon: const Icon(Icons.chevron_right),
                                    style: const ButtonStyle(
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )
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
      style: const TextStyle(fontSize: 12),
    );
  }

  Widget custRadio(String value, String title, List<PharmFullInfo> viewList) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Radio(
            fillColor: MaterialStateProperty.all(AppColors.primary),
            value: value,
            groupValue: selectedRadioValue,
            onChanged: (value) {
              setState(() {
                if (value == 'A') {
                  onSearch = false;
                } else {
                  onSearch = true;
                }
                selectedRadioValue = value!;
                _displayItems = viewList;
              });
            },
          ),
        ),
        radioText(
          title,
        ),
      ],
    );
  }

  searchPharmacy(String searchQuery) {
    filteredItems.clear();
    setState(() {
      searchQuery = _searchController.text;
    });
    final mylist = pharmProvider.fullList;
    for (int i = 0; i < mylist.length; i++) {
      if (searchQuery.isNotEmpty &&
          mylist[i].name.toLowerCase().contains(searchQuery.toLowerCase())) {
        filteredItems.add(
          PharmFullInfo(
            mylist[i].id,
            mylist[i].name,
            mylist[i].isCustomer,
            mylist[i].badCnt,
            mylist[i].isBad,
            mylist[i].debt,
            mylist[i].debtLimit,
          ),
        );
        setState(() {
          _displayItems = filteredItems;
        });
      }
      if (searchQuery.isEmpty) {
        setState(() {
          _displayItems = mylist;
        });
      }
    }
  }
}
