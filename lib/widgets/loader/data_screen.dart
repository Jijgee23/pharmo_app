import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/constants.dart';
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
  final Widget? fab;
  final Color? bg;
  final EdgeInsetsGeometry? pad;
  final Widget? customLoading;
  final FloatingActionButtonLocation fabLoc;

  const DataScreen({
    super.key,
    required this.loading,
    required this.empty,
    required this.child,
    this.onRefresh,
    this.appbar,
    this.navbar,
    this.customEmpty,
    this.fab,
    this.bg,
    this.pad,
    this.customLoading,
    this.fabLoc = FloatingActionButtonLocation.endFloat,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.pinkAccent,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      onRefresh: onRefresh ?? () async {},
      child: Scaffold(
        backgroundColor: bg,
        floatingActionButton: fab,
        floatingActionButtonLocation: fabLoc,
        appBar: appbar,
        body: AnimatedSwitcher(
          duration: duration,
          child: Builder(
            builder: (context) {
              if (loading) {
                return customLoading ?? CustomShimmer();
              }
              if (empty) {
                return customEmpty ?? noResult();
              }
              return Container(
                padding: pad ?? EdgeInsets.all(7.5),
                child: child,
              );
            },
          ),
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
