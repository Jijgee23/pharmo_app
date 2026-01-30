import 'package:pharmo_app/views/SELLER/customer/add_customer.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/order_general_builder.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/order_item_card.dart';
import 'package:pharmo_app/views/public/product/add_basket_sheet.dart';
import 'package:pharmo_app/application/application.dart';

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
          body: _buildContent(stream),
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
    Get.bottomSheet(
      EditSellerOrder(
        note: maybeNull(order.noteText),
        pt: order.payType ?? '',
        oId: order.id,
      ),
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
  final String note;
  final String pt;
  final int oId;
  const EditSellerOrder({
    super.key,
    required this.note,
    required this.pt,
    required this.oId,
  });

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
    if (widget.note != null && widget.note != 'null') {
      setState(() {
        nc.text = widget.note;
      });
    }
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
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Захиалгын мэдээлэл засах',
                      style: TextStyle(fontSize: 12)),
                  PopSheet()
                ],
              ),
              Input(hint: 'Нэмэлт тайлбар', contr: nc),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 10,
                children: [
                  MyChip(
                      title: 'Дансаар',
                      v: 'T',
                      selected: payType == 'T',
                      ontap: () => setPayType('T')),
                  MyChip(
                      title: 'Бэлнээр',
                      v: 'C',
                      selected: payType == 'C',
                      ontap: () => setPayType('C')),
                  MyChip(
                      title: 'Зээлээр',
                      v: 'L',
                      selected: payType == 'L',
                      ontap: () => setPayType('L')),
                ],
              ),
              CustomButton(
                text: 'Хадгалах',
                ontap: () {
                  final pharmProvider =
                      Provider.of<PharmProvider>(context, listen: false);
                  pharmProvider
                      .editSellerOrder(nc.text, payType, widget.oId, context)
                      .then((e) => Navigator.pop(context));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String payType = '';
  setPayType(String v) {
    setState(() {
      payType = v;
    });
  }
}
