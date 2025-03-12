import 'dart:math';
import 'package:custom_widgets/custom_list/refresh_provider.dart';
import 'package:custom_utils/custom_supabaseHelper.dart';
import 'package:custom_widgets/custom_list/dateGrouper.dart';
import 'package:custom_widgets/custom_siteSelection/siteSelectionItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:custom_widgets/custom_frame/frame_provider.dart';
import 'package:custom_widgets/custom_emptyState/emptyState.dart';
import 'package:custom_widgets/custom_searchbar/searchbar.dart';
import 'package:custom_widgets/custom_siteSelection/siteSelection.dart';
import 'package:custom_widgets/custom_skeleton/skeleton.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_titel/titel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QueryInfo {
  final String table;
  final String? filterByColumn;
  final String orderByColumn;
  final bool ascending;
  final List<List<dynamic>>? where;

  QueryInfo({required this.table, this.filterByColumn, required this.orderByColumn, this.ascending = false, this.where});
}

class CustomListWidget {
  final int verticalItemCount;
  final Widget Function(int id) object;
  final int? skeletonHeight;
  final double skeletonBorderRadius;
  final SiteSelectionItem? siteSelectionItem;
  final List<Map<String, dynamic>>? ownDataList;
  final int? searchParamCount;
  final Widget? customSkeleton;
  final bool showNotTheSkeleton;
  final List<Widget>? emptyState;
  final String? dateColumnName;
  final int? showWidgetWithIdOnTop;
  final String? searchbarPlaceholder;
  final double spacing;
  final QueryInfo queryInfo;

  CustomListWidget({
    this.verticalItemCount = 1,
    required this.object,
    this.skeletonHeight,
    this.skeletonBorderRadius = 15,
    this.siteSelectionItem,
    this.ownDataList,
    this.searchParamCount,
    this.customSkeleton,
    this.showNotTheSkeleton = false,
    this.emptyState,
    this.dateColumnName,
    this.showWidgetWithIdOnTop,
    this.searchbarPlaceholder,
    this.spacing = 10,
    required this.queryInfo,
  });
}

class CustomList extends StatefulWidget {
  final bool showSearchbar;
  final List<CustomListWidget> widgets;
  final bool useRefreshProvider;
  final bool searchbarOnOpenFocus;
  final void Function(bool)? isSearching;
  final void Function(int)? changedOffset;

  const CustomList({this.showSearchbar = false, required this.widgets, this.useRefreshProvider = false, this.searchbarOnOpenFocus = false, this.isSearching, this.changedOffset, super.key});

  @override
  CustomListState createState() => CustomListState();
}

class CustomListState extends State<CustomList> with TickerProviderStateMixin, SupabaseHelper {
  List<List<Map<String, dynamic>?>> data = [];
  String searchbarValue = "";
  bool isLoading = true;
  List<SiteSelectionItem> siteSelectionItems = [];
  int siteSelectionItemsLength = 0;
  int sliderSelection = 0;
  late int n;
  late double spacing;
  late double itemWidth;
  bool isSearchbarLoading = false;
  final Map<int, GlobalKey> itemKeys = {};
  final Map<int, AnimationController> slideControllers = {};
  final Map<int, Animation<Offset>> slideAnimations = {};
  int? highlightedId;
  int? preSelectedIndex;
  int? showWidgetWithIdOnTop;
  int maxRows = 10;
  late int limit;
  int offset = 0;
  bool noMoreData = false;
  int alreadyLoadedResults = 0;
  late List<bool> isDataInitialized;
  bool loadMoreLoader = false;

  // Instances
  late final RefreshProvider refreshProvider;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    calculateContentConstraints();

    siteSelectionItems = widget.widgets.map((w) => w.siteSelectionItem).whereType<SiteSelectionItem>().toList();

    siteSelectionItemsLength = siteSelectionItems.isNotEmpty ? siteSelectionItems.length : 1;

