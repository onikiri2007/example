import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/common/models/recase.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class CreateShiftStep4Screen extends StatefulWidget {
  @override
  _CreateShiftStep4ScreenState createState() => _CreateShiftStep4ScreenState();
}

class _CreateShiftStep4ScreenState extends State<CreateShiftStep4Screen>
    with PostBuildActionMixin, OpenUrlMixin {
  int _tabId = 0;
  bool _isCollapsed = false;
  CreateShiftBloc _bloc;
  ScrollController _scrollController = ScrollController();
  CreateShiftActionState actionState;

  @override
  void initState() {
    _bloc = BlocProvider.of<CreateShiftBloc>(context);
    actionState = _bloc.state;
    _scrollController.addListener(() {
      setState(() {
        _isCollapsed = _scrollController.offset > 10;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _bloc.add(CreateShiftMoveToStepFromReview(
          step: 3,
          approvalDetails: actionState.approvalDetails,
          eligibleWorkers: actionState.eligibleWorkers,
          peopleDetails: actionState.peopleDetails,
          shiftDetails: actionState.shiftDetails,
        ));

        Navigator.pop(context);
        return false;
      },
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: YodelTheme.lightPaleGrey,
          body: DefaultTabController(
            length: 3,
            initialIndex: _tabId,
            child: BlocListener(
              bloc: _bloc,
              listener: (context, state) {
                if (state is CreateShiftError) {
                  _bloc.add(ResetCreateShift(
                    approvalDetails: actionState.approvalDetails,
                    eligibleWorkers: actionState.eligibleWorkers,
                    peopleDetails: actionState.peopleDetails,
                    shiftDetails: actionState.shiftDetails,
                  ));
                  showErrorOnPostBuild(context,
                      "Failed to create a shift because ${state.error}.");
                }

                if (state is CreateShiftSuccess) {
                  showSuccessOnPostBuild(
                      context, "Shift has been successfully created.",
                      callback: () {
                    Navigator.popUntil(context, ModalRoute.withName("/home"));
                  });
                }
              },
              child: Stack(
                children: <Widget>[
                  NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return _buildSlivers(
                            context, actionState, innerBoxIsScrolled);
                      },
                      body: TabBarView(
                        children: <Widget>[
                          SafeArea(
                            top: false,
                            bottom: false,
                            child: Builder(builder: (context) {
                              return CustomScrollView(
                                key: PageStorageKey<String>("General"),
                                slivers: <Widget>[
                                  SliverOverlapInjector(
                                    // This is the flip side of the SliverOverlapAbsorber above.
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                            context),
                                  ),
                                  _GeneralDetailsView(state: actionState),
                                ],
                              );
                            }),
                          ),
                          SafeArea(
                            top: false,
                            bottom: false,
                            child: Builder(builder: (context) {
                              return CustomScrollView(
                                key: PageStorageKey<String>("Skills"),
                                slivers: <Widget>[
                                  SliverOverlapInjector(
                                    // This is the flip side of the SliverOverlapAbsorber above.
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                            context),
                                  ),
                                  _SkillsDetailsView(state: actionState),
                                ],
                              );
                            }),
                          ),
                          SafeArea(
                            top: false,
                            bottom: false,
                            child: Builder(builder: (context) {
                              return CustomScrollView(
                                key: PageStorageKey<String>("Others"),
                                slivers: <Widget>[
                                  SliverOverlapInjector(
                                    // This is the flip side of the SliverOverlapAbsorber above.
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                            context),
                                  ),
                                  _OtherDetailsView(state: actionState)
                                ],
                              );
                            }),
                          ),
                        ],
                      )),
                  Positioned(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    bottom: 0,
                    child: BlocBuilder(
                      bloc: _bloc,
                      builder: (context, CreateShiftState state) {
                        final eligibleWorkerText = Intl.plural(
                          actionState.eligibleWorkers,
                          zero: "employee",
                          one: "employee",
                          other: "employees",
                        );

                        List<Widget> children = [
                          Text(
                              "${actionState.eligibleWorkers} eligible $eligibleWorkerText",
                              style: YodelTheme.metaWhite),
                          SizedBox(
                            height: 8,
                          ),
                          ProgressButton(
                            child: Text("Create New Shift",
                                style: YodelTheme.bodyStrong),
                            color: YodelTheme.amber,
                            isLoading: state is CreateShiftLoading,
                            width: double.infinity,
                            onPressed: state is CreateShiftSuccess
                                ? null
                                : () {
                                    _bloc.add(CreateShift(
                                      approvalDetails:
                                          actionState.approvalDetails,
                                      eligibleWorkers:
                                          actionState.eligibleWorkers,
                                      peopleDetails: actionState.peopleDetails,
                                      shiftDetails: actionState.shiftDetails,
                                    ));
                                  },
                          )
                        ];

                        return Container(
                          height: 120,
                          color: YodelTheme.darkGreyBlue,
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: children,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, CreateShiftActionState state,
      bool innerBoxIsScrolled) {
    List<Widget> slivers = [
      BlocBuilder(
          bloc: _bloc,
          builder: (context, CreateShiftState state1) {
            bool isLoading = state1 is CreateShiftLoading;

            return SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              child: SliverAppBar(
                forceElevated: innerBoxIsScrolled,
                elevation: 0.0,
                automaticallyImplyLeading: false,
                backgroundColor: YodelTheme.darkGreyBlue,
                centerTitle: true,
                expandedHeight: kExpandedHeight,
                floating: false,
                pinned: true,
                leading: NavbarButton(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Edit",
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          _bloc.add(CreateShiftMoveToStepFromReview(
                            step: 3,
                            approvalDetails: actionState.approvalDetails,
                            eligibleWorkers: actionState.eligibleWorkers,
                            peopleDetails: actionState.peopleDetails,
                            shiftDetails: actionState.shiftDetails,
                          ));
                          Navigator.pop(context);
                        },
                ),
                actions: <Widget>[
                  NavbarButton(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      "Cancel",
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final ok = await showConfirmDialog(context,
                                title: "Are you sure you want to cancel?");

                            if (ok) {
                              Navigator.popUntil(
                                  context, ModalRoute.withName("/home"));
                            }
                          },
                  ),
                ],
                title: _isCollapsed
                    ? Text("Review Shifts Details", style: YodelTheme.bodyWhite)
                    : null,
                flexibleSpace: !_isCollapsed
                    ? FlexibleSpaceBar(
                        background: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Review Shifts Details",
                                    style: YodelTheme.mainTitle),
                                Text(
                                  state.shiftDetails.name,
                                  style: YodelTheme.metaWhite,
                                ),
                                Container(
                                  height: 5,
                                )
                              ],
                            )))
                    : null,
                bottom: TabBar(
                  labelPadding: EdgeInsets.only(top: 20),
                  labelColor: Colors.white,
                  indicatorWeight: 4.0,
                  unselectedLabelColor: YodelTheme.lightGreyBlue,
                  indicatorPadding:
                      EdgeInsets.only(left: 9.0, right: 9.0, top: 0, bottom: 0),
                  labelStyle: YodelTheme.tabFilterActive,
                  unselectedLabelStyle: YodelTheme.tabFilterDefault,
                  tabs: [
                    Tab(
                      text: "General",
                    ),
                    Tab(text: "Skills"),
                    Tab(text: "Other"),
                  ],
                ),
              ),
            );
          }),
    ];

    return slivers;
  }
}

