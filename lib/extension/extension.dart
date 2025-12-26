import 'package:pharmo_app/controllers/a_controlller.dart';

extension ContextX on BuildContext {
  Size get size => MediaQuery.of(this).size;
  double get width => MediaQuery.of(this).size.width;
  double get heigh => MediaQuery.of(this).size.height;
  ThemeData get theme => Theme.of(this);
  TextTheme get text => theme.textTheme;
  BuildContext get appContext => this;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;
}
