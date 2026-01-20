import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/controller/models/supplier.dart';
import 'package:pharmo_app/application/services/local_base.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';
import 'package:provider/provider.dart';

class ProductSearcher extends StatelessWidget {
  const ProductSearcher({super.key});

  @override
  Widget build(BuildContext context) {
    final security = LocalBase.security;

    if (security == null) {
      return Scaffold();
    }

    return Consumer<HomeProvider>(
      builder: (context, home, child) => Row(
        // spacing: ,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (security.role == 'PA') suplierPicker(home, context),
          if (security.role == 'PA') const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              cursorHeight: Sizes.smallFontSize + 2,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: '${home.searchType} хайх',
                hintStyle: const TextStyle(
                  fontSize: Sizes.mediumFontSize - 2,
                  color: Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                filled: true,
                fillColor: card,
                suffixIcon: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => _changeSearchType(home, context),
                  child: Icon(Icons.arrow_drop_down),
                ),
                // border: InputBorder.none,
                // focusedBorder: InputBorder.none,
                // enabledBorder: InputBorder.none,
              ),
              onChanged: (v) => _onfieldChanged(v, home),
              onFieldSubmitted: (v) => _onFieldSubmitted(v, home),
            ),
          ),
          SizedBox(width: 10),
          viewMode(home)
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 12),
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
    List<Stock> all = [];
    for (Supplier sup in home.supliers) {
      all.addAll(sup.stocks);
    }
    showMenu(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(
          size.width * 0.02, size.height * 0.15, size.width * 0.8, 0),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: all.map((e) => stockBuilder(e, home, context)).toList(),
    );
  }

  PopupMenuItem stockBuilder(Stock e, HomeProvider home, BuildContext context) {
    final supplier = home.supliers.firstWhere((sup) => sup.stocks.contains(e));
    bool hasImage = supplier.logo != null;
    bool selected = home.selected.id == e.id;
    return PopupMenuItem(
      onTap: () => onPickSupp(supplier, e, home, context),
      child: Row(
        spacing: 10,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueGrey.shade200,
            backgroundImage: hasImage
                ? NetworkImage('${dotenv.env['IMAGE_URL']}${supplier.logo!}')
                : null,
            child: (!hasImage)
                ? Text(
                    supplier.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20 * 0.9,
                    ),
                  )
                : null,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplier.name,
                style: TextStyle(
                    color: selected ? AppColors.succesColor : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '(${e.name})',
                style: TextStyle(
                  color: selected ? AppColors.succesColor : black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  onPickSupp(
    Supplier e,
    Stock stock,
    HomeProvider home,
    BuildContext context,
  ) async {
    await home.pickSupplier(e, stock, context);
    home.clearItems();
    home.setPageKey(1);
    home.fetchProducts();
  }

  Widget suplierPicker(HomeProvider home, BuildContext context) {
    return IntrinsicWidth(
      child: InkWell(
        onTap: () => _onPickSupplier(context, home),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Text(
                '${home.picked.name} ',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.succesColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 14,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget viewMode(HomeProvider home) {
    return IconButton(
      onPressed: () => home.switchView(),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: Colors.grey.shade200,
      ),
      icon: Icon(
        home.isList ? Icons.grid_view : Icons.list_sharp,
        color: primary,
      ),
    );
  }
}
