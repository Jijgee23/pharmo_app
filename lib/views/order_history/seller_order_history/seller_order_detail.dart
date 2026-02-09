import 'package:pharmo_app/views/SELLER/customer/add_customer.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/order_general_builder.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/order_item_card.dart';
import 'package:pharmo_app/views/product/add_basket_sheet.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:get/get.dart';
class SellerOrderDetail extends StatefulWidget {
  final int oId;
  const SellerOrderDetail({super.key, required this.oId});

  @override
  State<SellerOrderDetail> createState() => _SellerOrderDetailState();
}

class _SellerOrderDetailState extends State<SellerOrderDetail>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  final TextEditingController qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderModel>(
      stream: context.read<PharmProvider>().getSellerOrderDetail(widget.oId),
      builder: (context, stream) {
        return Scaffold(
          appBar: _buildAppBar(context, stream),
          body: Builder(builder: (context) {
            if (stream.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return _buildContent(stream);
          }),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AsyncSnapshot<OrderModel> stream,
  ) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      title: Text(
        maybeNull(stream.data?.orderNo.toString()),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: controller,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            tabs: const [
              Tab(text: 'Ерөнхий'),
              Tab(text: 'Бараа'),
            ],
            overlayColor: WidgetStateProperty.all(
              Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ),
      ),
      actions: [
        if (stream.hasData)
          IconButton(
            onPressed: () => _showEditBottomSheet(context, stream.data!),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Засах',
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(AsyncSnapshot<OrderModel> stream) {
    if (stream.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (stream.hasError) {
      return _buildErrorState(stream.error.toString());
    }
    if (!stream.hasData) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: controller,
      children: [
        OrderGeneralBuilder(order: stream.data!),
        _buildProductsTab(stream.data!),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Алдаа гарлаа',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Захиалгын мэдээлэл олдсонгүй',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab(OrderModel order) {
    if (order.products == null || order.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Бараа олдсонгүй',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade50,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: order.products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = order.products[index];
          return OrderItemCard(
            orderId: order.id,
            item: item,
            ontap: () => changeQty(order.id, item),
          );
        },
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, OrderModel order) {
    setState(() {});
    Get.bottomSheet(
      EditSellerOrder(order: order),
      isScrollControlled: true,
    );
  }

  Future<void> changeQty(int oid, dynamic item) async {
    qtyController.text = item['itemQty'].toString();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                item['itemName'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              // Input field
              Input(
                hint: 'Тоо ширхэг оруулна уу',
                contr: qtyController,
                keyType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Save button
              CustomButton(
                text: 'Хадгалах',
                ontap: () => _changeQty(oid, item),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> _changeQty(int oid, dynamic item) async {
    final p = context.read<PharmProvider>();

    if (qtyController.text.isEmpty) {
      messageWarning('Тоон утга оруулна уу!');
      return;
    }

    final qty = int.tryParse(qtyController.text);
    if (qty == null) {
      messageWarning('Зөв тоон утга оруулна уу!');
      return;
    }

    if (qty == 0) {
      messageWarning('Тоо ширхэг 0 байж болохгүй!');
      return;
    }

    try {
      final res = await p.changeItemQty(
        context: context,
        oId: oid,
        itemId: item['productId'],
        qty: qty,
      );

      if (res != null) {
        messageWarning(res['message'] ?? 'Амжилттай шинэчлэгдлээ');
      }

      Get.back();
    } catch (e) {
      messageWarning('Алдаа гарлаа: $e');
    }
  }
}

class EditSellerOrder extends StatefulWidget {
  final OrderModel order;
  const EditSellerOrder({super.key, required this.order});

  @override
  State<EditSellerOrder> createState() => _EditSellerOrderState();
}

class _EditSellerOrderState extends State<EditSellerOrder> {
  final nc = TextEditingController();
  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    print(widget.order.payMethod.value);
    setState(() {
      nc.text = widget.order.noteText ?? '';
      setPayType(widget.order.payMethod);
    });
  }

  PayType method = PayType.unknown;
  setPayType(PayType value) {
    setState(() {
      method = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Захиалгын мэдээлэл засах',
                    style: TextStyle(fontSize: 12),
                  ),
                  PopSheet()
                ],
              ),
              BottomSheetLabelBuilder('Тайлбар (Заавал биш)'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: nc,
                  decoration: const InputDecoration(
                    hintText: 'Энд тайлбар бичиж болно...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
              BottomSheetLabelBuilder('Төлбөрийн хэлбэр'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 10,
                children: [
                  ...paymentMethods.map(
                    (pm) => Expanded(
                      child: BottomSheetOptionChip(
                        title: pm.name,
                        v: pm.value,
                        icon: pm.icon,
                        isSelected: method == pm,
                        onTap: () => setPayType(pm),
                      ),
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: 'Хадгалах',
                ontap: () async {
                  final pp = context.read<PharmProvider>();
                  await pp
                      .editSellerOrder(
                        nc.text,
                        method.name,
                        widget.order.id,
                        context,
                      )
                      .then(
                        (e) => Navigator.pop(context),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
