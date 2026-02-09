import 'package:pharmo_app/application/application.dart';

class PharmoFilterChip extends StatelessWidget {
  final String caption;
  final bool selected;
  final void Function() onPressed;
  const PharmoFilterChip({
    super.key,
    required this.caption,
    this.selected = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await LoadingService.run(() async {
          await Future.delayed(const Duration(milliseconds: 300));
          onPressed.call();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? primary : white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: selected ? BorderSide.none : BorderSide(color: grey400),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: selected ? white : grey400,
          ),
          SizedBox(width: 5),
          Text(
            caption,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? white : black,
            ),
          ),
        ],
      ),
    );
  }
}
