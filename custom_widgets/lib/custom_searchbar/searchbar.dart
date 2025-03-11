import 'package:custom_widgets/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Searchbar extends StatefulWidget {
  final String placeholder;
  final String Function(String)? input;
  final bool onOpenFocus;
  final bool isLoading;
  final String? value;

  const Searchbar({required this.placeholder, this.onOpenFocus = false, this.input, this.isLoading = false, this.value, super.key});

  @override
  SearchbarState createState() => SearchbarState();
}

class SearchbarState extends State<Searchbar> {
  // variablen
  bool isFocused = false;
  String inputText = "";

  // instanzen
  final controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // standart
  @override
  void initState() {
    super.initState();

    if (widget.value != null) {
      setState(() {
        controller.text = widget.value!;
        inputText = widget.value!;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onOpenFocus) {
        FocusScope.of(context).requestFocus(focusNode);
      }
      load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Searchbar oldWidget) {
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

  load() async {}

  //functions

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  isFocused = hasFocus;
                });
              },
              child: Stack(
                children: [
                  TextField(
                    onTapOutside: (event) {
                      focusNode.unfocus();
                    },
                    controller: controller,
                    minLines: 1,
                    maxLines: 1,
                    focusNode: focusNode,
                    onChanged: (value) {
                      if (widget.input != null) {
                        widget.input!(value);
                      }
                      setState(() {
                        inputText = value;
                      });
                    },
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.only(left: 35, top: 14, bottom: 14, right: 35),
                      fillColor: constants.secondary,
                      filled: true,
                      counterText: '',
                      labelText: widget.placeholder,
                      labelStyle: TextStyle(
                        height: 1,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: constants.fontFamily,
                        fontSize: constants.regularFontSize,
                        color: constants.subFontColor,
                        fontWeight: constants.medium,
                      ),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: constants.blue, width: 1)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      height: 1,
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                      overflow: TextOverflow.fade,
                      fontFamily: constants.fontFamily,
                      fontSize: constants.mediumFontSize,
                      color: constants.fontColor,
                      fontWeight: constants.medium,
                    ),
                  ),
                  Positioned(left: 10, top: 10, bottom: 10, child: SizedBox(height: 15, width: 15, child: Image.asset('${constants.imgPath}lupe.png'))),
                  if (inputText != "")
                    Positioned(
                      right: 10,
                      top: 10,
                      bottom: 10,
                      child: widget.isLoading
                          ? CupertinoActivityIndicator(radius: 10, color: constants.fontColor)
                          : GestureDetector(
                              onTap: () {
                                controller.text = "";
                                if (widget.input != null) {
                                  widget.input!("");
                                }
                                setState(() {
                                  inputText = "";
                                });
                                FocusScope.of(context).requestFocus(focusNode);
                              },
                              child: Icon(CupertinoIcons.xmark_circle_fill, color: constants.subFontColor, size: 20),
                            ),
                    ),
                ],
              ),
            ),
          ),
          if (isFocused)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                color: const Color.fromARGB(0, 0, 0, 0),
                child: Text(
                  "Abbrechen",
                  style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.mediumFontSize, color: constants.subFontColor, fontWeight: constants.medium),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
