import 'package:pharmo_app/application/application.dart';

class SelectedFilter extends StatelessWidget {
  final String caption;
  final void Function() onSelect;
  final bool selected;
  const SelectedFilter({
    super.key,
    required this.selected,
    required this.caption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? primary : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        padding: EdgeInsets.all(15),
      ),
      onPressed: () {
        onSelect();
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            caption,
            style: TextStyle(color: selected ? white : Colors.black),
          ),
          if (selected) Icon(Icons.check, color: white)
        ],
      ),
    );
  }
}
