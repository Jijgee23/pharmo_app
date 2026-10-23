import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/order_card/order_card.dart';
import 'package:pharmo_app/views/order_history/order_card/order_card_skeleton.dart';
import 'package:pharmo_app/views/order_history/pharm_order_history/custom_drop.dart';

class PharmOrderHistory extends StatefulWidget {
  const PharmOrderHistory({super.key});
  @override
  State<PharmOrderHistory> createState() => _PharmOrderHistoryState();
}

class _PharmOrderHistoryState extends State<PharmOrderHistory> {
  // This widget is rebuilt each time the bottom bar switches back to it;
  // the list, its filters and scroll position are kept on OrderProvider.
  late final OrderProvider _orders;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _orders = context.read<OrderProvider>();
    _scrollController = ScrollController(initialScrollOffset: _orders.ordersScrollOffset)
      ..addListener(() => _orders.ordersScrollOffset = _scrollController.position.pixels);
    // Back on the tab with a list already loaded: show it as it was, then
    // update it in place, since statuses move and new orders come in.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => _orders.ordersLoaded ? await _orders.filterOrders() : await refresh(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future refresh({bool afterInit = false}) async {
    final order = context.read<OrderProvider>();
    order.setLoading(true);
    try {
      if (!afterInit) {
        await order.getBranches();
        await order.getSuppliers();
      }
      await order.filterOrders();
    } catch (e) {
      throw Exception(e);
    } finally {
      order.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OrderProvider, HomeProvider>(
      builder: (context, provider, home, _) {
        final orders = provider.orders;
        return SafeArea(
          bottom: false,
          child: Column(
            spacing: 10,
            children: [
              if (context.isLandscape) SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 7.5,
                children: [
                  Text(
                    'Захиалгын түүх',
                    style: context.theme.appBarTheme.titleTextStyle,
                  ),
                  filterRow(),
                ],
              ).paddingSymmetric(horizontal: 10),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => await refresh(),
                  child: Builder(
                    builder: (context) {
                      if (provider.loading) {
                        return SkeletonList();
                      }
                      if (orders.isEmpty) {
                        return const EmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'Захиалга олдсонгүй',
                          message: 'Захиалга өгөхөд энд харагдана.',
                          padding: EdgeInsets.only(bottom: 100),
                        );
                      }
                      return HomeScrollListener(
                        xchild: ListView.separated(
                          controller: _scrollController,
                          itemBuilder: (_, idx) {
                            return OrderCard(order: orders[idx]);
                          },
                          separatorBuilder: (_, idx) => SizedBox(height: 10),
                          itemCount: orders.isNotEmpty ? orders.length : 1,
                        ),
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

  Widget filterRow() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) => Container(
        height: 60,
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomDropdown<OrderStatus>(
                items: OrderStatus.filterList,
                getLabel: (OrderStatus st) => st.name,
                value: provider.status,
                onChanged: (OrderStatus? newValue) => provider.updateStatus(newValue),
                text: provider.status == OrderStatus.all ? "Төлөв" : provider.status.name,
                onRemove: provider.status == OrderStatus.all
                    ? null
                    : () => provider.updateStatus(OrderStatus.all),
              ),
              CustomDropdown<OrderProcess>(
                items: OrderProcess.filterList,
                getLabel: (OrderProcess pro) => pro.name,
                value: provider.process,
                onChanged: (OrderProcess? newValue) => provider.updateProcess(newValue),
                text: provider.process == OrderProcess.all ? "Явц" : provider.process.name,
                onRemove: provider.process == OrderProcess.all
                    ? null
                    : () => provider.updateProcess(OrderProcess.all),
              ),
              CustomDropdown<PayType>(
                items: PayType.filterList,
                getLabel: (PayType pm) => pm.name,
                value: provider.paymentMethod,
                onChanged: (PayType? newValue) => provider.updatePayMethod(newValue),
                text: provider.paymentMethod == PayType.unknown
                    ? "Төлбөрийн хэлбэр"
                    : provider.paymentMethod.name,
                onRemove: provider.paymentMethod == PayType.unknown
                    ? null
                    : () => provider.updatePayMethod(PayType.unknown),
              ),
              CustomDropdown<Branch>(
                items: provider.branches,
                getLabel: (Branch s) => s.name,
                value: provider.branches.isNotEmpty
                    ? provider.branches.firstWhere(
                        (b) => b.id == provider.branch.id,
                        orElse: () => provider.branches.first,
                      )
                    : Branch(id: -1, name: 'Салбар сонгох'),
                onChanged: (Branch? value) async {
                  provider.updateBranch(value);
                },
                text: provider.branch.name,
                onRemove: provider.branch.id == -1
                    ? null
                    : () => provider.updateBranch(
                          Branch(id: -1, name: 'Салбар сонгох'),
                        ),
              ),
              CustomDropdown<Supplier>(
                items: provider.suppliers,
                getLabel: (Supplier s) => s.name,
                value: provider.suppliers.isNotEmpty
                    ? provider.suppliers.firstWhere(
                        (b) => b.id == provider.supplier.id,
                        orElse: () => provider.suppliers.first,
                      )
                    : Supplier(
                        id: -1,
                        name: 'Нийлүүлэгч сонгох',
                        stocks: [],
                      ),
                onChanged: (Supplier? value) async {
                  provider.updateSupplier(value);
                },
                text: provider.supplier.name,
                onRemove: provider.supplier.id == -1
                    ? null
                    : () => provider.updateSupplier(
                          Supplier(
                            id: -1,
                            name: 'Нийлүүлэгч сонгох',
                            stocks: [],
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
