import 'package:pharmo_app/application/application.dart';
import 'package:get/get.dart';
class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String Function(T) getLabel;
  final void Function(T?)? onChanged;
  final String text;
  final void Function()? onRemove;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.getLabel,
    this.value,
    this.onChanged,
    required this.text,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        constraints: BoxConstraints(minWidth: 150),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: grey300),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<T>(
                items: items.map<DropdownMenuItem<T>>((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(getLabel(item), style: filterStyle(context)),
                  );
                }).toList(),
                value: value,
                padding: EdgeInsets.symmetric(horizontal: 15),
                onChanged: onChanged,
                style: filterStyle(context),
                alignment: Alignment.center,
                isDense: true,
                dropdownColor: Colors.white,
                menuWidth: 200,
                borderRadius: BorderRadius.circular(10),
                underline: const SizedBox(),
                selectedItemBuilder: (BuildContext context) {
                  return items
                      .map((item) => filterText(text, context))
                      .toList();
                },
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget filterText(String text, BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.fade,
      softWrap: true,
      style: filterStyle(context),
    );
  }

  TextStyle filterStyle(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      color: context.theme.colorScheme.primary,
      overflow: TextOverflow.fade,
      fontWeight: FontWeight.w600,
    );
  }
}
