import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custom_widgets/constants.dart';

class Input extends StatefulWidget {
  final String text;
  final IconData? icon;
  final double? padding;
  final String Function(String)? input;
  final bool maxHeight;
  final bool currency;
  final bool loader;
  final bool finished;
  final bool disabled;
  final String? value;
  final Constants? constants;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final VoidCallback? click;

  const Input({
    required this.text,
    this.icon,
    this.padding,
    this.input,
    this.maxHeight = false,
    this.currency = false,
    this.loader = false,
    this.finished = false,
    this.disabled = false,
    this.value,
    this.constants,
    this.borderRadius = const BorderRadius.all(Radius.circular(9)),
    this.backgroundColor,
    this.click,
    super.key,
  });

  @override
  InputState createState() => InputState();
}

class InputState extends State<Input> {
  late Constants constants;
  bool isFocused = false;
  String inputText = "";
  final controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  Timer? _scrollTimer;
  double keyboardHeight = 0;

  @override
  void initState() {
    super.initState();

    if (widget.constants == null) {
      constants = Constants();
    } else {
      constants = widget.constants!;
    }

    if (widget.value != null) {
      controller.text = widget.value!;
      inputText = widget.value!;
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _startKeyboardCheckTimer();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewInsets = MediaQuery.of(context).viewInsets.bottom;
      keyboardHeight = viewInsets;
    });
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value != null) {
        setState(() {
          controller.text = widget.value!;
          inputText = widget.value!;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _startKeyboardCheckTimer() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final viewInsets = MediaQuery.of(context).viewInsets.bottom;
      if (viewInsets > 0) {
        if (viewInsets == keyboardHeight) {
          // Keyboard is fully expanded, perform scroll
          scrollToInput();
          _scrollTimer?.cancel();
        }
        keyboardHeight = viewInsets;
      } else {
        // Keyboard is not visible
        _scrollTimer?.cancel();
      }
    });
  }

  void scrollToInput() {
    final scrollable = Scrollable.of(context);
    final renderObject = context.findRenderObject();

    if (renderObject != null) {
      scrollable.position.ensureVisible(renderObject, alignment: 0.5, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.click != null) widget.click!();
      },
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            isFocused = hasFocus;
          });
        },
        child: Stack(
          children: [
            TextField(
              cursorColor: constants.fontColor,
              autocorrect: false,
              keyboardType: widget.currency ? const TextInputType.numberWithOptions(decimal: true) : null,
              onTapOutside: (value) {
                setState(() {
                  isFocused = false;
                });
                focusNode.unfocus();
              },
              controller: controller,
              minLines: 1,
              maxLines: 1,
              focusNode: focusNode,
              onChanged: (value) {
                if (widget.currency) {
                  String pricePart = value.replaceAll(RegExp(r'[^\d.,]'), '');

                  pricePart = pricePart.replaceAll(',', '.');

                  if (pricePart.contains('.')) {
                    List<String> parts = pricePart.split('.');
                    if (parts.length == 2) {
                      if (parts[1].length > 2) {
                        parts[1] = parts[1].substring(0, 2);
                      }
                    }
                    if (parts[0].length > 8) {
                      parts[0] = parts[0].substring(0, 8);
                    }
                    pricePart = "${parts[0]}.${parts[1]}";
                  } else {
                    if (pricePart.length > 8) {
                      pricePart = pricePart.substring(0, 8);
                    }
                  }

                  String finalPrice = pricePart;

                  controller.text = finalPrice;

                  value = finalPrice;
                }

                if (widget.input != null) {
                  widget.input!(value);
                }
                setState(() {
                  inputText = value;
                });
              },
              enabled: !widget.disabled,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(
                    left: widget.icon != null
                        ? widget.padding != null
                            ? widget.padding! + 22
                            : 35
                        : widget.padding ?? 15,
                    top: widget.maxHeight ? 28 : widget.padding ?? 10,
                    bottom: widget.maxHeight ? 28 : widget.padding ?? 10,
                    right: widget.loader || widget.finished
                        ? widget.padding != null
                            ? widget.padding! + 22
                            : 35
                        : widget.padding ?? 15),
                fillColor: widget.backgroundColor ?? constants.primary,
                filled: true,
                counterText: '',
                hintText: widget.text,
                hintStyle: TextStyle(
                  height: 1,
                  overflow: TextOverflow.ellipsis,
                  fontFamily: constants.fontFamily,
                  fontSize: constants.mediumFontSize,
                  color: constants.subFontColor,
                  fontWeight: constants.medium,
                ),
                //focusedBorder: OutlineInputBorder(borderRadius: widget.borderRadius, borderSide: BorderSide(color: constants.blue, width: 1)),
                border: OutlineInputBorder(borderRadius: widget.borderRadius, borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
              ),
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                decoration: TextDecoration.none,
                decorationThickness: 0,
                overflow: TextOverflow.fade,
                fontFamily: constants.fontFamily,
                fontSize: constants.semibigFontSize,
                color: constants.fontColor.withValues(alpha: widget.disabled ? 0.5 : 1),
                fontWeight: constants.semi,
              ),
            ),
            if (widget.icon != null) ...[
              Positioned(
                left: widget.padding ?? 10,
                top: widget.padding ?? 10,
                bottom: widget.padding ?? 10,
                child: Icon(widget.icon, size: 15, color: constants.fontColor),
              ),
            ],
            widget.loader
                ? Positioned(
                    right: widget.padding ?? 10,
                    top: widget.padding ?? 10,
                    bottom: widget.padding ?? 10,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoActivityIndicator(color: constants.fontColor, radius: 8.0),
                        ],
                      ),
                    ),
                  )
                : widget.finished
                    ? Positioned(
                        right: widget.padding ?? 10,
                        top: widget.padding ?? 10,
                        bottom: widget.padding ?? 10,
                        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [SizedBox(height: 15, width: 15, child: Image.asset('assets/icons/checked.png'))])),
                      )
                    : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
