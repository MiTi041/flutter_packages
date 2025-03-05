import 'dart:async';
import 'package:flutter/material.dart';
import 'package:custom_widgets/constants.dart';

class Textarea extends StatefulWidget {
  final String text;
  final String Function(String)? input;
  final bool maxHeight;
  final bool currency;
  final bool loader;
  final bool finished;
  final bool disabled;
  final String? value;
  final Constants? constants;

  const Textarea({
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
  TextareaState createState() => TextareaState();
}

class TextareaState extends State<Textarea> {
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
  void didUpdateWidget(covariant Textarea oldWidget) {
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
            onTapOutside: (value) {
              focusNode.unfocus();
              setState(() {
                isFocused = false;
              });
            },
            controller: controller,
            minLines: 5,
            maxLines: 10,
            focusNode: focusNode,
            onChanged: (value) {
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
              contentPadding: EdgeInsets.only(left: 15, top: widget.maxHeight ? 28 : 15, bottom: widget.maxHeight ? 28 : 15, right: 15),
              fillColor: isFocused ? constants.secondary : constants.primary,
              filled: true,
              counterText: '',
              labelText: widget.text,
              alignLabelWithHint: true,
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
        ],
      ),
    );
  }
}
