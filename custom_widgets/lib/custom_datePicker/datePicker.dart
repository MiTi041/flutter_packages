import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:custom_widgets/custom_button/button.dart';
import 'package:custom_widgets/custom_modalPopup/modalPopup.dart';
import 'package:custom_widgets/constants.dart';

class DatePicker extends StatefulWidget {
  final String title;
  final String preSelected;
  final ValueChanged<DateTime?>? onDateSelected;
  final bool maximumExists;
  final bool minimumExists;

  const DatePicker({required this.title, required this.preSelected, this.onDateSelected, this.maximumExists = false, this.minimumExists = false, super.key});

  @override
  DatePickerState createState() => DatePickerState();
}

class DatePickerState extends State<DatePicker> {
  // Variables
  DateTime? selectedDate;

  // Instances

  // Standard
  @override
  void initState() {
    super.initState();

    selectedDate = DateFormat('dd.MM.yyyy').parse(widget.preSelected);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {}

  // Functions

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return GestureDetector(
      onTap: () {
        CustomModalPopup().show(
          context,
          "Datum",
          Column(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: CupertinoTheme(
                  data: CupertinoThemeData(brightness: Brightness.dark),
                  child: CupertinoDatePicker(
                    backgroundColor: constants.background,
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: widget.minimumExists ? DateTime.now().add(const Duration(seconds: 1)) : selectedDate ?? DateTime.now(),
                    maximumDate: widget.maximumExists ? DateTime.now() : null,
                    minimumDate: widget.minimumExists ? DateTime.now() : DateTime(1900),
                    maximumYear: widget.maximumExists ? DateTime.now().year : null,
                    use24hFormat: true,
                    onDateTimeChanged: (val) {
                      setState(() {
                        selectedDate = val;
                      });
                      if (widget.onDateSelected != null) {
                        widget.onDateSelected!(val);
                      }
                    },
                  ),
                ),
              ),
              const Gap(15),
              Button(
                text: 'Datum wählen',
                color: constants.blue,
                click: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(color: constants.primary, border: Border.all(color: constants.secondary, width: 1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    softWrap: true,
                    maxLines: null,
                    style: TextStyle(
                      height: 1,
                      fontFamily: constants.fontFamily,
                      fontSize: constants.regularFontSize,
                      color: constants.subFontColor,
                      fontWeight: constants.medium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    selectedDate == null ? widget.preSelected : DateFormat('dd.MM.yyyy').format(selectedDate!),
                    softWrap: true,
                    maxLines: null,
                    style: TextStyle(
                      height: 1,
                      fontFamily: constants.fontFamily,
                      fontSize: constants.semibigFontSize,
                      color: constants.fontColor,
                      fontWeight: constants.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
