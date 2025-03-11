import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/loader/custom_shimmer.dart';

class DataScreen extends StatelessWidget {
  final bool loading;
  final bool empty;
  final Widget child;
  final Widget? customEmpty;
  final Future<void> Function()? onRefresh;
  final PreferredSizeWidget? appbar;
  final BottomNavigationBar? navbar;

  const DataScreen({
    super.key,
    required this.loading,
    required this.empty,
    required this.child,
    this.onRefresh,
    this.appbar,
    this.navbar,
    this.customEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.pinkAccent,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      onRefresh: onRefresh ?? () async {},
      child: Scaffold(
        appBar: appbar,
        body: loading
            ? const CustomShimmer()
            : (empty)
                ? customEmpty ?? noResult()
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7.5),
                    margin: const EdgeInsets.only(top: 7.5),
                    child: child,
                  ),
        bottomNavigationBar: navbar,
      ),
    );
  }

  Center noResult() {
    return Center(
      child: Image.asset(
        'assets/icons/not-found.png',
        width: Sizes.width * 0.3,
      ),
    );
  }
}
