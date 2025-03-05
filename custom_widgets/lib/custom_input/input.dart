import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:custom_widgets/constants.dart';

class Input extends StatefulWidget {
  final bool backgroundSecondary;
  final String text;
  final String Function(String)? input;
  final bool maxHeight;
  final bool currency;
  final bool loader;
  final bool finished;
  final bool disabled;
  final String? value;
  final Constants? constants;

  const Input({
    this.backgroundSecondary = false,
    required this.text,
    this.input,
    this.maxHeight = false,
    this.currency = false,
    this.loader = false,
    this.finished = false,
    this.disabled = false,
    this.value,
    this.constants,
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
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          isFocused = hasFocus;
        });
      },
      child: Stack(
        children: [
          TextField(
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
              contentPadding: EdgeInsets.only(left: widget.loader || widget.finished ? 35 : 15, top: widget.maxHeight ? 28 : 15, bottom: widget.maxHeight ? 28 : 17, right: 45),
              fillColor:
                  isFocused
                      ? widget.backgroundSecondary
                          ? constants.third
                          : constants.secondary
                      : widget.backgroundSecondary
                      ? constants.secondary
                      : constants.primary,
              filled: true,
              counterText: '',
              labelText: widget.text,
              labelStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontFamily: constants.fontFamily,
                fontSize: constants.regularFontSize,
                color: constants.subFontColor,
                fontWeight: constants.medium,
              ),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: constants.blue, width: 1)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
            ),
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              decoration: TextDecoration.none,
              decorationThickness: 0,
              overflow: TextOverflow.fade,
              fontFamily: constants.fontFamily,
              fontSize: constants.mediumFontSize,
              color: constants.fontColor,
              fontWeight: constants.medium,
            ),
          ),
          if (inputText != "" && !widget.backgroundSecondary)
            Positioned(
              right: 15,
              top: 15,
              bottom: 15,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(focusNode);
                  controller.text = "";
                  setState(() {
                    inputText = "";
                  });
                  if (widget.input != null) {
                    widget.input!("");
                  }
                },
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: constants.third, borderRadius: BorderRadius.circular(50)),
                        child: SizedBox(height: 10, width: 10, child: Image.asset('${constants.imgPath}cross.png')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          widget.loader
              ? Positioned(left: 15, top: 15, bottom: 15, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [SpinKitRing(lineWidth: 2.0, color: constants.fontColor, size: 15)])))
              : widget.finished
              ? Positioned(
                left: 15,
                top: 15,
                bottom: 15,
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [SizedBox(height: 15, width: 15, child: Image.asset('assets/icons/checked.png'))])),
              )
              : const SizedBox(),
        ],
      ),
    );
  }
}
