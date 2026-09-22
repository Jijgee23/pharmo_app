import 'package:pharmo_app/application/app_lite.dart';

class PopSheet extends StatelessWidget {
  const PopSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade700,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Image.asset(
          'assets/cross-small.png',
          height: 16,
          color: Colors.black.withOpacity(.5),
        ),
      ),
    );
  }
}