    data = List.generate(siteSelectionItemsLength, (_) => []);
    isDataInitialized = List.generate(siteSelectionItemsLength, (_) => false);

    refreshProvider = Provider.of<RefreshProvider>(context, listen: false);
    if (widget.useRefreshProvider) refreshProvider.addListener(refreshProviderListener);

    // Check for 'showWidgetWithIdOnTop' and store index in preSelectedIndex
    for (int i = 0; i < widget.widgets.length; i++) {
      if (widget.widgets[i].showWidgetWithIdOnTop != null) {
        showWidgetWithIdOnTop = widget.widgets[i].showWidgetWithIdOnTop;
        preSelectedIndex = i;
        break;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  @override
  void dispose() {
    if (widget.useRefreshProvider) {
      refreshProvider.removeListener(refreshProviderListener);
    }
    slideControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      resetList();
    });
    await load();
  }

  void refreshProviderListener() {
    bool currentRefreshIndicator = !refreshProvider.needsRefresh;
    if (currentRefreshIndicator != refreshProvider.needsRefresh) {
      currentRefreshIndicator = refreshProvider.needsRefresh;
      refresh();
    }
  }

  Future<void> load({bool withoutLoading = false, bool isSearch = false, bool activateLoadMoreLoader = false}) async {
    if (!withoutLoading) isLoading = true;
    if (activateLoadMoreLoader) loadMoreLoader = true;
    setState(() {});

    if (sliderSelection < widget.widgets.length && !noMoreData) {
      CustomListWidget widgetConfig = widget.widgets[preSelectedIndex ?? sliderSelection];
      QueryInfo queryInfo = widgetConfig.queryInfo;

      List<String> searchParam = [];

      if (widgetConfig.searchParamCount != null) {
        for (int i = 0; i < widgetConfig.searchParamCount!; i++) {
          searchParam.add('$searchbarValue%');
          searchParam.add(searchbarValue);
        }
      }

      List<Map<String, dynamic>> results;

      // Falls es eine Datumsspalte gibt, füge sie der Selektion hinzu
      String selectString = 'id';
      if (widgetConfig.dateColumnName != null) {
        selectString = 'id, ${widgetConfig.dateColumnName}';
      }

      String filterColumn = queryInfo.filterByColumn!;

      // Anwendung der where-Bedingung
      var query = Supabase.instance.client.from(queryInfo.table).select(selectString);

      // Optionales where hinzufügen, falls vorhanden
      if (queryInfo.where != null) {
        for (var where in queryInfo.where!) {
          query = query.eq(where[0], where[1]);
        }
      }

      if (queryInfo.filterByColumn != null && searchbarValue.isNotEmpty) {
        // Anwendung der ilike-Bedingung für die Filterung
        query = query.ilike(filterColumn, '$searchbarValue%');
      }

      // Abfrage ausführen mit optionaler Sortierung und Paginierung
      results = await query
          .order(
            widgetConfig.dateColumnName != null ? widgetConfig.dateColumnName! : queryInfo.orderByColumn,
            ascending: queryInfo.ascending,
          )
          .range(offset, offset + limit - 1);

      // Wenn es eine Datumsspalte gibt, benenne sie um
      if (widgetConfig.dateColumnName != null) {
        results = results.map((item) {
          return {...item, 'date': item[widgetConfig.dateColumnName]};
        }).toList();
      }

      // Prüfen, ob noch Daten vorhanden sind
      if (results.isEmpty) {
        noMoreData = true;
        if (isSearch && isDataInitialized[sliderSelection]) {
          data[sliderSelection].clear();
        }
      } else {
        alreadyLoadedResults += results.length;

        if (offset == 0) {
          data[sliderSelection] = filterData(results, widgetConfig);
        } else {
          data[sliderSelection].addAll(filterData(results, widgetConfig));
        }

        data[sliderSelection] = deleteDuplicates(data[sliderSelection]);
        preSelectedIndex = null;

        offset += limit;

        if (widget.changedOffset != null) {
          widget.changedOffset!(offset);
        }
      }

      isLoading = false;
      loadMoreLoader = false;
    } else {
      isLoading = false;
      loadMoreLoader = false;
    }

    isDataInitialized[sliderSelection] = true;
    setState(() {});
  }

