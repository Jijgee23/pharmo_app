import 'package:pharmo_app/views/public/order/order_widget.dart';
import 'package:pharmo_app/application/application.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({super.key});

  @override
  State<SellerOrders> createState() => _SellerOrdersState();
}

class _SellerOrdersState extends State<SellerOrders>
    with SingleTickerProviderStateMixin {
  List<SellerOrderModel> orders = [];
  final TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => init(),
    );
  }

  late AnimationController _controller;

  Future init() async {
    LoadingService.run(() async {
      final orderProvider = context.read<MyOrderProvider>();
      await orderProvider.getSellerOrders();
    });
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
        return Scaffold(
          appBar: SideAppBar(
            title: searchBar(),
            preferredSize: const Size.fromHeight(kToolbarHeight + 10),
            centerTitle: false,
          ),
          body: SafeArea(
            bottom: true,
            child: RefreshIndicator(
              onRefresh: () async => await init(),
              child: ListView.separated(
                padding: EdgeInsets.all(10),
                scrollDirection: Axis.vertical,
                key: _listKey,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                shrinkWrap: true,
                itemCount: provider.sellerOrders.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final order = provider.sellerOrders[index];
                  return OrderWidget(order: order);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.smallFontSize),
      decoration: BoxDecoration(
        color: primary.withAlpha(50),
        borderRadius: BorderRadius.circular(30),
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
                  WidgetsBinding.instance.addPostFrameCallback(
                    (cb) async {
                      if (value.isEmpty) {
                        await orderProvider.getSellerOrders();
                      } else {
                        await orderProvider.filterOrder(filter, search.text);
                      }
                    },
                  );
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
