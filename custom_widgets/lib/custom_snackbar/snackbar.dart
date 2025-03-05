import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:custom_widgets/custom_snackBar/snackBar_provider.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_button/button.dart';

/// SnackBarProvider().showSnackBar(context, status: SnackBarStatus.success, text: "Der Beitrag wurde kommentiert");

class CustomSnackbar extends StatefulWidget {
  final String text;
  final SnackBarStatus status;
  final Button? button;

  const CustomSnackbar({required this.text, this.status = SnackBarStatus.normal, this.button, super.key});

  @override
  CustomSnackbarState createState() => CustomSnackbarState();
}

class CustomSnackbarState extends State<CustomSnackbar> {
  final GlobalKey snackbarKey = GlobalKey();
  double height = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  void _updateHeight() {
    final renderBox = snackbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        height = renderBox.size.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final constants = Constants();
    final snackBarProvider = Provider.of<SnackBarProvider>(context, listen: true);

    final Color backgroundColor = _getBackgroundColor(widget.status);
    final Color lineColor = _getLineColor(widget.status);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 125),
      top: snackBarProvider.isSliding ? 0 : -height,
      left: 0,
      right: 0,
      child: Material(
        color: constants.background,
        child: GestureDetector(
          onHorizontalDragEnd: (_) => snackBarProvider.slideUpSnackBar(),
          child: Container(
            key: snackbarKey,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 20 + MediaQuery.of(context).padding.top, 20, 20),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(0), border: Border(bottom: BorderSide(color: lineColor, width: 1))),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_getIconPath(widget.status) != null) Row(children: [Image.asset(_getIconPath(widget.status)!, height: 30, width: 30), const Gap(10)]),
                    Expanded(child: Text(widget.text, style: TextStyle(fontFamily: constants.fontFamily, fontSize: constants.mediumFontSize, color: constants.fontColor, fontWeight: constants.semi))),
                    GestureDetector(
                      onTap: () => snackBarProvider.slideUpSnackBar(),
                      child: Container(
                        height: 30,
                        width: 30,
                        color: Colors.transparent,
                        child: Align(alignment: Alignment.centerRight, child: SizedBox(height: 12, child: Image.asset('${constants.imgPath}cross.png'))),
                      ),
                    ),
                  ],
                ),
                if (widget.button != null) Column(children: [const Gap(15), widget.button!]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(SnackBarStatus status) {
    final constants = Constants();
    switch (status) {
      case SnackBarStatus.success:
        return constants.green.withValues(alpha: 0.3);
      case SnackBarStatus.error:
        return constants.red.withValues(alpha: 0.3);
      case SnackBarStatus.warning:
        return constants.orange.withValues(alpha: 0.3);
      case SnackBarStatus.info:
        return constants.blue.withValues(alpha: 0.3);
      default:
        return constants.blue.withValues(alpha: 0.3);
    }
  }

  Color _getLineColor(SnackBarStatus status) {
    final constants = Constants();
    switch (status) {
      case SnackBarStatus.success:
        return constants.green;
      case SnackBarStatus.error:
        return constants.red;
      case SnackBarStatus.warning:
        return constants.orange;
      case SnackBarStatus.info:
        return constants.blue;
      default:
        return constants.blue;
    }
  }

  String? _getIconPath(SnackBarStatus status) {
    switch (status) {
      case SnackBarStatus.success:
        return 'assets/icons/checked.png';
      case SnackBarStatus.error:
        return 'assets/icons/error.png';
      case SnackBarStatus.warning:
        return 'assets/icons/notChecked.png';
      case SnackBarStatus.info:
        return 'assets/icons/info.png';
      default:
        return null;
    }
  }
}