class _GeneralDetailsView extends StatelessWidget with OpenUrlMixin {
  final CreateShiftActionState state;
  _GeneralDetailsView({
    Key key,
    @required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime start =
        DateTimeHelper.toDateOnly(state.shiftDetails.startDate);
    final DateTime end = DateTimeHelper.toDateOnly(state.shiftDetails.endDate);
    String date;
    final format = DateFormat("EE d MMM yyyy");
    final timeFormat = DateFormat("h:mm a");
    if (start == end) {
      date = "${format.format(start)}";
    } else {
      date = "${format.format(start)} - ${format.format(end)}";
    }

    final String time =
        "${timeFormat.format(state.shiftDetails.startDate).toLowerCase()} - ${timeFormat.format(state.shiftDetails.endDate).toLowerCase()}";
    final headCount = state.peopleDetails.noOfPeople;

    final headCountText = Intl.plural(
      headCount,
      zero: "employee",
      one: "employee",
      other: "employees",
    );

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            title: Text("Shift date", style: YodelTheme.metaRegularInactive),
            subtitle: Text(date, style: YodelTheme.bodyDefault),
          ),
          Separator(),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            title:
                Text("Start - End time", style: YodelTheme.metaRegularInactive),
            subtitle: Text(time, style: YodelTheme.bodyDefault),
          ),
          Separator(),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            title: Text("Number of people required",
                style: YodelTheme.metaRegularInactive),
            subtitle: Text("$headCount $headCountText",
                style: YodelTheme.bodyDefault),
          ),
          SectionHeader(
            child: Text(
              "Location",
              style: YodelTheme.metaRegular,
            ),
          ),
          SiteItem(
            onChanged: (site, _) async {
              await openMapForSite(site);
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            site: state.shiftDetails.location,
            trailingBuilder: (context, site) {
              return Container(
                width: 120,
                alignment: Alignment.center,
                child: LinkButton(
                  highlightStyle: YodelTheme.metaRegularManage.copyWith(
                    color: YodelTheme.darkGreyBlue.withOpacity(0.8),
                  ),
                  style: YodelTheme.metaRegularManage,
                  child: Text(
                    "Shift location",
                    textAlign: TextAlign.right,
                  ),
                  onPressed: () async {
                    await openMapForSite(site);
                  },
                ),
              );
            },
          ),
          SectionHeader(
            padding: const EdgeInsets.only(top: 8),
          ),
          Container(
            height: 130,
          ),
        ],
      ),
    );
  }
}

