import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/deliveries.dart';

class DriverButton extends StatelessWidget {
  const DriverButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = LocalBase.security;
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        return Positioned(
          bottom: 20,
          left: 20,
          child: SafeArea(
            child: Builder(
              builder: (context) {
                if (user != null && user.role == "D") {
                  return SizedBox(
                    width: ContextX(context).width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FloatingActionButton.extended(
                          elevation: 10,
                          heroTag: 'trackingDeliveries',
                          onPressed: () => goto(Deliveries()),
                          backgroundColor: Colors.white,
                          label: Column(
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  Text(
                                    'Идэвхитэй түгээлтүүд',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.shopping_bag,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              if (jagger.delivery != null &&
                                  jagger.delivery!.startedOn != null)
                                Row(
                                  spacing: 10,
                                  children: [
                                    Text(
                                      '${jagger.delivery!.startedOn!.substring(11, 16)}-с эхэлсэн',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox();
              },
            ),
          ),
        );
      },
    );
  }
}
