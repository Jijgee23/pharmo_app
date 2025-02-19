import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/pharmacy/my_orders/my_order_detail.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/views/main/seller/seller_order_detail.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:pharmo_app/widgets/ui_help/container.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({super.key});

  @override
  State<SellerOrders> createState() => _SellerOrdersState();
}

class _SellerOrdersState extends State<SellerOrders> {
  late MyOrderProvider orderProvider;
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
    orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    init();
  }

  init() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        setLoading(true);
        await orderProvider.getSellerOrders();
        if (mounted) setLoading(false);
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<MyOrderProvider, PharmProvider>(
      builder: (_, provider, pp, child) {
        return DataScreen(
          onRefresh: () async => await init(),
          appbar: SideAppBar(
            title: searchBar(),
            action: InkWell(
              onTap: () => showCalendar(),
              child: const Padding(
                  padding: EdgeInsets.only(right: Sizes.smallFontSize),
                  child: Icon(Icons.calendar_month)),
            ),
          ),
          loading: loading,
          empty: provider.sellerOrders.isEmpty,
          child: SingleChildScrollView(
            child: Wrap(runSpacing: Sizes.smallFontSize / 3, children: [
              ...provider.sellerOrders.map(
                (e) => OrderWidget(
                  order: provider.sellerOrders[provider.sellerOrders.indexOf(e)],
                ),
              )
            ]),
          ),
        );
      },
    );
  }

  Widget searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.smallFontSize),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Sizes.smallFontSize),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: Sizes.width * .5,
              child: TextFormField(
                controller: search,
                cursorColor: Colors.black,
                cursorHeight: 20,
                cursorWidth: .8,
                keyboardType: selectedType,
                onChanged: (value) {
                  print([search.text, filter]);
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
    await orderProvider
        .filterOrder(!isEnd ? 'end' : 'start', selectedDate.toString().substring(0, 10))
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

class OrderWidget extends StatelessWidget {
  final SellerOrderModel order;
  const OrderWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, provider, child) => Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              flex: 2,
              onPressed: (context) => askDeletetion(context, provider, order.orderNo.toString()),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Устгах',
              borderRadius: BorderRadius.circular(8),
            )
          ],
        ),
        child: Ctnr(
          child: InkWell(
            onTap: () => goto(SellerOrderDetail(oId: maybeNull(order.id.toString()))),
            child: Wrap(
              runSpacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: primary.withOpacity(.3), borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: primary),
                          const SizedBox(width: 5),
                          Text(maybeNull(order.customer),
                              style: const TextStyle(fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    TitleContainer(
                      child: Col(
                          t1: toPrice(order.totalPrice.toString()),
                          t2: '#${order.orderNo.toString()}'),
                    ),
                  ],
                ),
                Container(
                  height: 1.8,
                  width: double.maxFinite,
                  color: grey300,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tx(order.status),
                        tx(order.process),
                        tx(order.createdOn.toString().substring(0, 10))
                      ],
                    ),
                    const SizedBox()
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  tx(String? s) {
    return Text(maybeNull(s), style: const TextStyle(fontSize: 14, color: Colors.black));
  }

  askDeletetion(BuildContext context, MyOrderProvider op, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.bigFontSize),
            child: Column(
              children: [
                text('Та $name дугаартай захиалгыг устгамаар байна уу?',
                    color: black, align: TextAlign.center),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    btn(true, context, op),
                    btn(false, context, op),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  btn(bool isPop, BuildContext context, MyOrderProvider op) {
    return DialogButton(
      width: Sizes.width * 0.3,
      color: theme.primaryColor,
      child: SmallText(isPop ? 'Үгүй' : 'Тийм', color: white),
      onPressed: () => isPop
          ? Navigator.pop(context)
          : deleteOrder(op).then(
              (e) => Navigator.pop(context),
            ),
    );
  }

  Future deleteOrder(MyOrderProvider op) async {
    await op.deleteSellerOrders(orderId: order.id);
  }
}