class _SkillsDetailsView extends StatelessWidget {
  final CreateShiftActionState state;
  _SkillsDetailsView({
    Key key,
    @required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    int i = 0;
    state.peopleDetails.skills.forEach((skill) {
      children.add(SkillItem(
        skill: skill,
        backgroundColor: YodelTheme.lightPaleGrey,
      ));

      if (i < state.peopleDetails.skills.length - 1) {
        children.add(Separator());
      }

      i++;
    });

    children.add(
      SectionHeader(
        padding: const EdgeInsets.only(top: 8),
      ),
    );

    children.add(
      Container(
        height: 130,
      ),
    );
    return SliverList(
      delegate: SliverChildListDelegate(
        children,
      ),
    );
  }
}

class _OtherDetailsView extends StatelessWidget {
  final CreateShiftActionState state;
  _OtherDetailsView({
    Key key,
    @required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        title: Text("Description", style: YodelTheme.metaRegularInactive),
        subtitle: Text(state.shiftDetails.description ?? "-",
            style: YodelTheme.bodyDefault),
      ),
      Separator(),
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text("Approval type", style: YodelTheme.metaRegularInactive),
        subtitle: Text(
            ReCase(describeEnum(state.approvalDetails.mode)).sentenceCase,
            style: YodelTheme.bodyDefault),
      ),
      SectionHeader(
        child: Text(
          "Find people from",
          style: YodelTheme.metaRegular,
        ),
      ),
    ];

    int i = 0;
    state.peopleDetails.sites.forEach((site) {
      children.add(SiteItem(
        site: site,
        backgroundColor: YodelTheme.lightPaleGrey,
      ));

      if (i < state.peopleDetails.sites.length - 1) {
        children.add(Separator());
      }

      i++;
    });

    children.add(
      SectionHeader(
        child: Text(
          "Send notification to",
          style: YodelTheme.metaRegular,
        ),
      ),
    );

    i = 0;
    children.add(WorkerItem(
      backgroundColor: YodelTheme.lightPaleGrey,
      worker: state.approvalDetails.approver,
      trailingBuilder: (context, worker) => Text(
        "You",
        style: YodelTheme.metaRegularManage,
      ),
    ));

    if (state.approvalDetails.workers.length > 0) {
      children.add(Separator());
    }

    final workers = state.approvalDetails.workers
        .where((m) => m.mode == WorkerType.individual)
        .toList();

    workers.forEach((worker) {
      children.add(WorkerItem(
        worker: worker,
      ));

      if (i < workers.length - 1) {
        children.add(Separator());
      }

      i++;
    });

    children.add(
      SectionHeader(
        padding: const EdgeInsets.only(top: 8),
      ),
    );

    children.add(
      Container(
        height: 130,
      ),
    );

    return SliverList(
      delegate: SliverChildListDelegate(
        children,
      ),
    );
  }
}
