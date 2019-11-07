import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/api/models/authentication.dart';
import 'package:yodel/src/authentication/bloc/authentication_state.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/home/blocs/bottom_tab_controller/bloc.dart';
import 'package:yodel/src/home/blocs/push_notification/bloc.dart';
import 'package:yodel/src/home/models/models.dart';
import 'package:yodel/src/notifications/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/shift/screens/my_shift_details_screen.dart';
import 'package:yodel/src/theme/themes.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with PostBuildActionMixin {
  BottomTabsBloc _bloc;
  PushNotificationBloc _notificationBloc;
  MyShiftsBloc _myShiftsBloc;
  ManageShiftsBloc _manageShiftsBloc;
  bool shouldAskForNotification = true;

  @override
  void initState() {
    _bloc = BottomTabsBloc();
    _myShiftsBloc = MyShiftsBloc(
      refresherBloc: BlocProvider.of<ShiftsSyncBloc>(context),
    );
    _manageShiftsBloc = ManageShiftsBloc(
      refresherBloc: BlocProvider.of<ShiftsSyncBloc>(context),
    );
    _notificationBloc = PushNotificationBloc(
      authBloc: BlocProvider.of<AuthenticationBloc>(context),
    );

    super.initState();
  }

  @override
  void dispose() {
    _myShiftsBloc.close();
    _manageShiftsBloc.close();
    _bloc.close();
    _notificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onWidgetDidBuild(() async {
      if (shouldAskForNotification) {
        await Future.delayed(Duration(
          milliseconds: 500,
        ));

        _notificationBloc.add(InitializeNotification());
        shouldAskForNotification = false;
      }
    });

    return WillPopScope(
      onWillPop: () async {
        await sl<AppService>().minimise();
        return Future.value(false);
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BottomTabsBloc>.value(
            value: _bloc,
          ),
          BlocProvider<MyShiftsBloc>.value(
            value: _myShiftsBloc,
          ),
          BlocProvider<ManageShiftsBloc>.value(
            value: _manageShiftsBloc,
          ),
          BlocProvider<PushNotificationBloc>.value(
            value: _notificationBloc,
          ),
        ],
        child: BlocListener(
          bloc: _notificationBloc,
          listener: (context, PushNotificationState state) {
            if (state is PushNotificationShiftMessageRecieved) {
              Navigator.of(context).push(
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) {
                      final child = state.myShift
                          ? MyShiftDetailsScreen(
                              shiftId: state.shift.id,
                              shift: state.shift,
                            )
                          : ShiftDetailsScreen(
                              shiftId: state.shift.id,
                              shift: state.shift,
                            );

                      return MultiBlocProvider(
                        providers: [
                          BlocProvider<ManageShiftsBloc>.value(
                            value: _manageShiftsBloc,
                          ),
                          BlocProvider<MyShiftsBloc>.value(
                            value: _myShiftsBloc,
                          ),
                        ],
                        child: child,
                      );
                    }),
              );
            }
          },
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, authState) {
            final authenticationBloc =
                BlocProvider.of<AuthenticationBloc>(context);
            ;
            if (authState is! AuthenticationAuthenticated) {
              return LoadingIndicator();
            }

            final user =
                authenticationBloc.sessionTracker.currentSession.userData;

            return SafeArea(
              child: BlocBuilder<BottomTabsBloc, BottomTabControllerState>(
                builder: (context, state) {
                  final widgets = _getTabsByUser(user);
                  int index = 0;

                  final List<BottomNavigationBarItem> tabs =
                      BottomTabItems.getTabsByUser(user)
                          .map<BottomNavigationBarItem>((tab) {
                    final widget = BottomNavigationBarItem(
                      icon: Icon(
                        tab.icon,
                        color: YodelTheme.lightGreyBlue,
                        size: 20,
                      ),
                      activeIcon: Icon(
                        tab.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          tab.name,
                          style: state.currentTab == index
                              ? YodelTheme.metaRegularActiveWhite
                                  .copyWith(fontSize: 12)
                              : YodelTheme.metaRegularInactive
                                  .copyWith(fontSize: 12),
                        ),
                      ),
                      backgroundColor: YodelTheme.darkGreyBlue,
                    );
                    index++;
                    return widget;
                  }).toList();

                  return Scaffold(
                    backgroundColor: YodelTheme.darkGreyBlue,
                    bottomNavigationBar: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      height: state.isVisible ? kBottomNavigationBarHeight : 0,
                      child: SingleChildScrollView(
                        child: BottomNavigationBar(
                          currentIndex: state.currentTab,
                          backgroundColor: YodelTheme.darkGreyBlue,
                          type: BottomNavigationBarType.fixed,
                          onTap: (index) {
                            _bloc.add(ChangeTab(tab: index));
                          },
                          items: tabs,
                        ),
                      ),
                    ),
                    body: BlocBuilder<PushNotificationBloc,
                        PushNotificationState>(
                      builder: (context, notificationState) {
                        if (notificationState is PushNotificationLoading) {
                          return Container(
                            color: YodelTheme.lightPaleGrey,
                            child: LoadingIndicator(),
                          );
                        }

                        return IndexedStack(
                          index: state.currentTab,
                          children: widgets,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  List<Widget> _getTabsByUser(UserData userData) {
    return [
      if (userData.isManagementRole)
        ShiftListScreen(
          key: ValueKey<BottomTabItemType>(BottomTabItemType.Manage),
        ),
      MyShiftListScreen(
        key: ValueKey<BottomTabItemType>(BottomTabItemType.MyShifts),
      ),
      NotificationListScreen(
        key: ValueKey<BottomTabItemType>(BottomTabItemType.Notifications),
      ),
      ProfileScreen(
        key: ValueKey<BottomTabItemType>(BottomTabItemType.Profile),
      ),
    ];
  }
}
