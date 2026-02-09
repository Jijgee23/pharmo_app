import 'package:pharmo_app/application/application.dart';

class DefInputContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final Function()? ontap;
  final double? width;
  const DefInputContainer(
      {super.key, required this.child, this.ontap, this.title, this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Column(
        children: [
          if (title != null) SmallText(title!),
          Container(
            margin: EdgeInsets.only(top: title != null ? 10 : 0),
            decoration: BoxDecoration(
              border: Border.all(color: context.theme.primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            width: width,
            padding: EdgeInsets.all(smallFontSize),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}
