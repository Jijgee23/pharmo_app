import 'package:pharmo_app/application/application.dart';

class PharmoFilterChip extends StatelessWidget {
  final String caption;
  final bool selected;
  final void Function()? onPressed;
  const PharmoFilterChip(
      {super.key,
      required this.caption,
      this.selected = false,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? primary : white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: selected ? BorderSide.none : BorderSide(color: grey400),
        ),
      ),
      child: Text(
        caption,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected ? white : black,
        ),
      ),
    );
  }
}
