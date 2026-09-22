import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/authentication/login/login.dart';
import 'package:pharmo_app/authentication/role_managemant/user_role.dart';
import 'package:pharmo_app/roles/driver/index_driver.dart';
import 'package:pharmo_app/roles/repman/index.dart';
import 'package:pharmo_app/roles/van_sales/van_sales_index.dart';
import 'package:pharmo_app/views/index.dart';

void main() {
  group('UserRole.fromCode', () {
    test('maps every known backend role code to its enum value', () {
      expect(UserRole.fromCode('D'), UserRole.driver);
      expect(UserRole.fromCode('S'), UserRole.seller);
      expect(UserRole.fromCode('R'), UserRole.representative);
      expect(UserRole.fromCode('PA'), UserRole.pharmacist);
      expect(UserRole.fromCode('A'), UserRole.admin);
      expect(UserRole.fromCode('VS'), UserRole.vanSales);
    });

    test('falls back to unknown for an unrecognized code', () {
      expect(UserRole.fromCode('nope'), UserRole.unknown);
    });
  });

  group('UserRole predicates', () {
    test('isVanSales is true only for the VS role', () {
      expect(UserRole.vanSales.isVanSales(), isTrue);
      expect(UserRole.driver.isVanSales(), isFalse);
      expect(UserRole.seller.isVanSales(), isFalse);
    });
  });

  group('RoleConfig.getDefaultRoute', () {
    test('returns the expected route per role', () {
      expect(RoleConfig.getDefaultRoute(UserRole.driver), '/driver');
      expect(RoleConfig.getDefaultRoute(UserRole.representative), '/representative');
      expect(RoleConfig.getDefaultRoute(UserRole.pharmacist), '/pharmacist');
      expect(RoleConfig.getDefaultRoute(UserRole.admin), '/admin');
      expect(RoleConfig.getDefaultRoute(UserRole.seller), '/saler');
      expect(RoleConfig.getDefaultRoute(UserRole.vanSales), '/van-sales');
      expect(RoleConfig.getDefaultRoute(UserRole.unknown), '/login');
    });
  });

  group('RoleConfig.getHomePage', () {
    test('returns the widget matching each role', () {
      expect(RoleConfig.getHomePage(UserRole.driver), isA<IndexDriver>());
      expect(RoleConfig.getHomePage(UserRole.representative), isA<IndexRep>());
      expect(RoleConfig.getHomePage(UserRole.pharmacist), isA<IndexPharma>());
      expect(RoleConfig.getHomePage(UserRole.seller), isA<IndexPharma>());
      expect(RoleConfig.getHomePage(UserRole.vanSales), isA<VanSalesIndex>());
      expect(RoleConfig.getHomePage(UserRole.unknown), isA<LoginPage>());
    });
  });
}
