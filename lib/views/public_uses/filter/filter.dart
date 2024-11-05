// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/category.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/filter/filtered_products.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  int selectedIdx = 0;
  int selectId = -1;
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

  List<String> filterList = [
    !(HomeProvider().categories.isNotEmpty &&
            HomeProvider().categories.length > 1)
        ? 'Ангилал'
        : '',
    (HomeProvider().mnfrs.isNotEmpty) ? 'Нийлүүлэгчид' : '',
    (HomeProvider().vndrs.isNotEmpty) ? 'Үйлдвэрлэгчид' : '',
  ];

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = [_categories(), _mnfrs(), _vndrs()];
    return RefreshIndicator(
      onRefresh: () => Future.sync(() async {
        homeProvider.refresh(context, homeProvider, PromotionProvider());
      }),
      child: Consumer<HomeProvider>(
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
                        onTap: () =>
                            setState(() => selectedIdx = filterList.indexOf(e)),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            e,
                            style: TextStyle(
                                fontSize: 14,
                                color: filterList.indexOf(e) == selectedIdx
                                    ? AppColors.secondary
                                    : AppColors.primary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                list[selectedIdx]
              ],
            ),
          );
        },
      ),
    );
  }

  _categories() {
    final cats = homeProvider.categories;
    return SliverList.builder(
      itemBuilder: (context, index) {
        final cat = homeProvider.categories[index];
        return SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CategoryItem(cat: cat),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: Colors.grey.shade300,
                ),
              )
            ],
          ),
        );
      },
      itemCount: cats.length,
    );
  }

  _mnfrs() {
    return SliverList.builder(
      itemBuilder: (_, idx) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 30,
            top: 10,
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
                    );
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
                  );
              },
            ),
          ),
        );
      },
      itemCount: homeProvider.vndrs.length,
    );
  }
}

class CategoryItem extends StatefulWidget {
  final Category cat;

  const CategoryItem({super.key, required this.cat});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.cat.children!.isNotEmpty) {
          setState(() => isExpanded = !isExpanded);
        } else {
          goto(
              FilteredProducts(
                  type: 'cat',
                  title: widget.cat.name,
                  filterKey: widget.cat.id),
            );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 5, left: 20, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.cat.name,
                  style: TextStyle(
                    color: isExpanded ? AppColors.secondary : Colors.black,
                  ),
                ),
                widget.cat.children!.isNotEmpty
                    ? Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down_outlined
                            : Icons.chevron_right_rounded,
                        color: isExpanded ? AppColors.secondary : Colors.black,
                        size: 20,
                      )
                    : const SizedBox()
              ],
            ),
            (widget.cat.children!.isNotEmpty && isExpanded == true)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.cat.children!.map((e) {
                      return CategoryItem(cat: e);
                    }).toList(),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