  List<Map<String, dynamic>?> deleteDuplicates(List<Map<String, dynamic>?> results) {
    Set<dynamic> seen = <dynamic>{};
    results.retainWhere((item) {
      if (item == null) return false;
      final id = item.values.first;
      if (seen.contains(id)) {
        return false;
      } else {
        seen.add(id);
        return true;
      }
    });

    return results;
  }

  List<Map<String, dynamic>> filterData(List<Map<String, dynamic>> results, CustomListWidget widgetConfig) {
    if (showWidgetWithIdOnTop != null) {
      final index = results.indexWhere((item) => item.values.first == showWidgetWithIdOnTop);

      if (index != -1) {
        // Remove the item from its current position
        final item = results.removeAt(index);

        // Insert the item at the beginning of the list
        results.insert(0, item);

        highlightedId = showWidgetWithIdOnTop;
        // Damit es nur einmal gehighlighted wird
        showWidgetWithIdOnTop = null;
      }
    }

    // Sortiere und gruppiere nach Datum, wenn `dateColumnName` true ist
    if (widgetConfig.dateColumnName != null) {
      results.sort((a, b) {
        final dateA = a['date'] != null ? (a['date'] is DateTime ? a['date'] as DateTime : DateTime.tryParse(a['date'] as String) ?? DateTime(1970)) : DateTime(1970); // Standarddatum für null-Werte

        final dateB = b['date'] != null ? (b['date'] is DateTime ? b['date'] as DateTime : DateTime.tryParse(b['date'] as String) ?? DateTime(1970)) : DateTime(1970); // Standarddatum für null-Werte

        return dateB.compareTo(dateA);
      });
      Map<String, List<Map<String, dynamic>>> groupedResults = DateGrouper.groupByDate(results);
      results.clear();
      groupedResults.forEach((key, value) {
        results.addAll(value);
      });
    }

    return results;
  }

