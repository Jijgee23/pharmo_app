import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/printer/delivery_order_ticket.dart';
import 'package:pharmo_app/views/printer/printer_provider.dart';

class PrintPreviev extends StatefulWidget {
  final DeliveryOrder order;
  const PrintPreviev({super.key, required this.order});

  @override
  State<PrintPreviev> createState() => _PrintPrevievState();
}

class _PrintPrevievState extends State<PrintPreviev> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<PrinterProvider>(
      builder: (context, printer, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Баримт хэвлэх'),
          actions: [
            IconButton(
              onPressed: printer.scanDevices,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: printer.loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TicketPreview(order: widget.order),
                  const SizedBox(height: 20),
                  Text(
                    'Bluetooth төхөөрөмж',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (printer.devices.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          spacing: 12,
                          children: [
                            Text(
                              'Төхөөрөмж олдсонгүй',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            ElevatedButton(
                              onPressed: () => printer.scanDevices(),
                              style: ElevatedButton.styleFrom(
                                maximumSize: Size(120, 40),
                                minimumSize: Size(120, 32),
                                backgroundColor: AppColors.main,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.refresh, color: white),
                                  Text(
                                    'Хайх',
                                    style: TextStyle(color: white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  else
                    ...printer.devices.map((device) {
                      final connected = printer.connectedDevice?.macAdress == device.macAdress;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: connected ? Colors.green.shade300 : Colors.grey.shade200,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => printer.connect(device),
                          leading: Icon(
                            Icons.print_outlined,
                            color: connected ? Colors.green.shade600 : Colors.grey.shade500,
                          ),
                          title: Text(device.name, style: theme.textTheme.bodyMedium),
                          trailing: TextButton(
                            onPressed: () => printer.connect(device),
                            child: Text(
                              connected ? 'Холбогдсон' : 'Холбох',
                              style: TextStyle(
                                color: connected ? Colors.green.shade600 : AppColors.main,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
        bottomNavigationBar: (printer.loading)
            ? null
            : Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      if (printer.connectedDevice != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bluetooth_connected,
                                  size: 16, color: Colors.green.shade600),
                              const SizedBox(width: 6),
                              Text(
                                printer.connectedDevice!.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      CustomButton(
                        text: 'Хэвлэх',
                        ontap: () {
                          final deliveryId = context.read<JaggerProvider>().delivery?.id;
                          printer.printOrder(widget.order, deliveryId: deliveryId);
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
