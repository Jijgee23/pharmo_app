import 'package:pharmo_app/application/application.dart';

extension ContextX on BuildContext {
  Size get size => MediaQuery.of(this).size;
  double get width => MediaQuery.of(this).size.width;
  double get heigh => MediaQuery.of(this).size.height;
  ThemeData get theme => Theme.of(this);
  TextTheme get text => theme.textTheme;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;
}
