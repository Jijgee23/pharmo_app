import 'package:pharmo_app/application/application.dart';

class BottomSubmit extends StatelessWidget {
  final String caption;
  final void Function() ontap;
  const BottomSubmit({
    super.key,
    this.caption = 'Хадгалах',
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      padding: EdgeInsets.all(20),
      child: SafeArea(
        child: CustomButton(
          text: caption,
          ontap: ontap,
        ),
      ),
    );
  }
}
