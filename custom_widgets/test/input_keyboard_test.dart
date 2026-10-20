import 'package:custom_widgets/custom_input/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('textarea scrolls above the keyboard when focused', (tester) async {
    double keyboardHeight = 0;
    late StateSetter setKeyboard;
    final scrollController = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setKeyboard = setState;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewInsets: EdgeInsets.only(bottom: keyboardHeight),
              ),
              child: Material(
                child: SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        const SizedBox(height: 500),
                        Input(isTextArea: true, text: 'Notizen'),
                        const SizedBox(height: 400),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    setKeyboard(() => keyboardHeight = 300);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0));
  });
}
