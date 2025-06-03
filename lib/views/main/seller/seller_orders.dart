import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/order/order_widget.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/loader/shimmer_box.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';
import 'package:provider/provider.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({super.key});

  @override
  State<SellerOrders> createState() => _SellerOrdersState();
}

class _SellerOrdersState extends State<SellerOrders>
    with SingleTickerProviderStateMixin {
  List<SellerOrderModel> orders = [];
  final TextEditingController search = TextEditingController();
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    init();
  }

  late AnimationController _controller;

  init() {
    final orderProvider = context.read<MyOrderProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        setLoading(true);
        await orderProvider.getSellerOrders();
        if (mounted) setLoading(false);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String selectedFilter = 'Харилцагчийн нэрээр';
  String filter = 'customer__name__icontains';
  TextInputType selectedType = TextInputType.name;
  void setFilter(v) {
    setState(() {
      selectedFilter = v;
      if (v == 'Харилцагчийн нэрээр') {
        filter = 'customer__name__icontains';
        selectedType = TextInputType.text;
      } else if (v == 'Захиалгын дугаараар') {
        filter = 'orderNo';
        selectedType = TextInputType.number;
      }
    });
  }

  DateTime selectedDate = DateTime.now();
  setDate(DateTime d) {
    setState(() {
      selectedDate = d;
    });
  }

  List<String> filters = ['Харилцагчийн нэрээр', 'Захиалгын дугаараар'];
  bool isEnd = false;
  String dateType = 'start';
  String dateTypeName = 'хойш';

  setDateType(String n) {
    setState(() {
      dateType = n;
    });
    if (dateType == 'start') {
      dateTypeName = 'хойш';
    } else {
      dateTypeName = 'өмнөх';
    }
  }

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Consumer2<MyOrderProvider, PharmProvider>(
      builder: (_, provider, pp, child) {
        return DataScreen(
          pad: EdgeInsets.all(7.5),
          onRefresh: () async => await init(),
          appbar: SideAppBar(
            title: searchBar(),
            preferredSize: const Size.fromHeight(kToolbarHeight + 10),
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            centerTitle: false,
          ),
          customLoading: shimmer(),
          loading: loading,
          empty: provider.sellerOrders.isEmpty,
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            key: _listKey,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            shrinkWrap: true,
            itemCount: provider.sellerOrders.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return OrderWidget(order: provider.sellerOrders[index]);
            },
          ),
        );
      },
    );
  }

  shimmer() {
    List<int> list = List.generate(5, (index) => index);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 10,
          children: list
              .map((index) => Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ShimmerBox(
                      controller: _controller,
                      height: 150,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.smallFontSize),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.search, color: Colors.black54),
            Expanded(
              child: TextFormField(
                controller: search,
                cursorColor: Colors.black,
                cursorHeight: 20,
                cursorWidth: .8,
                keyboardType: selectedType,
                onChanged: (value) {
                  final orderProvider = context.read<MyOrderProvider>();
                  WidgetsBinding.instance.addPostFrameCallback((cb) async {
                    if (value.isEmpty) {
                      await orderProvider.getSellerOrders();
                    } else {
                      await orderProvider.filterOrder(filter, search.text);
                    }
                  });
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '$selectedFilter хайх',
                  hintStyle: const TextStyle(color: Colors.black38),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showMenu(
                  context: context,
                  color: white,
                  shadowColor: Colors.grey.shade500,
                  position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                  items: [
                    ...filters.map(
                      (f) => PopupMenuItem(
                        child: SmallText(f, color: Colors.black),
                        onTap: () => setFilter(f),
                      ),
                    )
                  ],
                );
              },
              child: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
            ),
            InkWell(
              onTap: () => showCalendar(),
              child: Container(
                padding: EdgeInsets.only(right: Sizes.smallFontSize),
                child: Icon(
                  Icons.calendar_month,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCalendar() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Container(
              padding: const EdgeInsets.all(Sizes.smallFontSize),
              child: Wrap(
                children: [
                  CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                    onDateChanged: (d) {
                      setDialogState(() {
                        selectedDate = d;
                      });
                    },
                    onDisplayedMonthChanged: (value) => print(value),
                    initialCalendarMode: DatePickerMode.day,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                          '${selectedDate.toString().substring(0, 10)}-${!isEnd ? 'н хүртгэл' : 'c хойш'}'),
                      Switch(
                        value: isEnd,
                        onChanged: (b) {
                          setDialogState(() {
                            isEnd = b;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _smallbutton('Хаах', () => Navigator.pop(context)),
                      _smallbutton('Шүүх', () => _filter()),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _filter() async {
    final orderProvider = context.read<MyOrderProvider>();
    await orderProvider
        .filterOrder(
            !isEnd ? 'end' : 'start', selectedDate.toString().substring(0, 10))
        .whenComplete(() => Navigator.pop(context));
  }

  Widget _smallbutton(String title, Function() ontap) {
    return ElevatedButton(
      onPressed: ontap,
      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(white)),
      child: Text(title),
    );
  }
}
