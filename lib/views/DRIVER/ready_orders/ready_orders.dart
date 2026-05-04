import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/DRIVER/ready_orders/ready_order_card.dart';

class ReadyOrders extends StatefulWidget {
  const ReadyOrders({super.key});

  @override
  State<ReadyOrders> createState() => _ReadyOrdersState();
}

class _ReadyOrdersState extends State<ReadyOrders> {
  List<int> selecteds = [];
  int delman = -1;
  String me = 'Өөрийн';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await fetch());
  }

  Future fetch() async {
    LoadingService.run(() async {
      final jag = context.read<DriverProvider>();
      await jag.getOrders();
      await jag.getDelmans();
    });
  }

  void onTapOrder(DeliveryOrder order) {
    setState(() {
      selecteds.contains(order.id) ? selecteds.remove(order.id) : selecteds.add(order.id);
    });
  }

  void setDelman(int n) {
    setState(() {
      delman = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, jagger, child) => Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Бэлэн захиалгууд',
                      style: context.theme.appBarTheme.titleTextStyle,
                    )
                  ],
                ).paddingAll(10),
                Divider(),
                Flexible(
                  child: Builder(
                    builder: (context) {
                      if (jagger.orders.isEmpty) {
                        return NoResult();
                      }
                      return ListView.builder(
                        itemCount: jagger.orders.length,
                        itemBuilder: (context, index) {
                          final order = jagger.orders[index];
                          return ReadyOrderCard(
                            onTap: () => onTapOrder(order),
                            selected: selecteds.contains(order.id),
                            ord: order,
                          );
                        },
                      );
                    },
                  ).paddingAll(10),
                )
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Durations.medium1,
            bottom: 20,
            right: selecteds.isNotEmpty ? 20 : -300,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 30,
                      ),
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(16),
                      ),
                    ),
                    onPressed: () => addSheet(jagger),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 12,
                      children: [
                        Icon(Icons.add_rounded, color: white, size: 20),
                        Text(
                          'Түгээлт рүү нэмэх',
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void addSheet(DriverProvider driver) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
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
              Text(
                'Түгээлтэнд нэмэх (${selecteds.length} захиалга)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),

              // 1. Selection Type
              const BottomSheetLabelBuilder('Түгээгч сонгох төрөл'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BottomSheetOptionChip(
                      title: 'Өөрийн',
                      v: 'Өөрийн',
                      icon: '👤',
                      isSelected: me == 'Өөрийн',
                      onTap: () => setModalState(() => me = 'Өөрийн'),
                    ),
                  ),
                  Expanded(
                    child: BottomSheetOptionChip(
                      title: 'Бусдын',
                      v: 'Бусдын',
                      icon: '👥',
                      isSelected: me == 'Бусдын',
                      onTap: () => setModalState(() => me = 'Бусдын'),
                    ),
                  ),
                ],
              ),

              // 2. Delman Selection (Conditional)
              if (me != 'Өөрийн') ...[
                const SizedBox(height: 24),
                const BottomSheetLabelBuilder('Түгээгч сонгох'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100, // Fixed height for horizontal scroll or use Wrap
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: driver.delmans.map((dm) {
                        bool isSelected = delman == dm.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(dm.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) HapticFeedback.lightImpact();
                              setModalState(() => delman = dm.id);
                            },
                            // --- Modern Styling ---
                            elevation: isSelected ? 4 : 0,
                            pressElevation: 0,
                            shadowColor: primary.withOpacity(0.3),
                            backgroundColor: Colors.grey[100],
                            selectedColor: primary.withOpacity(0.15),
                            side: BorderSide(
                              color: isSelected ? primary : Colors.transparent,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // Softer, more modern corners
                            ),
                            showCheckmark: false, // Modern chips usually skip the checkmark icon
                            labelStyle: TextStyle(
                              color: isSelected ? primary : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // 3. Action Button
              CustomButton(
                text: 'Хадгалах',
                ontap: () {
                  if (me == 'Өөрийн') {
                    driver.addOrdersToDelivery(selecteds);
                  } else {
                    if (delman == -1) {
                      message('Түгээгч сонгоно уу!');
                      return;
                    }
                    driver.passOrdersToDelman(selecteds, delman);
                  }
                  Navigator.pop(context);
                  setState(() => selecteds.clear()); // Clear main state
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void cleanOrders(Function(void Function()) setModalState) {
    setModalState(() {
      selecteds.clear();
    });
  }
}
