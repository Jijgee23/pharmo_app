import 'package:pharmo_app/views/home/widgets/modern_field.dart';
import 'package:pharmo_app/views/home/widgets/modern_icon.dart';
import 'package:pharmo_app/views/home/widgets/selected_filter.dart';
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
        return SafeArea(
          bottom: true,
          child: Column(
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  ModernField(
                    hint: '$selectedFilter хайх',
                    onChanged: (v) {
                      final orderProvider = context.read<MyOrderProvider>();
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
              ),
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
                          return OrderWidget(order: order);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 10),
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
    final orderProvider = context.read<MyOrderProvider>();
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
