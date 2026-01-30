import 'package:flutter/material.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App logo/name
          Icon(
            Icons.medical_services_outlined,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Pharmo App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          // const SizedBox(height: 8),
          // Text(
          //   'Хувилбар 1.0.0',
          //   style: TextStyle(
          //     fontSize: 13,
          //     color: Colors.grey.shade600,
          //   ),
          // ),
          const SizedBox(height: 8),
          Text(
            '© 2024 Pharmo. Бүх эрх хуулиар хамгаалагдсан.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
