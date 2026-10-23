import 'package:flutter/material.dart';
import 'package:pharmo_app/roles/driver/index_driver.dart';
import 'package:pharmo_app/roles/van_sales/van_sales_index.dart';
import 'package:pharmo_app/roles/repman/index.dart';
import 'package:pharmo_app/authentication/login/login.dart';
import 'package:pharmo_app/views/index.dart';

enum UserRole {
  driver('D', 'Жолооч'),
  seller('S', 'Борлуулагч'),
  representative('R', 'Төлөөлөгч'),
  pharmacist('PA', 'Эмийн санч'),
  admin('A', 'Админ'),
  vanSales('VS', 'Жолооч-Борлуулагч'),
  unknown('U', 'Тодорхойгүй');

  final String code;
  final String displayName;

  const UserRole(this.code, this.displayName);

  static UserRole fromCode(String code) {
    return UserRole.values.firstWhere(
      (role) => role.code == code,
      orElse: () => UserRole.unknown,
    );
  }

  bool isDriver() => this == UserRole.driver;
  bool isRepresentative() => this == UserRole.representative;
  bool isPharmacist() => this == UserRole.pharmacist;
  bool isAdmin() => this == UserRole.admin;
  bool isSaler() => this == UserRole.seller;
  bool isVanSales() => this == UserRole.vanSales;
  bool isUnknown() => this == UserRole.unknown;
}

class RoleConfig {
  static String getDefaultRoute(UserRole role) {
    switch (role) {
      case UserRole.driver:
        return '/driver';
      case UserRole.representative:
        return '/representative';
      case UserRole.pharmacist:
        return '/pharmacist';
      case UserRole.admin:
        return '/admin';
      case UserRole.seller:
        return '/saler';
      case UserRole.vanSales:
        return '/van-sales';
      default:
        return '/login';
    }
  }

  static Widget getHomePage(UserRole role) {
    switch (role) {
      case UserRole.driver:
        return IndexDriver();
      case UserRole.representative:
        return IndexRep();
      case UserRole.pharmacist:
        return IndexPharma();
      case UserRole.seller:
        return IndexPharma();
      case UserRole.vanSales:
        return VanSalesIndex();
      default:
        return LoginPage();
    }
  }
}
