import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';

class Visits extends StatefulWidget {
  const Visits({super.key});

  @override
  State<Visits> createState() => _VisitsState();
}

class _VisitsState extends State<Visits> {
  @override
  Widget build(BuildContext context) {
    return DataScreen(
      appbar: CustomAppBar(
        leading: ChevronBack(),
      ),
      loading: false,
      empty: true,
      child: Column(
        children: [],
      ),
    );
  }
}
