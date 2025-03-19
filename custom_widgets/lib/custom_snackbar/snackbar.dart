import 'dart:async';
import 'package:custom_widgets/custom_snackbar/snackBarStatus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_button/button.dart';

class CustomSnackbar extends StatefulWidget {
  final String text;
  final SnackBarStatus status;
  final Button? button;
  final Function slideUpSnackBar;

  const CustomSnackbar({required this.slideUpSnackBar, required this.text, this.status = SnackBarStatus.normal, this.button, super.key});

  @override
  CustomSnackbarState createState() => CustomSnackbarState();
}

class CustomSnackbarState extends State<CustomSnackbar> {
  final GlobalKey snackbarKey = GlobalKey();
  double height = 100;
  Timer? timerStart;
  Timer? timerSlideUp;
  Timer? timerClose;
  bool isSliding = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    // Höhe des Snackbars nach der ersten Frame aktualisieren
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());

    // Start der Animation mit einer kurzen Verzögerung
    timerStart = Timer(const Duration(milliseconds: 50), () {
      setState(() {
        isSliding = true; // Starten der Aufwärtsbewegung
      });
    });

    // Nach 2 Sekunden die Snackbar wieder nach unten schieben und Callback auslösen
    timerSlideUp = Timer(const Duration(seconds: 3), () {
      setState(() {
        isSliding = false; // Starten der Aufwärtsbewegung
      });
      timerClose = Timer(const Duration(milliseconds: 150), () {
        widget.slideUpSnackBar();
      });
    });
  }

  void _updateHeight() {
    final renderBox = snackbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        height = renderBox.size.height;
      });
    }
  }

  void slideUpSnackBar() {
    setState(() {
      isSliding = false; // Starten der Aufwärtsbewegung
    });
    timerClose = Timer(const Duration(milliseconds: 200), () {
      widget.slideUpSnackBar();
    });
  }

  @override
  void dispose() {
    timerStart?.cancel();
    timerSlideUp?.cancel();
    timerClose?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final constants = Constants();

    final Color backgroundColor = _getBackgroundColor(widget.status);
    final Color lineColor = _getLineColor(widget.status);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      top: isSliding ? 0 : -height, // Top-Wert steuert die Position
      left: 0,
      right: 0,
      child: Material(
        color: constants.background,
        child: GestureDetector(
          onHorizontalDragEnd: (_) => slideUpSnackBar(),
          child: Container(
            key: snackbarKey,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top, 20, 20),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(0), border: Border(bottom: BorderSide(color: lineColor, width: 1))),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_getIconPath(widget.status) != null) Row(children: [Image.asset(_getIconPath(widget.status)!, height: 30, width: 30, package: 'custom_widgets'), const Gap(10)]),
                    Expanded(
                      child: Text(
                        widget.text,
                        style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.mediumFontSize, color: constants.fontColor, fontWeight: constants.semi),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => slideUpSnackBar(),
                      child: Container(
                        height: 30,
                        width: 30,
                        color: Colors.transparent,
                        child: Align(alignment: Alignment.centerRight, child: Icon(CupertinoIcons.xmark, color: constants.fontColor, size: 12)),
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
