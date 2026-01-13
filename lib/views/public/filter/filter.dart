// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/controller/models/category.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/constants.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/views/cart/cart_icon.dart';
import 'package:pharmo_app/views/public/filter/filtered_products.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  int selectedIdx = 0;
  int selectId = -1;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().getFilters();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Consumer<HomeProvider>(
        builder: (context, home, child) {
          List<String?> filterList = [
            (home.categories.isNotEmpty) ? 'Ангилал' : '',
            (home.mnfrs.isNotEmpty) ? 'Нийлүүлэгч' : '',
            (home.vndrs.isNotEmpty) ? 'Үйлдвэрлэгч' : '',
          ];
          List<dynamic> views = [_categories(home), _mnfrs(home), _vndrs(home)];
          return Scaffold(
            appBar: AppBar(
              leading: ChevronBack(),
              title: Text(
                'Ангилал',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [CartIcon()],
              bottom: TabBar(
                  indicatorColor: primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  tabs: filterList
                      .map(
                        (fil) => Tab(
                          child: Text(
                            fil!,
                            style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList()),
            ),
            body: TabBarView(
              children: [
                ...views.map(
                  (v) => RefreshIndicator(
                    onRefresh: () => Future.sync(
                      () async {
                        home.refresh(context);
                      },
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.smallFontSize,
                      ),
                      child: Column(children: v),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _categories(HomeProvider home) {
    final cats = home.categories;
    return [
      ...cats.map(
        (cat) => CategoryItem(cat: cat),
      )
    ];
  }

  _mnfrs(HomeProvider home) {
    final mnfrs = home.mnfrs;
    return [
      ...mnfrs.map(
        (m) => item(
            text: home.mnfrs[mnfrs.indexOf(m)].name,
            type: 'mnfr',
            title: home.mnfrs[mnfrs.indexOf(m)].name,
            filterKey: home.mnfrs[mnfrs.indexOf(m)].id),
      ),
    ];
  }

  _vndrs(HomeProvider home) {
    final vndrs = home.vndrs;
    return [
      ...vndrs.map(
        (v) => item(
          text: home.vndrs[vndrs.indexOf(v)].name,
          type: 'vndr',
          title: home.vndrs[vndrs.indexOf(v)].name,
          filterKey: home.vndrs[vndrs.indexOf(v)].id,
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
          child: categoryText(text, black),
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
                categoryText(
                  widget.cat.name,
                  isExpanded
                      ? AppColors.secondary
                      : theme.colorScheme.onSecondary,
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

categoryText(String txt, Color color) {
  return Text(
    txt,
    style: TextStyle(
      color: color,
      fontSize: Sizes.mediumFontSize,
      fontWeight: FontWeight.bold,
    ),
  );
}
