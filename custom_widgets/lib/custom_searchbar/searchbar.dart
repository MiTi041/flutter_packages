import 'package:custom_widgets/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Searchbar extends StatefulWidget {
  final String placeholder;
  final void Function(String)? input;
  final bool onOpenFocus;
  final bool isLoading;
  final String? value;

  const Searchbar({required this.placeholder, this.onOpenFocus = false, this.input, this.isLoading = false, this.value, super.key});

  @override
  SearchbarState createState() => SearchbarState();
}

class SearchbarState extends State<Searchbar> {
  // Variables
  bool isFocused = false;
  String inputText = "";

  // Instances
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // Standard
  @override
  void initState() {
    super.initState();

    if (widget.value != null) {
      controller.text = widget.value!;
      inputText = widget.value!;
    }

    focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onOpenFocus && mounted) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Searchbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value && widget.value != null) {
      controller.text = widget.value!;
      setState(() {
        inputText = widget.value!;
      });
    }
  }

  // Functions
  void _onFocusChange() {
    if (isFocused != focusNode.hasFocus) {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    }
  }

  void _clear({bool keepFocus = true}) {
    controller.clear();
    widget.input?.call("");
    setState(() {
      inputText = "";
    });

    if (keepFocus) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 1,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: constants.blue,
                onTapOutside: (event) => focusNode.unfocus(),
                onChanged: (value) {
                  widget.input?.call(value);
                  setState(() {
                    inputText = value;
                  });
                },
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  height: 1.2,
                  fontFamily: constants.fontFamily,
                  fontSize: constants.mediumFontSize,
                  color: constants.fontColor,
                  fontWeight: constants.medium,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: constants.secondary,
                  counterText: '',
                  hintText: widget.placeholder,
                  hintMaxLines: 1,
                  hintStyle: TextStyle(
                    height: 1.5,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: constants.fontFamily,
                    fontSize: constants.regularFontSize,
                    color: constants.subFontColor,
                    fontWeight: constants.medium,
                  ),
                  contentPadding: const EdgeInsets.only(left: 35, top: 14, bottom: 14, right: 35),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: constants.blue, width: 1)),
                ),
              ),
              Positioned(left: 10, top: 10, bottom: 10, child: Icon(CupertinoIcons.search, color: constants.fontColor, size: 20)),
              if (inputText != "")
                Positioned(
                  right: 10,
                  top: 10,
                  bottom: 10,
                  child: widget.isLoading
                      ? CupertinoActivityIndicator(radius: 10, color: constants.fontColor)
                      : GestureDetector(
                          onTap: _clear,
                          child: Icon(CupertinoIcons.clear_thick_circled, color: constants.fontColor, size: 20),
                        ),
                ),
            ],
          ),
        ),

        // Abbrechen
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.centerRight,
          child: isFocused
              ? TextFieldTapRegion(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _clear(keepFocus: false),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 0, 10),
                      child: Text(
                        "Abbrechen",
                        maxLines: 1,
                        style: TextStyle(
                          height: 1,
                          fontFamily: constants.fontFamily,
                          fontSize: constants.mediumFontSize,
                          color: constants.subFontColor,
                          fontWeight: constants.medium,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
