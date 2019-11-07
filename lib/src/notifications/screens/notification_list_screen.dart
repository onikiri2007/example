import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/home/blocs/bottom_tab_controller/bloc.dart';
import 'package:yodel/src/notifications/bloc/bloc.dart';
import 'package:yodel/src/notifications/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

const double _kExpandedHeight = 80;
const double _kCollapableOffset = 50;

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key key}) : super(key: key);

  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  ScrollController _scrollController = ScrollController();

  bool _isCollapsed = false;
  NotificationsBloc _bloc;
  ShiftsSyncBloc _syncBloc;
  ManageShiftsBloc _manageShiftsBloc;
  MyShiftsBloc _myShiftsBloc;
  BottomTabsBloc _tabsBloc;
  AuthenticationBloc _authBloc;

  bool get isManagementRole =>
      _authBloc?.sessionTracker?.currentSession?.userData?.isManagementRole ??
      false;

  @override
  void initState() {
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    _bloc = NotificationsBloc(
      defaultFilter:
          isManagementRole ? NotificationType.Manage : NotificationType.MyShift,
    );
    _syncBloc = BlocProvider.of<ShiftsSyncBloc>(context);
    _manageShiftsBloc = BlocProvider.of<ManageShiftsBloc>(context);
    _myShiftsBloc = BlocProvider.of<MyShiftsBloc>(context);
    _tabsBloc = BlocProvider.of<BottomTabsBloc>(context);
    _bloc.add(FetchNotifications());

    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      PageStorageKey(0),
      if (isManagementRole) PageStorageKey(1),
    ];

    return BlocProvider<NotificationsBloc>.value(
      value: _bloc,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            _bloc.add(FetchNotifications());
          },
          displacement: 20,
          child: DefaultTabController(
            length: isManagementRole ? 2 : 1,
            initialIndex: 0,
            child: BlocBuilder(
                bloc: _bloc,
                builder: (context, NotificationsState state) {
                  return StreamBuilder<NotificationType>(
                      initialData: _bloc.currentFilter,
                      stream: _bloc.filter,
                      builder: (context, filtersnapshot) {
                        final index =
                            isManagementRole ? (filtersnapshot.data.index) : 0;

                        return StreamBuilder<
                                Map<DateTime, List<YodelNotification>>>(
                            stream: _bloc.notifications,
                            builder: (context, snapshot) {
                              return CustomScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                key: keys[index],
                                controller: _scrollController,
                                slivers: _buildSlivers(
                                  context,
                                  state,
                                  snapshot.hasData ? snapshot.data : {},
                                ),
                              );
                            });
                      });
                }),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, NotificationsState state,
      Map<DateTime, List<YodelNotification>> notifications) {
    int i = 0;
    List<Widget> slivers = [
      _buildAppBar(context),
      if (isManagementRole) _buildTabs(context),
      if (state is NotificationsLoading)
        SliverFillRemaining(
          child: MiniLoadingIndicator(),
        ),
      if (state is NotificationsLoaded)
        ...notifications.keys.map((d) {
          final widget = _buildSliverBuilderLists(
            context,
            d,
            i,
            notifications[d],
          );
          i++;
          return widget;
        })
    ];

    return slivers;
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      forceElevated: false,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: YodelTheme.darkGreyBlue,
      centerTitle: true,
      expandedHeight: _kExpandedHeight,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.all(16),
        title: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 240,
          ),
          child: _isCollapsed
              ? Text(
                  "Notifications",
                  style: YodelTheme.bodyWhite,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
        background: !_isCollapsed
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "Notifications",
                      maxLines: 1,
                      style: YodelTheme.mainTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  _buildTabs(BuildContext context) {
    return StreamBuilder<NotificationType>(
        initialData: _bloc.currentFilter,
        stream: _bloc.filter,
        builder: (context, snapshot) {
          final filter = snapshot.data;
          final indicatorColor = isManagementRole
              ? (filter == NotificationType.MyShift
                  ? YodelTheme.tealish
                  : YodelTheme.amber)
              : YodelTheme.tealish;

          return SliverPersistentHeader(
            delegate: SliverTabBarDelegate(
              TabBar(
                labelPadding: EdgeInsets.only(top: 10),
                labelColor: Colors.white,
                indicatorWeight: 4.0,
                indicatorColor: indicatorColor,
                unselectedLabelColor: YodelTheme.lightGreyBlue,
                indicatorPadding:
                    EdgeInsets.only(left: 9.0, right: 9.0, top: 0, bottom: 0),
                labelStyle: YodelTheme.tabFilterActive,
                unselectedLabelStyle: YodelTheme.tabFilterDefault,
                onTap: (id) {
                  final filterType = isManagementRole
                      ? (id == NotificationType.MyShift.index
                          ? NotificationType.MyShift
                          : NotificationType.Manage)
                      : NotificationType.MyShift;

                  _bloc.changeFilter(filterType);
                },
                tabs: [
                  if (isManagementRole)
                    Tab(
                      text: "Manage",
                    ),
                  Tab(text: "My Shifts"),
                ],
              ),
              key: ValueKey(filter.index),
            ),
            pinned: true,
          );
        });
  }

  Widget _buildSliverBuilderLists(BuildContext context, DateTime date,
      int index, List<YodelNotification> notifications) {
    return SliverStickyHeaderBuilder(
      builder: (context, state) =>
          _buildAnimatedHeader(context, index, date, state),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final notification = notifications[i];

            Color backgroundColor = Colors.white;

            if (!notification.isViewed) {
              backgroundColor = notification.isWorkerNotification
                  ? YodelTheme.tealish.withOpacity(0.08)
                  : YodelTheme.amber.withOpacity(0.08);
            }

            final child = NotificationItem(
              backgroundColor: backgroundColor,
              onTap: (notification) {
                _bloc.add(NotificationViewed(notification.id));
                final child = notification.isWorkerNotification
                    ? MyShiftDetailsScreen(
                        shiftId: notification.shiftId,
                      )
                    : ShiftDetailsScreen(
                        shiftId: notification.shiftId,
                      );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider<ShiftsSyncBloc>.value(
                          value: _syncBloc,
                        ),
                        BlocProvider<ManageShiftsBloc>.value(
                          value: _manageShiftsBloc,
                        ),
                        BlocProvider<MyShiftsBloc>.value(
                          value: _myShiftsBloc,
                        ),
                      ],
                      child: child,
                    ),
                    fullscreenDialog: true,
                  ),
                );
              },
              notification: notification,
            );

            if (i == notifications.length - 1) {
              return child;
            } else {
              return Column(
                children: <Widget>[child, Separator()],
              );
            }
          },
          childCount: notifications.length,
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context, int index, DateTime date,
      SliverStickyHeaderState state) {
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

    return Container(
      height: 32.0,
      color: YodelTheme.paleGrey.withOpacity(1.0 - state.scrollPercentage),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: children,
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
      _isCollapsed = _scrollController.offset > _kCollapableOffset;
    });
  }
}
