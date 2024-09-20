// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/widgets/icon/cart_icon.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_grid.dart';
import 'package:provider/provider.dart';

class FilteredProducts extends StatefulWidget {
  final String? type;
  final int filterKey;
  final String title;
  const FilteredProducts(
      {super.key,
      required this.type,
      required this.filterKey,
      required this.title});

  @override
  State<FilteredProducts> createState() => _FilteredProductsState();
}

class _FilteredProductsState extends State<FilteredProducts> {
  final int _pageSize = 20;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  late HomeProvider homeProvider;
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      if (widget.type == 'cat') {
        _fetchByCategory(widget.filterKey, pageKey);
      } else {
        _fetchByMnfrsOrVndrs(widget.type!, widget.filterKey, pageKey);
      }
    });
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: 
      AppBar(
        leading: const ChevronBack(),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
        actions: const [CartIcon()],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomScrollView(
          slivers: [
            CustomGridView(pagingController: _pagingController),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchByMnfrsOrVndrs(
      String type, int filters, int pageKey) async {
    try {
      final newItems =
          await homeProvider.filter(type, filters, pageKey, _pageSize);
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _fetchByCategory(int key, int pageKey) async {
    try {
      final newItems = await homeProvider.filterCate(key, pageKey, _pageSize);
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
}
