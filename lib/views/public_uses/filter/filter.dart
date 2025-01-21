// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/category.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/filter/filtered_products.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
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
            List<dynamic> views = [_categories(), _mnfrs(), _vndrs()];

            return Scaffold(
              appBar: const SideAppBar(text: 'Ангилал', hasBasket: true),
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
                    child: TabBarView(children: [
                      ...views.map(
                        (v) => SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.smallFontSize),
                          child: Column(
                            children: v,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _categories() {
    final cats = homeProvider.categories;
    return [
      ...cats.map(
        (cat) => CategoryItem(cat: cat),
      )
    ];
  }

  _mnfrs() {
    final mnfrs = homeProvider.mnfrs;
    return [
      ...mnfrs.map(
        (m) => item(
            text: homeProvider.mnfrs[mnfrs.indexOf(m)].name,
            type: 'mnfr',
            title: homeProvider.mnfrs[mnfrs.indexOf(m)].name,
            filterKey: homeProvider.mnfrs[mnfrs.indexOf(m)].id),
      ),
    ];
  }

  _vndrs() {
    final vndrs = homeProvider.vndrs;
    return [
      ...vndrs.map(
        (v) => item(
          text: homeProvider.vndrs[vndrs.indexOf(v)].name,
          type: 'vndr',
          title: homeProvider.vndrs[vndrs.indexOf(v)].name,
          filterKey: homeProvider.vndrs[vndrs.indexOf(v)].id,
        ),
      ),
    ];
  }

  Widget item(
      {required String text,
      required String type,
      required String title,
      required int filterKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          child: Text(text,
              style: const TextStyle(color: Colors.black, fontSize: 12)),
          onTap: () => goto(
              FilteredProducts(type: type, title: title, filterKey: filterKey)),
        ),
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
      onTap: () => onTap(),
      child: AnimatedContainer(
        duration: duration,
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
                        : theme.colorScheme.onSecondary,
                    fontSize: Sizes.mediumFontSize,
                  ),
                ),
                const SizedBox(width: Sizes.mediumFontSize),
                widget.cat.children!.isNotEmpty
                    ? Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down_outlined
                            : Icons.chevron_right_rounded,
                        color: isExpanded
                            ? AppColors.secondary
                            : theme.colorScheme.onSecondary,
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

  onTap() {
    if (widget.cat.children!.isNotEmpty) {
      setState(() => isExpanded = !isExpanded);
    } else {
      goto(FilteredProducts(
          type: 'cat', title: widget.cat.name, filterKey: widget.cat.id));
    }
  }
}
