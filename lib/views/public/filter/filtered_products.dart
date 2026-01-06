// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/controller/models/products.dart';
import 'package:pharmo_app/views/home.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:provider/provider.dart';

class FilteredProducts extends StatefulWidget {
  final String? type;
  final int filterKey;
  final String title;
  const FilteredProducts(
      {super.key, required this.type, required this.filterKey, required this.title});

  @override
  State<FilteredProducts> createState() => _FilteredProductsState();
}

class _FilteredProductsState extends State<FilteredProducts> {
  final int _pageSize = 20;
  int pageKey = 1;
  setPageKey(int n) {
    setState(() {
      pageKey + n;
    });
  }

  late HomeProvider homeProvider;
  List<Product> products = [];
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setPageKey(pageKey + 1);
        fetItems();
      }
    });

    fetItems();
  }

  @override
  void dispose() {
    super.dispose();
  }

  fetItems() async {
    List<Product> items =
        await homeProvider.filter(widget.type!, widget.filterKey, pageKey, _pageSize);
    setState(() {
      products.addAll(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => Scaffold(
        appBar: SideAppBar(text: widget.title, hasBasket: true),
        body: Center(
          child: Container(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Products(controller: _scrollController, products: products),
          ),
        ),
      ),
    );
  }
}
