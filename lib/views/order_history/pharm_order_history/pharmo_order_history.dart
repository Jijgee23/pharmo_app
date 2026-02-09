import 'package:pharmo_app/views/order_history/pharm_order_history/custom_drop.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/order_card/order_card.dart';
import 'package:get/get.dart';
class PharmOrderHistory extends StatefulWidget {
  const PharmOrderHistory({super.key});
  @override
  State<PharmOrderHistory> createState() => _PharmOrderHistoryState();
}

class _PharmOrderHistoryState extends State<PharmOrderHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await refresh());
  }

  Future refresh({bool afterInit = false}) async {
    LoadingService.run(() async {
      final order = context.read<OrderProvider>();
      if (!afterInit) {
        await order.getBranches();
        await order.getSuppliers();
      }
      await order.filterOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final orders = provider.orders;
        return SafeArea(
          child: Column(
            spacing: 10,
            children: [
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
                child: Builder(
                  builder: (context) {
                    if (orders.isEmpty) {
                      return NoResult();
                    }
                    return ListView.separated(
                      itemBuilder: (_, idx) {
                        return OrderCard(order: orders[idx]);
                      },
                      separatorBuilder: (_, idx) => SizedBox(height: 10),
                      itemCount: orders.isNotEmpty ? orders.length : 1,
                    );
                  },
                ),
              )
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
                onChanged: (OrderStatus? newValue) =>
                    provider.updateStatus(newValue),
                text: provider.status == OrderStatus.all
                    ? "Төлөв"
                    : provider.status.name,
                onRemove: provider.status == OrderStatus.all
                    ? null
                    : () => provider.updateStatus(OrderStatus.all),
              ),
              CustomDropdown<OrderProcess>(
                items: OrderProcess.filterList,
                getLabel: (OrderProcess pro) => pro.name,
                value: provider.process,
                onChanged: (OrderProcess? newValue) =>
                    provider.updateProcess(newValue),
                text: provider.process == OrderProcess.all
                    ? "Явц"
                    : provider.process.name,
                onRemove: provider.process == OrderProcess.all
                    ? null
                    : () => provider.updateProcess(OrderProcess.all),
              ),
              CustomDropdown<PayType>(
                items: PayType.filterList,
                getLabel: (PayType pm) => pm.name,
                value: provider.paymentMethod,
                onChanged: (PayType? newValue) =>
                    provider.updatePayMethod(newValue),
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
