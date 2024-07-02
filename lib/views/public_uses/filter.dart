// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/filtered_products.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> filterList = ['Англилал', 'Үйлдвэрлэгчид', 'Нийлүүлэгчид'];
  int selectedFilter = 0;
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.getFilters();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.cleanWhite,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                toolbarHeight: 14,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: filterList.map((e) {
                    return TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = filterList.indexOf(e);
                        });
                      },
                      child: Text(
                        e,
                        style: TextStyle(
                            color: filterList.indexOf(e) == selectedFilter
                                ? AppColors.succesColor
                                : AppColors.primary),
                      ),
                    );
                  }).toList(),
                ),
              ),
              selectedFilter == 0
                  ? _categories()
                  : selectedFilter == 1
                      ? _mnfrs()
                      : _vndrs(),
            ],
          ),
        );
      },
    );
  }

  _categories() {
    return SliverList.builder(
      itemBuilder: (context, index) {
        return Padding(
            padding: const EdgeInsets.only(left: 30, top: 5),
            child: GestureDetector(
              child: Text(
                homeProvider.categories[index].name,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                goto(
                    FilteredProducts(
                        type: 'category',
                        title: homeProvider.categories[index].name,
                        filterKey: homeProvider.categories[index].id),
                    context);
              },
            ));
      },
      itemCount: homeProvider.categories.length,
    );
  }

  _mnfrs() {
    return SliverList.builder(
      itemBuilder: (_, idx) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 30,
            top: 5,
          ),
          child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                child: Text(
                  homeProvider.mnfrs[idx].name,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  goto(
                      FilteredProducts(
                          type: 'mnfr',
                          title: homeProvider.mnfrs[idx].name,
                          filterKey: homeProvider.mnfrs[idx].id),
                      context);
                },
              )),
        );
      },
      itemCount: homeProvider.mnfrs.length,
    );
  }

  _vndrs() {
    return SliverList.builder(
      itemBuilder: (_, idx) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 30,
            top: 5,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              child: Text(
                homeProvider.vndrs[idx].name,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                goto(
                    FilteredProducts(
                        type: 'vndr',
                        title: homeProvider.vndrs[idx].name,
                        filterKey: homeProvider.vndrs[idx].id),
                    context);
              },
            ),
          ),
        );
      },
      itemCount: homeProvider.vndrs.length,
    );
  }

  addBasket(int? id, int? itemnameId) async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      Map<String, dynamic> res = await basketProvider.addBasket(
          product_id: id, itemname_id: itemnameId, qty: 1);
      if (res['errorType'] == 1) {
        basketProvider.getBasket();
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа', context: context);
    }
  }
}