  void scrollToWidgetWithId(int id) async {
    double padding = FrameProvider().appbarHeight + 15;

    if (itemKeys.containsKey(id)) {
      final context = itemKeys[id]?.currentContext;
      if (context != null) {
        final scrollableState = Scrollable.of(context);
        final position = scrollableState.position;

        // Berechne den Offset des Widgets
        final renderBox = context.findRenderObject() as RenderBox;
        final widgetOffset = renderBox.localToGlobal(Offset.zero);
        final widgetHeight = renderBox.size.height;

        // Sichtbare Scroll-Grenzen (von Pixel oben und unten)
        final viewPortStart = position.pixels;
        final viewPortEnd = viewPortStart + position.viewportDimension;

        // Widget-Grenzen (oben und unten) relativ zur Scroll-Position
        final widgetTop = widgetOffset.dy + position.pixels;
        final widgetBottom = widgetTop + widgetHeight;

        // Überprüfe, ob das Widget teilweise oder vollständig außerhalb des sichtbaren Bereichs liegt
        if (widgetTop < viewPortStart || widgetBottom > viewPortEnd) {
          // Berechne den Scroll-Offset mit Padding
          final scrollOffset = widgetTop - padding;

          // Scrolle zur berechneten Position mit zusätzlichem Padding
          position.animateTo(scrollOffset, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
        }
      }
    }
  }

  void calculateContentConstraints() {
    n = widget.widgets[sliderSelection].verticalItemCount;

    // Calculate the number of items loaded at once
    maxRows = n * maxRows;
    limit = maxRows;

    spacing = widget.widgets[sliderSelection].spacing;
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    itemWidth = (size.width - 30 - (spacing * (n - 1))) / n;
  }

  void search(String value) async {
    if (widget.isSearching != null) {
      widget.isSearching!(value.isNotEmpty);
    }
    setState(() {
      searchbarValue = value;
      isSearchbarLoading = true;
    });

    resetList();

    await load(withoutLoading: true, isSearch: true);

    setState(() {
      isSearchbarLoading = false;
    });
  }

  void select(int value) async {
    setState(() {
      sliderSelection = value;
    });

    resetList();

    calculateContentConstraints();

    load(withoutLoading: true, isSearch: searchbarValue.isNotEmpty);
  }

  Future<void> removeItemWithId(int id) async {
    if (sliderSelection < data.length) {
      if (!slideControllers.containsKey(id)) {
        slideControllers[id] = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
        slideAnimations[id] = Tween<Offset>(begin: Offset.zero, end: const Offset(-2, 0)).animate(CurvedAnimation(parent: slideControllers[id]!, curve: Curves.easeInOut));
      }

      // Start the slide animation
      await slideControllers[id]!.forward();

      data[sliderSelection] = data[sliderSelection].where((item) => item?.values.first != id).toList();
      itemKeys.remove(id);
      slideControllers.remove(id);
      slideAnimations.remove(id);
      setState(() {});
    }
  }

  Future<void> addItemWithId(int id) async {
    CustomListWidget widgetConfig = widget.widgets[preSelectedIndex ?? sliderSelection];
    QueryInfo queryInfo = widgetConfig.queryInfo;

    // Um das Item nicht bei den Suchergebnissen einzufügen
    if (searchbarValue.isNotEmpty) {
      setState(() {
        searchbarValue = "";
      });
      resetList();
      await load(withoutLoading: true);
    }

    String selectString = 'id';
    if (widgetConfig.dateColumnName != null) {
      selectString = 'id, ${widgetConfig.dateColumnName}';
    }

    List<Map<String, dynamic>> result = await supabase.from(queryInfo.table).select(selectString).eq('id', id);

    if (result.isNotEmpty) {
      setState(() {
        if (widgetConfig.dateColumnName != null) {
          data[sliderSelection].insert(0, {...result[0], 'id': id, 'date': result[0][widgetConfig.dateColumnName]});
        } else {
          data[sliderSelection].insert(0, {...result[0], 'id': id});
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        scrollToWidgetWithId(id);
      });
    }
  }

  Widget insertDataIntoWidget(Function(int) widgetBuilder, Map<String, dynamic>? item) {
    if (item == null) {
      return Container();
    }

    int id = item.values.first as int;
    bool isHighlighted = id == highlightedId;

    // Wenn hervorgehoben, setze Debouncer für das Zurücksetzen
    if (isHighlighted) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        setState(() {
          highlightedId = null;
        });
      });
    }

    // Initialisiere AnimationController und Animation, falls noch nicht vorhanden
    if (!slideControllers.containsKey(id)) {
      slideControllers[id] = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
      slideAnimations[id] = Tween<Offset>(begin: Offset.zero, end: const Offset(-2, 0)).animate(CurvedAnimation(parent: slideControllers[id]!, curve: Curves.easeInOut));
    }

    final slideAnimation = slideAnimations[id]!;

    // Überprüfen, ob die ID bereits existiert
    if (!itemKeys.containsKey(id)) {
      itemKeys[id] = GlobalKey();
    }

