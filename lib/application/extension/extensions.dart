import 'package:intl/intl.dart';

extension XDate on DateTime {
  String get yyyyMMdd => DateFormat('yyyy-MM-dd').format(this);
  String get hhMMss => DateFormat('HH:mm:ss').format(this);
  String get full => DateFormat('yyyy-MM-dd, HH:mm:ss').format(this);
  String get dateTime => DateFormat('yyyy-MM-dd HH:mm').format(this);
}

extension Xdouble on double {}

extension XString on String? {
  String? get mayNull => this ?? "";
}

// extension XWidget on Widget {
//   Widget get background ( Color color )=> ColoredBox(color: color, child: this); 
// }