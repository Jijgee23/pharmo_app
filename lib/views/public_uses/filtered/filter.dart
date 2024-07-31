// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/filtered/filtered_products.dart';
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
  bool isExpanded = false;

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
                    return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          selectedFilter = filterList.indexOf(e);
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            e,
                            style: TextStyle(
                                fontSize: 14,
                                color: filterList.indexOf(e) == selectedFilter
                                    ? AppColors.succesColor
                                    : AppColors.primary),
                          ),
                        ],
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
        final cat = homeProvider.categories[index];
        return Padding(
          padding: const EdgeInsets.only(left: 30, top: 0),
          child: InkWell(
            splashColor: Colors.transparent,
            child: Row(
              children: [
                Text(
                  homeProvider.categories[index].name,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                cat.children!.isNotEmpty
                    ? const Icon(Icons.chevron_right_rounded)
                    : const SizedBox()
              ],
            ),
            onTap: () {
              if (cat.children!.isNotEmpty) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: cat.children!
                                  .map((e) => InkWell(
                                        onTap: () {
                                          print(e['children']);
                                          // Navigator.pop(context);
                                          // goto(
                                          //     FilteredProducts(
                                          //         type: 'category',
                                          //         title: e['name'],
                                          //         filterKey: e['id']),
                                          //     context);
                                        },
                                        child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                            ),
                                            child:
                                                Center(child: Text(e['name']))),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    });
              } else {
                goto(
                    FilteredProducts(
                        type: 'category',
                        title: homeProvider.categories[index].name,
                        filterKey: homeProvider.categories[index].id),
                    context);
              }
            },
          ),
        );
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
                print(homeProvider.vndrs[idx].id);
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
}
