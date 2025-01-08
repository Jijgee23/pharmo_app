// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/category.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/filter/filtered_products.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() async {
        homeProvider.refresh(context, homeProvider, PromotionProvider());
      }),
      child: DefaultTabController(
        length: 3,
        child: Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            List<String?> filterList = [
              (homeProvider.categories.isNotEmpty) ? 'Ангилал' : '',
              (homeProvider.mnfrs.isNotEmpty) ? 'Нийлүүлэгч' : '',
              (homeProvider.vndrs.isNotEmpty) ? 'Үйлдвэрлэгч' : '',
            ];
            return Scaffold(
              appBar: CustomAppBar(
                leading: back(color: Theme.of(context).primaryColor),
                title: const Text(
                  'Ангилал',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              body: Column(   
                children: [
                  TabBar(
                      indicatorColor: Colors.blue,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerHeight: 0,
                      tabs: filterList
                          .map(
                            (fil) => Tab(
                              child: Text(
                                fil!,
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                          .toList()),
                  Expanded(
                    child: TabBarView(
                        children: [_categories(), _mnfrs(), _vndrs()]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _categories() {
    final cats = homeProvider.categories;
    return SingleChildScrollView(
      child: Column(
        children: [
          ...cats.map((cat) => CategoryItem(cat: cat)),
        ],
      ),
    );
  }

  _mnfrs() {
    final mnfrs = homeProvider.mnfrs;
    return SingleChildScrollView(
      child: Column(
        children: [
          ...mnfrs.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  child: Text(
                    homeProvider.mnfrs[mnfrs.indexOf(m)].name,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  onTap: () {
                    goto(
                      FilteredProducts(
                          type: 'mnfr',
                          title: homeProvider.mnfrs[mnfrs.indexOf(m)].name,
                          filterKey: homeProvider.mnfrs[mnfrs.indexOf(m)].id),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _vndrs() {
    final vndrs = homeProvider.vndrs;
    return SingleChildScrollView(
      child: Column(
        children: [
          ...vndrs.map(
            (v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  child: Text(
                    homeProvider.vndrs[vndrs.indexOf(v)].name,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  onTap: () {
                    goto(
                      FilteredProducts(
                          type: 'vndr',
                          title: homeProvider.vndrs[vndrs.indexOf(v)].name,
                          filterKey: homeProvider.vndrs[vndrs.indexOf(v)].id),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
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
                type: 'cat', title: widget.cat.name, filterKey: widget.cat.id),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.cat.name,
                  style: TextStyle(
                      color: isExpanded
                          ? AppColors.secondary
                          : Theme.of(context).colorScheme.onSecondary,
                      fontSize: 12),
                ),
                widget.cat.children!.isNotEmpty
                    ? Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down_outlined
                            : Icons.chevron_right_rounded,
                        color: isExpanded
                            ? AppColors.secondary
                            : Theme.of(context).colorScheme.onSecondary,
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
