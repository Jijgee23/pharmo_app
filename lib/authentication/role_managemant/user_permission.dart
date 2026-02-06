// //
// enum Permission {
//   // Захиалгын эрхүүд
//   ordersView('orders.view', 'Захиалга харах'),
//   ordersCreate('orders.create', 'Захиалга үүсгэх'),
//   ordersUpdate('orders.update', 'Захиалга засах'),
//   ordersDelete('orders.delete', 'Захиалга устгах'),
//   ordersApprove('orders.approve', 'Захиалга баталгаажуулах'),

//   // Барааны эрхүүд
//   productsView('products.view', 'Бараа харах'),
//   productsManage('products.manage', 'Бараа удирдах'),
//   productsInventory('products.inventory', 'Бараа тоолох'),

//   // Тайлангийн эрхүүд
//   reportsView('reports.view', 'Тайлан харах'),
//   reportsExport('reports.export', 'Тайлан экспортлох'),
//   reportsAnalytics('reports.analytics', 'Аналитик харах'),

//   // Хэрэглэгчийн эрхүүд
//   usersView('users.view', 'Хэрэглэгч харах'),
//   usersManage('users.manage', 'Хэрэглэгч удирдах'),

//   // Тохиргооны эрхүүд
//   settingsView('settings.view', 'Тохиргоо харах'),
//   settingsManage('settings.manage', 'Тохиргоо засах'),

//   // Хүргэлтийн эрхүүд
//   deliveryManage('delivery.manage', 'Хүргэлт удирдах'),
//   deliveryTrack('delivery.track', 'Хүргэлт хянах');

//   final String code;
//   final String displayName;

//   const Permission(this.code, this.displayName);

//   static Permission? fromCode(String code) {
//     try {
//       return Permission.values.firstWhere((p) => p.code == code);
//     } catch (e) {
//       return null;
//     }
//   }
// }
