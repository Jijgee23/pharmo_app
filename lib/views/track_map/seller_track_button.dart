import 'package:pharmo_app/application/application.dart';

class SellerTrackButton extends StatelessWidget {
  final bool isStart;
  final void Function() onPressed;

  const SellerTrackButton(
      {super.key, required this.onPressed, required this.isStart});

  @override
  Widget build(BuildContext context) {
    final user = LocalBase.security;
    return Positioned(
      bottom: 20,
      left: 20,
      child: SafeArea(
        child: Builder(builder: (context) {
          if (user == null || (user != null && user.role != 'S')) {
            return SizedBox();
          }
          return SizedBox(
            width: ContextX(context).width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FloatingActionButton.extended(
                  elevation: 10,
                  heroTag: 'trackingDeliveries',
                  onPressed: onPressed,
                  backgroundColor: (isStart ? Colors.green : Colors.red),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                      Icon(
                        isStart ? Icons.gps_fixed : Icons.gps_off,
                        color: white,
                      ),
                      Text(
                        "Борлуулалт ${isStart ? 'эхлэх' : 'дуусгах'}",
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