    return SlideTransition(
      position: slideAnimation,
      child: FadeIn(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.all(isHighlighted ? 10 : 0),
          decoration: BoxDecoration(
            border: isHighlighted ? Border.all(strokeAlign: BorderSide.strokeAlignOutside, color: Constants().blue, width: 1.0) : null,
            borderRadius: BorderRadius.circular(15),
          ),
          width: itemWidth,
          key: itemKeys[id],
          child: widgetBuilder(id),
        ),
      ),
    );
  }

  bool doesWidgetExist(GlobalKey? key) {
    if (key == null) return false;

    final context = key.currentContext;

    // Prüft, ob der context und das RenderObject des Widgets existieren
    return context != null && context.findRenderObject() != null;
  }

  void sortAndGroupByDate() {
    if (widget.widgets[sliderSelection].dateColumnName != null) {
      Map<String, List<Map<String, dynamic>>> groupedData = DateGrouper.groupByDate(data[sliderSelection]);
      data[sliderSelection] = groupedData.values.expand((list) => list).toList();
    }
  }

  Future<void> resetList() async {
    offset = 0;
    noMoreData = false;
    alreadyLoadedResults = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.widgets[sliderSelection].dateColumnName != null) {
      sortAndGroupByDate();
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          if (widget.showSearchbar)
            Searchbar(
              value: searchbarValue,
              isLoading: isSearchbarLoading,
              onOpenFocus: widget.searchbarOnOpenFocus,
              placeholder: widget.widgets[sliderSelection].searchbarPlaceholder ?? 'Suchen',
              input: (String value) {
                search(value);
                return value;
              },
            ),
          if (siteSelectionItems.length > 1) ...[
            const Gap(10),
            SiteSelection(
              preSelectedIndex: preSelectedIndex,
              items: siteSelectionItems,
              select: (int value) async {
                select(value);
                return true;
              },
            ),
          ],
          const Gap(15),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: spacing,
              runSpacing: spacing,
              children: [
                if (isLoading || !isDataInitialized[sliderSelection])
                  if (!widget.widgets[sliderSelection].showNotTheSkeleton)
                    ...List.generate(
                      n * 5,
                      (_) => SizedBox(
                        width: itemWidth,
                        child: FadeIn(
                          child: widget.widgets[sliderSelection].customSkeleton ??
                              Skeleton(
                                borderRadius: widget.widgets[sliderSelection].skeletonBorderRadius,
                                height: (widget.widgets[sliderSelection].skeletonHeight ?? Random().nextInt(100) + 200).toDouble(),
                              ),
                        ),
                      ),
                    ),
                if (!isLoading && isDataInitialized[sliderSelection])
                  if (searchbarValue.isEmpty && widget.widgets[sliderSelection].ownDataList != null)
                    if (widget.widgets[sliderSelection].ownDataList!.isNotEmpty)
                      ...widget.widgets[sliderSelection].ownDataList!.map((item) => insertDataIntoWidget(widget.widgets[sliderSelection].object, item))
                    else
                      buildEmptyState(context, isDataInitialized[sliderSelection])
                  else if (data[sliderSelection].isNotEmpty)
                    ...buildList(context)
                  else
                    buildEmptyState(context, isDataInitialized[sliderSelection]),
                if (loadMoreLoader)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildList(BuildContext context) {
    if (widget.widgets[sliderSelection].dateColumnName != null) {
      return DateGrouper.groupByDate(data[sliderSelection])
          .entries
          .expand(
            (entry) => [
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Titel(text: entry.key, count: entry.value.length),
              ), // "Heute", "Gestern", etc.
              ...entry.value.map((item) => insertDataIntoWidget(widget.widgets[sliderSelection].object, item)),
            ],
          )
          .toList();
    } else {
      if (data[sliderSelection].isNotEmpty) {
        return data[sliderSelection].map((item) {
          return insertDataIntoWidget(widget.widgets[sliderSelection].object, item);
        }).toList();
      } else {
        return [buildEmptyState(context, isDataInitialized[sliderSelection])];
      }
    }
  }

  Widget buildEmptyState(BuildContext context, bool isDataInitialized) {
    return Column(
      children: searchbarValue.isNotEmpty
          ? [
              EmptyState(
                illustration: const Text('🔍', textAlign: TextAlign.center, style: TextStyle(fontSize: 50)),
                title: "Keine Suchergebnisse für '$searchbarValue'",
                text: "Überprüfe die Schreibweise",
              ),
            ]
          : widget.widgets[sliderSelection].emptyState ?? [EmptyState(illustration: Text('🕳️', textAlign: TextAlign.center, style: TextStyle(fontSize: 50)), title: "Keine Ergebnisse vorhanden")],
    );
  }
}
