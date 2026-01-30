import 'package:flutter/material.dart';

class ModernDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Color? valueColor;
  const ModernDetailRow(this.label, this.value, {super.key, this.valueColor});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty || value == 'null') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Flexible(
            child: Text(
              value ?? '-',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
