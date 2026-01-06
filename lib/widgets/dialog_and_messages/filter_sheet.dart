import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';

import '../../application/utilities/colors.dart';

typedef FilterContentBuilder = List<Widget> Function(
    BuildContext context, StateSetter setModalState);

Future<void> showFilterBottomSheet({
  required BuildContext context,
  required FilterContentBuilder contentBuilder,
  required FutureOr<void> Function() onSubmit,
  String submitLabel = 'Хайх',
  bool showCloseAction = true,
  VoidCallback? onClose,
  BoxConstraints? constraints,
  EdgeInsetsGeometry padding = const EdgeInsets.all(15),
}) {
  final sheetConstraints = constraints ??
      BoxConstraints(
        minWidth: Sizes.width,
        maxHeight: Sizes.height * .9,
      );

  return Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        final children = contentBuilder(context, setState);
        return Container(
          constraints: sheetConstraints,
          decoration: BoxDecoration(
            color: white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          padding: padding,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                spacing: 20,
                children: [
                  if (showCloseAction)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            onClose?.call();
                            await Navigator.of(context).maybePop();
                          },
                          child: Icon(Icons.cancel_outlined, size: 30),
                        ),
                      ],
                    ),
                  ...children,
                  CustomButton(
                    text: submitLabel,
                    ontap: () async {
                      await Navigator.of(context).maybePop();
                      await Future.sync(onSubmit);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    isScrollControlled: true,
    backgroundColor: transperant,
  );
}
