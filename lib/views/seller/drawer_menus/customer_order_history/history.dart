
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/models/pharm.dart';
import 'package:pharmo_app/views/seller/drawer_menus/customer_order_history/favorites.dart';
import 'package:pharmo_app/views/seller/drawer_menus/customer_order_history/order_history_list.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

class SellerCustomerOrderHisrtory extends StatefulWidget {
  const SellerCustomerOrderHisrtory({super.key});

  @override
  State<SellerCustomerOrderHisrtory> createState() =>
      _SellerCustomerOrderHisrtoryState();
}

class _SellerCustomerOrderHisrtoryState
    extends State<SellerCustomerOrderHisrtory> {
  List<Pharm> pharmList = <Pharm>[];
  List<Pharm> displayItems = <Pharm>[];
  List<Pharm> filteredItems = <Pharm>[];
  TextEditingController searchController = TextEditingController();
  late PharmProvider pharmProvider;
  searchPharmacy(String searchQuery) {
    filteredItems.clear();
    setState(() {
      searchQuery = searchController.text;
    });
    for (int i = 0; i < pharmProvider.customeList.length; i++) {
      if (searchQuery.isNotEmpty &&
          pharmProvider.customeList[i].name
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        filteredItems.add(Pharm(
            pharmProvider.customeList[i].id,
            pharmProvider.customeList[i].name,
            pharmProvider.customeList[i].isCustomer,
            pharmList[i].badCnt));
        setState(() {
          displayItems = filteredItems;
        });
      }
      if (searchQuery.isEmpty) {
        setState(() {
          displayItems = pharmList;
        });
      }
    }
  }

  @override
  void initState() {
    setState(() {
      displayItems = pharmList;
    });
    super.initState();
    pharmProvider = Provider.of<PharmProvider>(context, listen: false);
    pharmProvider.getPharmacyList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (_, provider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
              leading: const ChevronBack(),
              centerTitle: true,
              title: const Text('Харилцагчид', style: TextStyle(fontSize: 16))),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomSearchBar(
                  searchController: searchController,
                  title: 'Хайх',
                  onChanged: (value) {
                    searchPharmacy(value);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.customeList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        provider.getOrderList(provider.customeList[index].id);
                        goto(
                            OrderhistoryListPage(
                                customerId: provider.customeList[index].id),
                            context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${index + 1}.${provider.customeList[index].name}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: provider.customeList[index].isBad
                                      ? Colors.red
                                      : provider.customeList[index].debt != 0 &&
                                              provider.customeList[index]
                                                      .debtLimit !=
                                                  0 &&
                                              provider.customeList[index]
                                                      .debt >=
                                                  provider.customeList[index]
                                                      .debtLimit
                                          ? AppColors.failedColor
                                          : AppColors.primary,),
                            ),
                            GestureDetector(
                              onTap: () => goto(
                                  FavoriteList(
                                      customerId:
                                          provider.customeList[index].id),
                                  context),
                              child: const Icon(
                                Icons.favorite,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
