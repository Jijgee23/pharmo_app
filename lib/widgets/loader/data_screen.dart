import 'package:pharmo_app/application/application.dart';

class DataScreen extends StatelessWidget {
  final bool loading;
  final bool empty;
  final Widget child;
  final Widget? customEmpty;
  final Future<void> Function()? onRefresh;
  final PreferredSizeWidget? appbar;
  final BottomNavigationBar? navbar;
  final Color? bg;
  final EdgeInsetsGeometry? pad;
  final Widget? customLoading;

  const DataScreen({
    super.key,
    required this.loading,
    required this.empty,
    required this.child,
    this.onRefresh,
    this.appbar,
    this.navbar,
    this.customEmpty,
    this.bg,
    this.pad,
    this.customLoading,
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
                padding: EdgeInsets.all(10.0),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Image.asset(
            'assets/icons/not-found.png',
            width: 100,
          ),
          Text('Үр дүн олдсонгүй')
        ],
      ),
    );
  }
}
