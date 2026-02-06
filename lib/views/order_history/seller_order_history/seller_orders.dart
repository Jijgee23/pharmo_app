import 'package:pharmo_app/views/order_history/order_card/order_card.dart';
import 'package:pharmo_app/application/application.dart';

class SellerOrderHistory extends StatefulWidget {
  const SellerOrderHistory({super.key});

  @override
  State<SellerOrderHistory> createState() => _SellerOrderHistoryState();
}

class _SellerOrderHistoryState extends State<SellerOrderHistory>
    with SingleTickerProviderStateMixin {
  List<OrderModel> orders = [];
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
      final orderProvider = context.read<OrderProvider>();
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
    return Consumer2<OrderProvider, PharmProvider>(
      builder: (_, provider, pp, child) {
        return SafeArea(
          bottom: true,
          child: Column(
            spacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 7.5,
                children: [
                  Text(
                    'Захиалгын түүх',
                    style: ContextX(context).theme.appBarTheme.titleTextStyle,
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      ModernField(
                        hint: '$selectedFilter хайх',
                        onChanged: (v) {
                          final orderProvider = context.read<OrderProvider>();
                          WidgetsBinding.instance.addPostFrameCallback(
                            (cb) async {
                              if (v.isEmpty) {
                                await orderProvider.getSellerOrders();
                              } else {
                                await orderProvider.filterOrder(
                                    filter, search.text);
                              }
                            },
                          );
                        },
                        suffixIcon: IconButton(
                          onPressed: selectType,
                          icon: Icon(
                            Icons.settings,
                          ),
                        ),
                      ),
                      ModernIcon(
                        iconData: Icons.calendar_month,
                        onPressed: showCalendar,
                      ),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 10),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => await init(),
                  child: Builder(
                    builder: (context) {
                      if (provider.sellerOrders.isEmpty) {
                        return Column(children: [NoResult()]);
                      }
                      return ListView.separated(
                        padding: EdgeInsets.only(bottom: 100),
                        scrollDirection: Axis.vertical,
                        key: _listKey,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        shrinkWrap: true,
                        itemCount: provider.sellerOrders.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final order = provider.sellerOrders[index];
                          return OrderCard(order: order);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void selectType() {
    mySheet(
      isDismissible: true,
      spacing: 10,
      title: 'Хайх төрөл сонгоно уу',
      children: [
        ...filters.map(
          (f) => SelectedFilter(
            selected: f == selectedFilter,
            caption: f,
            onSelect: () => setFilter(f),
          ),
        )
      ],
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
    final orderProvider = context.read<OrderProvider>();
    await orderProvider
        .filterOrder(
            !isEnd ? 'end' : 'start', selectedDate.toString().substring(0, 10))
        .whenComplete(
          () => Navigator.pop(context),
        );
  }

  Widget _smallbutton(String title, Function() ontap) {
    return ElevatedButton(
      onPressed: ontap,
      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(white)),
      child: Text(title),
    );
  }
}
