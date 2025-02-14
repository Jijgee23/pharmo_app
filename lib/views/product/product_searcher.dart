import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:provider/provider.dart';

class ProductSearcher extends StatelessWidget {
  const ProductSearcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (home.userRole == 'PA') suplierPicker(home, context),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TextFormField(
                    cursorHeight: Sizes.smallFontSize + 2,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: '${home.searchType} хайх',
                      hintStyle:
                          const TextStyle(fontSize: Sizes.mediumFontSize - 2, color: Colors.black),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) => _onfieldChanged(v, home),
                    onFieldSubmitted: (v) => _onFieldSubmitted(v, home),
                  )),
                  InkWell(
                      onTap: () => _changeSearchType(home, context),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: black,
                      )),
                  const SizedBox(width: 5),
                  viewMode(home)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _changeSearchType(HomeProvider home, BuildContext context) {
    showMenu(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      context: context,
      position: const RelativeRect.fromLTRB(150, 10, 10, 10),
      items: home.stype
          .map(
            (e) => PopupMenuItem(
              onTap: () {
                home.setQueryTypeName(e);
                int index = home.stype.indexOf(e);
                if (index == 0) {
                  home.setQueryType('name');
                } else if (index == 1) {
                  home.setQueryType('barcode');
                }
              },
              child: Text(
                e,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
              ),
            ),
          )
          .toList(),
    );
  }

  // Хайлт функц
  _onfieldChanged(String v, HomeProvider home) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (v.isEmpty || v == '') {
        home.setPageKey(1);
        home.fetchProducts();
      } else {
        home.filterProduct(v);
      }
    });
  }

  _onFieldSubmitted(String v, HomeProvider home) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (v.isEmpty || v == '') {
        home.setPageKey(1);
        home.fetchProducts();
      } else {
        home.filterProduct(v);
      }
    });
  }

  _onPickSupplier(BuildContext context, HomeProvider home) {
    Size size = MediaQuery.of(context).size;
    showMenu(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(size.width * 0.02, size.height * 0.15, size.width * 0.8, 0),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: home.supList
          .map(
            (e) => PopupMenuItem(
              onTap: () async => await onPickSupp(e, home, context),
              child: Text(
                e.name,
                style: TextStyle(
                  color: e.name == home.supName
                      ? AppColors.succesColor
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  onPickSupp(Supplier e, HomeProvider home, BuildContext context) async {
    await home.pickSupplier(int.parse(e.id), context);
    await home.changeSupName(e.name);
    home.setSupId(int.parse(e.id));
    home.clearItems();
    home.setPageKey(1);
    home.fetchProducts();
  }

  Widget suplierPicker(HomeProvider home, BuildContext context) {
    return IntrinsicWidth(
      child: InkWell(
        onTap: () => _onPickSupplier(context, home),
        child: Text(
          '${home.supName} :',
          style: const TextStyle(
            fontSize: Sizes.mediumFontSize - 2,
            color: AppColors.succesColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget viewMode(HomeProvider home) {
    return InkWell(
      onTap: () => home.switchView(),
      child: Icon(
        home.isList ? Icons.grid_view : Icons.list_sharp,
        color: black,
      ),
    );
  }
}
