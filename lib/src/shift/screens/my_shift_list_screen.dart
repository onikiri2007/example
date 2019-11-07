import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/home/blocs/bottom_tab_controller/bloc.dart';
import 'package:yodel/src/routes.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class MyShiftListScreen extends StatefulWidget {
  const MyShiftListScreen({Key key}) : super(key: key);

  @override
  _MyShiftListScreenState createState() => _MyShiftListScreenState();
}

class _MyShiftListScreenState extends State<MyShiftListScreen>
    with PostBuildActionMixin, WidgetsBindingObserver {
  final AutoScrollController _scrollController = AutoScrollController(
    viewportBoundaryGetter: () => Rect.fromLTRB(0, -10, 0, 0),
  );
  bool _isCollapsed = false;
  BottomTabsBloc _tabsBloc;
  ShiftsSyncBloc _refresherBloc;
  MyShiftsBloc _bloc;
  StreamSubscription _tabSubscription;

  final CalendarModel _model = CalendarModel(
    minTime: DateTime.now().subtract(Duration(days: 14)),
    maxTime: DateTime.now().add(Duration(days: 180)),
  );
  Map<DateTime, bool> _pinned = {};

  final CalendarDateController _dateController =
      CalendarDateController(date: DateTimeHelper.getToday());

  @override
  void initState() {
    _refresherBloc = BlocProvider.of<ShiftsSyncBloc>(context);

    _bloc = BlocProvider.of<MyShiftsBloc>(context);

    _scrollController.addListener(_onScroll);
    _tabSubscription = _bloc.currentFilter.skip(1).listen((filter) {
      onWidgetDidBuild(() {
        _scrollController.scrollToIndex(_model.indexOf(_dateController.date),
            preferPosition: AutoScrollPosition.begin,
            duration: Duration(milliseconds: 1));
      });
    });

    _bloc.add(FetchMyShifts(
      autoScroll: true,
    ));
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabSubscription?.cancel();
    _tabSubscription = null;
    _scrollController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _tabsBloc = BlocProvider.of<BottomTabsBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _bloc.add(RefreshMyShifts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: YodelTheme.tealish,
      ),
      child: Scaffold(
        backgroundColor: YodelTheme.lightPaleGrey,
        body: BlocListener(
          bloc: _bloc,
          listener: (context, MyShiftsState state) {
            if (state is MyShiftsLoaded) {
              if (state.autoScroll) {
                onWidgetDidBuild(() {
                  _scrollController.scrollToIndex(
                      _model.indexOf(_dateController.date),
                      preferPosition: AutoScrollPosition.begin,
                      duration: Duration(milliseconds: 100));
                });
              }
            }

            if (state is MyShiftsError) {
              onWidgetDidBuild(() {
                var snackbar = SnackBar(
                  content: Container(
                    width: 220,
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      state.error,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "Try again",
                    textColor: YodelTheme.iris,
                    onPressed: () {
                      _bloc.add(FetchMyShifts(
                        autoScroll: true,
                      ));
                    },
                  ),
                );
                Scaffold.of(context).showSnackBar(snackbar);
              });
            }
          },
          child: BlocBuilder(
              bloc: _bloc,
              builder: (context, MyShiftsState state) {
                return StreamBuilder<MyShiftListFilterType>(
                  initialData: _bloc.currentFilter.value,
                  stream: _bloc.currentFilter,
                  builder: (context, snapshot) {
                    return StreamBuilder(
                      stream: _bloc.shifts,
                      builder: (context,
                          AsyncSnapshot<Map<DateTime, List<MyShift>>>
                              shiftsSnapshot) {
                        return DefaultTabController(
                          length: 3,
                          initialIndex: snapshot.data.index,
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _bloc.add(FetchMyShifts(
                                autoScroll: true,
                              ));
                            },
                            displacement: 20,
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: _buildSlivers(
                                context,
                                state,
                                shiftsSnapshot.hasData
                                    ? shiftsSnapshot.data
                                    : {},
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, MyShiftsState state,
      Map<DateTime, List<MyShift>> shifts) {
    List<Widget> slivers = [
      SliverAppBar(
        forceElevated: false,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: YodelTheme.darkGreyBlue,
        centerTitle: true,
        expandedHeight: kExpandedHeight,
        floating: false,
        pinned: true,
        leading: IconLinkButton(
          icon: Icon(YodelIcons.sites),
          color: YodelTheme.tealish,
          highlightColor: YodelTheme.tealish.withOpacity(0.8),
          disabledColor: YodelTheme.lightGreyBlue,
          onPressed: () {
            router.navigateTo(context, "/sites",
                transition: TransitionType.native);
          },
        ),
        actions: <Widget>[
          IconLinkButton(
            padding: EdgeInsets.all(16),
            icon: Icon(YodelIcons.refresh),
            color: YodelTheme.tealish,
            highlightColor: YodelTheme.tealish.withOpacity(0.8),
            disabledColor: YodelTheme.lightGreyBlue,
            onPressed: () {
              _bloc.add(FetchMyShifts(autoScroll: true));
            },
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: _isCollapsed ? true : false,
          titlePadding:
              !_isCollapsed ? EdgeInsets.symmetric(horizontal: 16) : null,
          title: _isCollapsed
              ? Text("My Shifts", style: YodelTheme.bodyWhite)
              : Text(
                  "My Shifts",
                  style: YodelTheme.mainTitle,
                ),
        ),
      ),
      SliverPersistentHeader(
        delegate: SliverTabBarDelegate(
          TabBar(
            indicatorColor: YodelTheme.tealish,
            labelPadding: EdgeInsets.only(top: 10),
            labelColor: Colors.white,
            indicatorWeight: 4.0,
            unselectedLabelColor: YodelTheme.lightGreyBlue,
            indicatorPadding:
                EdgeInsets.only(left: 9.0, right: 9.0, top: 0, bottom: 0),
            labelStyle: YodelTheme.tabFilterActive,
            unselectedLabelStyle: YodelTheme.tabFilterDefault,
            onTap: (id) {
              final filter = MyShiftListFilterType.values[id];
              _bloc.changeFilter(filter);
            },
            tabs: [
              Tab(
                text: "All Shifts",
              ),
              Tab(text: "Available"),
              Tab(text: "Approved"),
            ],
          ),
        ),
        pinned: true,
      ),
    ];

    if (state is MyShiftsLoaded || state is MyShiftsError) {
      final calendarMarkers = getMarkers(_model, shifts);

      slivers.add(SliverPersistentHeader(
        delegate: SliverCalendarDelegate(
          CalendarWidget(
            markers: calendarMarkers,
            selectedColor: YodelTheme.iris,
            calendarModel: _model,
            controller: _dateController,
            onDateSelected: (date) {
              final index = _model.dates.indexOf(date);
              _scrollController
                  .scrollToIndex(index,
                      duration: Duration(milliseconds: 250),
                      preferPosition: AutoScrollPosition.begin)
                  .then((_) {
                _dateController.disableAutoScrolling = false;
              });
            },
          ),
        ),
        pinned: true,
      ));
      int index = 0;
      final widgets = _model.dates.map((date) {
        final widget = _buildSliverBuilderLists(
            context, date, index, shifts.containsKey(date) ? shifts[date] : []);
        index++;
        return widget;
      });
      slivers.addAll(widgets);
    } else {
      slivers.add(SliverFillRemaining(
        child: LoadingIndicator(),
      ));
    }

    return slivers;
  }

  Widget _buildSliverBuilderLists(
      BuildContext context, DateTime date, int index, List<Shift> shifts) {
    return SliverStickyHeaderBuilder(
      builder: (context, state) => _buildAnimatedHeader(
          context,
          index,
          date,
          state,
          shifts.isNotEmpty
              ? EdgeInsets.only(bottom: 24)
              : EdgeInsets.only(bottom: 16)),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            return _buildShiftCard(i, shifts);
          },
          childCount: shifts.isEmpty ? 1 : shifts.length,
        ),
      ),
    );
  }

  Widget _buildShiftCard(int i, List<Shift> shifts) {
    EdgeInsets padding;
    final count = shifts.length;

    if (i == 0) {
      padding =
          const EdgeInsets.only(left: 16.0, right: 16, top: 0, bottom: 16);
    } else if (i == (count - 1)) {
      padding =
          const EdgeInsets.only(left: 16.0, right: 16, top: 0, bottom: 24);
    } else {
      padding =
          const EdgeInsets.only(left: 16.0, right: 16, top: 0, bottom: 16);
    }

    final shift = shifts.isNotEmpty ? shifts[i] : null;
    return MyShiftCard(
      padding: padding,
      shift: shift,
      onTap: shift != null
          ? () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<ShiftsSyncBloc>.value(
                      value: _refresherBloc,
                    ),
                    BlocProvider<MyShiftsBloc>.value(
                      value: _bloc,
                    ),
                  ],
                  child: MyShiftDetailsScreen(
                    shiftId: shift.id,
                    shift: shift,
                  ),
                ),
                fullscreenDialog: true,
              ));
            }
          : null,
    );
  }

  Widget _buildAnimatedHeader(BuildContext context, int index, DateTime date,
      SliverStickyHeaderState state, EdgeInsets margin) {
    if (state.isPinned) {
      _pinned.putIfAbsent(date, () => state.isPinned);
    } else {
      _pinned.remove(date);
    }

    String dateDescription;

    if (DateTimeHelper.isToday(date)) {
      dateDescription = "Today";
    } else if (DateTimeHelper.isTomorrow(date)) {
      dateDescription = "Tomorrow";
    } else if (DateTimeHelper.isYesterday(date)) {
      dateDescription = "Yesterday";
    }

    List<Widget> children = [
      if (dateDescription != null)
        Text(dateDescription, style: YodelTheme.metaStrong),
      Text(
        '${dateDescription != null ? " - " : ""}${DateFormat("EE, d MMMM").format(date)}',
        style: YodelTheme.metaRegular,
      ),
    ];

    return AutoScrollTag(
      key: ValueKey(index),
      controller: _scrollController,
      index: index,
      child: Container(
        height: 32.0,
        margin: margin,
        color: YodelTheme.paleGrey.withOpacity(1.0 - state.scrollPercentage),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          children: children,
        ),
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      _tabsBloc.add(ChangeVisibilityTab(
          isVisible: _scrollController.offset < kBottomTabBarAppearanceOffset));
    } else if (!_tabsBloc.state.isVisible) {
      _tabsBloc.add(ChangeVisibilityTab(isVisible: true));
    }
    setState(() {
      _isCollapsed = _scrollController.offset > kCollapseOffset;
    });

    _dateController.isAutoScrolling = _scrollController.isAutoScrolling;

    if (_pinned.length > 0 && !_dateController.disableAutoScrolling) {
      final date = _pinned.keys?.last;

      if (date != null) {
        _dateController.date = date;
      }
    }
  }
}
