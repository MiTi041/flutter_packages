import 'package:custom_widgets/custom_chart/heatmap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ShaderMask;
import 'package:flutter_test/flutter_test.dart';

Future<List<List<double>>> _load() async =>
    List.generate(7, (_) => List.filled(20, 1));

Future<List<List<double>>> _loadMany() async =>
    List.generate(7, (_) => List.filled(120, 1));

Future<List<List<double>>> _loadFew() async =>
    List.generate(7, (_) => List.filled(3, 1));

Future<List<List<double>>> _loadNewest() async {
  final data = List.generate(7, (_) => List.filled(20, 0.0));
  for (final row in data) {
    row[18] = 1;
    row[19] = 2;
  }
  return data;
}

void main() {
  testWidgets('heatmap scrolls horizontally with edge fade when narrow',
      (tester) async {
    tester.view.physicalSize = const Size(300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Heatmap(titel: 'Test', loadData: _load),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(ShaderMask), findsOneWidget);

    final controller = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .controller!;
    expect(controller.position.pixels, controller.position.minScrollExtent);
  });

  testWidgets('shows calendar weeks and sticky year header', (tester) async {
    tester.view.physicalSize = const Size(300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Heatmap(titel: 'Test', showWeekLabels: true, loadData: _load),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KW'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Text && RegExp(r'^\d{4}$').hasMatch(widget.data ?? '')),
      findsOneWidget,
    );
  });

  testWidgets('year header follows the scrolled weeks', (tester) async {
    tester.view.physicalSize = const Size(300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child:
              Heatmap(titel: 'Test', showWeekLabels: true, loadData: _loadMany),
        ),
      ),
    );
    await tester.pumpAndSettle();

    String visibleYear() => tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .firstWhere((data) => RegExp(r'^\d{4}$').hasMatch(data));

    final initialYear = visibleYear();
    final controller = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .controller!;
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();

    expect(visibleYear(), isNot(initialYear));
  });

  testWidgets('newest week is rendered on the right', (tester) async {
    tester.view.physicalSize = const Size(300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Heatmap(titel: 'Test', loadData: _loadNewest),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final newest = tester.getCenter(find.text('2.00'));
    final older = tester.getCenter(find.text('1.00'));
    expect(newest.dx, greaterThan(older.dx));

    final cell = tester.getSize(
      find
          .ancestor(of: find.text('2.00'), matching: find.byType(Container))
          .first,
    );
    expect(cell.width, cell.height);
  });

  testWidgets('pads short data with empty dummy columns', (tester) async {
    tester.view.physicalSize = const Size(300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Heatmap(titel: 'Test', loadData: _loadFew),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final controller = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .controller!;
    expect(controller.position.maxScrollExtent, 0);

    expect(
      find.byWidgetPredicate((widget) =>
          widget is SizedBox &&
          widget.width == 22 &&
          widget.height == 22 &&
          widget.child == null),
      findsWidgets,
    );

    final cell = tester.getSize(
      find
          .ancestor(of: find.text('1.00'), matching: find.byType(Container))
          .first,
    );
    expect(cell.width, 22);
    expect(cell.height, 22);
  });
}
