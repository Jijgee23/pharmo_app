import 'package:flutter/material.dart';
// import 'package:pharmo_app/application/config/role_managemant/user_permission.dart';
import 'package:pharmo_app/views/DRIVER/index_driver.dart';
import 'package:pharmo_app/views/REPMAN/index.dart';
import 'package:pharmo_app/views/auth/login/login.dart';
import 'package:pharmo_app/views/index.dart';

enum UserRole {
  driver('D', 'Жолооч'),
  seller('S', 'Борлуулагч'),
  representative('R', 'Төлөөлөгч'),
  pharmacist('PA', 'Эмийн санч'),
  admin('A', 'Админ'),
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
}

class RoleConfig {
  /// Роль бүрийн эрхүүд
  // static const Map<UserRole, List<Permission>> rolePermissions = {
  //   UserRole.driver: [
  //     Permission.deliveryManage,
  //     Permission.deliveryTrack,
  //     Permission.ordersView,
  //     Permission.ordersUpdate,
  //   ],
  //   UserRole.representative: [
  //     Permission.ordersView,
  //     Permission.ordersCreate,
  //     Permission.ordersUpdate,
  //     Permission.productsView,
  //     Permission.reportsView,
  //   ],
  //   UserRole.pharmacist: [
  //     Permission.ordersView,
  //     Permission.ordersCreate,
  //     Permission.productsView,
  //     Permission.productsInventory,
  //     Permission.reportsView,
  //   ],
  //   UserRole.admin: [
  //     // Админ бүх эрхтэй
  //     ...Permission.values,
  //   ],
  // };

  // /// Роль эрхтэй эсэхийг шалгах
  // static bool hasPermission(UserRole role, Permission permission) {
  //   final permissions = rolePermissions[role] ?? [];
  //   return permissions.contains(permission);
  // }

  // /// Олон эрхтэй эсэхийг шалгах
  // static bool hasAllPermissions(UserRole role, List<Permission> permissions) {
  //   return permissions.every((p) => hasPermission(role, p));
  // }

  // /// Ямар нэг эрхтэй эсэхийг шалгах
  // static bool hasAnyPermission(UserRole role, List<Permission> permissions) {
  //   return permissions.any((p) => hasPermission(role, p));
  // }

  // /// Роль-ын эрхүүдийг авах
  // static List<Permission> getPermissions(UserRole role) {
  //   return rolePermissions[role] ?? [];
  // }

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
      case UserRole.admin:
        return IndexPharma();
      default:
        return LoginPage();
    }
  }
}
