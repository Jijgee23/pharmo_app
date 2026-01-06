import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String Function(T) getLabel;
  final void Function(T?)? onChanged;
  final String text;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.getLabel,
    this.value,
    this.onChanged,
    required this.text,
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
          child: DropdownButton<T>(
            items: items.map<DropdownMenuItem<T>>((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(getLabel(item), style: filterStyle()),
              );
            }).toList(),
            value: value,
            padding: EdgeInsets.symmetric(horizontal: 15),
            onChanged: onChanged,
            style: filterStyle(),
            alignment: Alignment.center,
            isDense: true,
            dropdownColor: Colors.white,
            menuWidth: 200,
            borderRadius: BorderRadius.circular(10),
            underline: const SizedBox(),
            selectedItemBuilder: (BuildContext context) {
              return items.map((item) => filterText(text)).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget filterText(String text) {
    return Text(
      text,
      overflow: TextOverflow.fade,
      softWrap: true,
      style: filterStyle(),
    );
  }

  TextStyle filterStyle() {
    return TextStyle(
      fontSize: 12,
      color: theme.colorScheme.primary,
      overflow: TextOverflow.fade,
      fontWeight: FontWeight.w600,
    );
  }
}
