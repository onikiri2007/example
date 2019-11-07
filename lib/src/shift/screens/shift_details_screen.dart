import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/contact/index.dart';
import 'package:yodel/src/routes.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

const double _kShiftActionMenuHeight = 222;

class ShiftDetailsScreen extends StatefulWidget {
  final ManageShift shift;
  final int shiftId;

  ShiftDetailsScreen({
    @required this.shiftId,
    this.shift,
  }) : assert(shiftId != null);

  @override
  _ShiftDetailsScreenState createState() => _ShiftDetailsScreenState();
}

class _ShiftDetailsScreenState extends State<ShiftDetailsScreen>
    with PostBuildActionMixin, TickerProviderStateMixin, OpenUrlMixin {
  ScrollController _scrollController = ScrollController();
  TabController _responseTabController;
  TabController _tabController;
  int _tabId = 0;
  int _responseTabId = 0;
  bool _isCollapsed = false;
  ManageShiftBloc _bloc;

  @override
  void initState() {
    _responseTabController = TabController(length: 3, vsync: this);
    _bloc = ManageShiftBloc(
      refresherBloc: BlocProvider.of<ShiftsSyncBloc>(context),
      shiftsBloc: BlocProvider.of<ManageShiftsBloc>(context),
      shift: widget.shift,
    );

    _bloc.add(FetchManageShift(
      widget.shiftId,
    ));

    _scrollController.addListener(() {
      setState(() {
        _isCollapsed = _scrollController.offset > kCollapseOffset;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _scrollController.dispose();
    _responseTabController.dispose();
    _tabController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      PageStorageKey<int>(0),
      PageStorageKey<int>(1),
      PageStorageKey<int>(2),
    ];

    return BlocBuilder(
        bloc: _bloc,
        builder: (context, ManageShiftState state) {
          return SafeArea(
            bottom: false,
            child: Scaffold(
              backgroundColor: YodelTheme.lightPaleGrey,
              body: BlocListener(
                bloc: _bloc,
                listener: (context, state) {
                  if (state is ManageShiftError) {
                    _bloc.add(ResetShiftActionResult());
                    showErrorOnPostBuild(context, state.error);
                  }

                  if (state is ManageShiftLoaded) {
                    if (state.actionResult == ManageShiftActionResult.success &&
                        state.action != ManageShiftAction.inviteFromOtherSite) {
                      showSuccessOnPostBuild(context, state.actionMessage,
                          callback: () {
                        _bloc.add(ResetShiftActionResult());
                      });
                    }
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _bloc.add(FetchManageShift(widget.shiftId));
                        },
                        displacement: 20,
                        child: StreamBuilder<Shift>(
                            initialData: _bloc.currentShift,
                            stream: _bloc.shift,
                            builder: (context, snapshot) {
                              return CustomScrollView(
                                key: keys[_tabId],
                                physics: AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                slivers: _buildSlivers(
                                  context,
                                  state,
                                  snapshot.data,
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  List<Widget> _buildSlivers(
      BuildContext context, ManageShiftState state, ManageShift shift) {
    if (shift == null) {
      return [
        SliverFillRemaining(
          child: LoadingIndicator(),
        ),
      ];
    }

    List<Widget> slivers = [
      _buildAppBar(context, shift),
    ];

    if (shift != null) {
      slivers.addAll([_buildCalendarWidget(shift), _buildTabs(shift)]);
    }

    if (shift.isFilled) {
      if (_tabId == 1) {
        slivers.addAll(
            _buildShiftMoreInfoSlivers(shift, state is ManageShiftLoading));
      } else {
        slivers.addAll(
            _buildShiftApprovedSlivers(shift, state is ManageShiftLoading));
      }
    } else {
      if (_tabId == 1) {
        slivers.addAll(
            _buildShiftApprovedSlivers(shift, state is ManageShiftLoading));
      } else if (_tabId == 2) {
        slivers.addAll(
            _buildShiftMoreInfoSlivers(shift, state is ManageShiftLoading));
      } else {
        slivers.addAll(_buildShiftResponsesSlivers(shift, state));
      }
    }

    return slivers;
  }

  SliverPersistentHeader _buildTabs(ManageShift shift) {
    var tabs = ["Responses", "Approved", "More info"];
    if (shift.isFilled) {
      tabs = tabs.sublist(1, tabs.length).toList();
    }

    _tabController =
        TabController(initialIndex: _tabId, length: tabs.length, vsync: this);

    return SliverPersistentHeader(
      delegate: SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelPadding: EdgeInsets.only(top: 10),
          labelColor: Colors.white,
          indicatorWeight: 4.0,
          unselectedLabelColor: YodelTheme.lightGreyBlue,
          indicatorPadding:
              EdgeInsets.only(left: 9.0, right: 9.0, top: 0, bottom: 0),
          labelStyle: YodelTheme.tabFilterActive,
          unselectedLabelStyle: YodelTheme.tabFilterDefault,
          onTap: (id) {
            setState(() {
              _tabId = id;
            });
          },
          tabs: tabs.map((name) {
            return Tab(
              text: name,
            );
          }).toList(),
        ),
        key: ValueKey<int>(tabs.length),
      ),
      pinned: true,
    );
  }

  SliverPersistentHeader _buildCalendarWidget(ManageShift shift) {
    final headCountText = Intl.plural(shift.headCountRemaining,
        zero: "employee", one: "employee", other: "employees");

    return SliverPersistentHeader(
      delegate: SliverShiftDateWidgetDelegate(
        shift: shift,
        color: YodelTheme.amber,
        hasBorder: true,
        child: Row(
          children: <Widget>[
            if (shift.isCancelled)
              Text(
                "Shift Cancelled",
                style: YodelTheme.metaRegularInactive,
              ),
            if (!shift.isCancelled && !shift.isFilled)
              Text(
                "Required:",
                style: YodelTheme.metaRegularActiveWhite,
              ),
            if (!shift.isCancelled && !shift.isFilled)
              SizedBox(
                width: 2,
              ),
            if (!shift.isCancelled)
              Text(
                shift.isFilled
                    ? "All positions filled"
                    : "${shift.headCountRemaining} $headCountText",
                style: YodelTheme.metaRegularActiveWhite.copyWith(
                  color: shift.isFilled ? YodelTheme.tealish : YodelTheme.amber,
                ),
              )
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildAppBar(BuildContext context, ManageShift shift) {
    return YodelSliverAppBar(
      forceElevated: false,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: YodelTheme.darkGreyBlue,
      centerTitle: true,
      expandedHeight: kExpandedHeight,
      floating: false,
      pinned: true,
      leading: NavbarButton(
        padding: const EdgeInsets.only(left: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          "Close",
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        StreamBuilder<bool>(
            initialData: false,
            stream: _bloc.menuEnabled,
            builder: (context, snapshot) {
              final authBloc = BlocProvider.of<AuthenticationBloc>(context);
              final user = authBloc.sessionTracker.currentSession.userData;
              double menuSize = _kShiftActionMenuHeight;
              final manager = shift.managerWorkers
                  .firstWhere((w) => w.id == user.userId, orElse: () => null);

              if (_isMyShift(shift, user)) {
                menuSize = menuSize - 56;
              }

              if (!_isMyShift(shift, user)) {
                menuSize = menuSize - 56;
              }

              return BubbleTooltip(
                onClose: () {
                  _bloc.enableMenu(false);
                },
                showTooltip: snapshot.data,
                arrowTipDistance: 10.0,
                arrowBaseWidth: 25,
                arrowLength: 15,
                borderWidth: 0,
                minimumOutSidePadding: 16,
                borderRadius: 10,
                touchThroughAreaShape: ClipAreaShape.rectangle,
                outsideBackgroundColor: YodelTheme.shadow.withOpacity(0.32),
                popupDirection: TooltipDirection.down,
                borderColor: Colors.transparent,
                shadows: [
                  BoxShadow(
                    blurRadius: 4,
                    color: YodelTheme.shadow.withOpacity(0.32),
                    offset: Offset(0, 1),
                  )
                ],
                content: Container(
                    width: 200,
                    height: menuSize,
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        BlocBuilder(
                            bloc: _bloc,
                            builder: (context, ManageShiftState state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      LinkButton(
                                        alignment: Alignment.centerLeft,
                                        onPressed: () {
                                          _bloc.add(ResendInvites(shift.id));
                                        },
                                        style: YodelTheme.bodyActive,
                                        disabledStyle: YodelTheme.bodyInactive,
                                        highlightStyle: YodelTheme.bodyActive
                                            .copyWith(
                                                color: YodelTheme.darkGreyBlue),
                                        child: Text(
                                          "Resend shift invites",
                                        ),
                                      ),
                                      if (state is ManageShiftMenuActionLoading)
                                        SizedBox(
                                          width: 10,
                                        ),
                                      if (state is ManageShiftMenuActionLoading)
                                        MiniLoadingIndicator(
                                          width: 15,
                                          height: 15,
                                          padding: EdgeInsets.zero,
                                        )
                                    ],
                                  ),
                                ),
                              );
                            }),
                        Separator(),
                        if (_isMyShift(shift, user))
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16.0),
                              child: LinkButton(
                                alignment: Alignment.centerLeft,
                                onPressed: () {
                                  _bloc.enableMenu(false);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BlocProvider<ManageShiftBloc>.value(
                                        value: _bloc,
                                        child: InviteFromOtherSitesScreen(
                                          header: Text(
                                            "Select sites",
                                            style: YodelTheme.metaRegular,
                                          ),
                                          selected: [
                                            shift.site,
                                            ...shift.otherSites
                                          ],
                                          location: shift.site,
                                          multiSelect: true,
                                          title: Text(
                                            "Invite other sites",
                                            style: YodelTheme.titleWhite,
                                          ),
                                        ),
                                      ),
                                      fullscreenDialog: true,
                                    ),
                                  );
                                },
                                style: YodelTheme.bodyActive,
                                disabledStyle: YodelTheme.bodyInactive,
                                highlightStyle: YodelTheme.bodyActive
                                    .copyWith(color: YodelTheme.darkGreyBlue),
                                child: Text(
                                  "Invite from other sites",
                                ),
                              ),
                            ),
                          ),
                        if (_isMyShift(shift, user)) Separator(),
                        if (!_isMyShift(shift, user))
                          BlocBuilder(
                              bloc: _bloc,
                              builder: (context, ManageShiftState state) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        LinkButton(
                                          alignment: Alignment.centerLeft,
                                          onPressed: () {
                                            _bloc.add(
                                              TurnOnOrOffNotification(
                                                shiftId: shift.id,
                                                managerId: manager?.id,
                                              ),
                                            );
                                          },
                                          style: YodelTheme.bodyActive,
                                          disabledStyle:
                                              YodelTheme.bodyInactive,
                                          highlightStyle: YodelTheme.bodyActive
                                              .copyWith(
                                                  color:
                                                      YodelTheme.darkGreyBlue),
                                          child: Text(
                                            manager != null
                                                ? "Turn off notifications"
                                                : "Turn on notifications",
                                          ),
                                        ),
                                        if (state
                                            is ManageShiftMenuActionLoading)
                                          SizedBox(
                                            width: 10,
                                          ),
                                        if (state
                                            is ManageShiftMenuActionLoading)
                                          MiniLoadingIndicator(
                                            width: 15,
                                            height: 15,
                                            padding: EdgeInsets.zero,
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        if (!_isMyShift(shift, user)) Separator(),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16.0),
                            child: LinkButton(
                              alignment: Alignment.centerLeft,
                              onPressed: () async {
                                _bloc.enableMenu(false);
                                final ok = await showConfirmDialog(context,
                                    title:
                                        "Are you sure you want to delete this shift?");

                                if (ok) {
                                  _bloc.add(DeleteShift(shift.id));
                                }
                              },
                              style: YodelTheme.bodyActive
                                  .copyWith(color: Colors.redAccent),
                              disabledStyle: YodelTheme.bodyInactive,
                              highlightStyle: YodelTheme.bodyActive.copyWith(
                                  color: Colors.redAccent.withOpacity(0.8)),
                              child: Text(
                                "Delete",
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                child: IconLinkButton(
                  icon: Icon(YodelIcons.moreactions),
                  color: YodelTheme.amber,
                  highlightColor: YodelTheme.amber.withOpacity(0.8),
                  disabledColor: YodelTheme.lightGreyBlue,
                  onPressed: shift != null && shift.isActive
                      ? () {
                          _bloc.enableMenu(!snapshot.data);
                        }
                      : null,
                ),
              );
            })
      ],
      flexibleSpace: shift != null
          ? FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.all(16),
              title: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: _isCollapsed
                    ? Text(
                        shift.name,
                        maxLines: 1,
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
                            shift.name,
                            style: YodelTheme.mainTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            shift.site.name,
                            style: YodelTheme.metaWhite,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ))
                  : null)
          : null,
    );
  }

  List<Widget> _buildShiftResponsesSlivers(
      ManageShift shift, ManageShiftState state) {
    final workers = shift.responses;
    List<Widget> slivers = [_buildResponsesTabs(workers)];

    if (state is ManageShiftLoading) {
      slivers.add(SliverFillRemaining(
        child: LoadingIndicator(),
      ));
      return slivers;
    }

    if (_responseTabId == 1) {
      slivers.addAll(_buildInvitedResponsesSlivers(shift));
    } else if (_responseTabId == 2) {
      slivers.addAll(_buildDeclinedResponsesSlivers(shift));
    } else {
      slivers.addAll(_buildToReviewResponsesSlivers(shift, state: state));
    }

    return slivers;
  }

  Widget _buildResponsesTabs(FilteredResponses workers) {
    return SliverPersistentHeader(
      delegate: SliverTabBarDelegate(
          TabBar(
            controller: _responseTabController,
            labelPadding: EdgeInsets.all(8),
            labelColor: YodelTheme.darkGreyBlue,
            indicator: BoxDecoration(color: Colors.transparent),
            indicatorWeight: 0.1,
            unselectedLabelColor: YodelTheme.lightGreyBlue,
            indicatorPadding: EdgeInsets.zero,
            labelStyle: YodelTheme.metaRegular,
            unselectedLabelStyle: YodelTheme.metaDefaultInactive,
            onTap: (id) {
              setState(() {
                _responseTabId = id;
              });
            },
            tabs: [
              Tab(
                text: "To review (${workers?.reviewItemsCount ?? 0})",
              ),
              Tab(text: "Invited (${workers?.invitedItemCount ?? 0})"),
              Tab(text: "Declined (${workers?.declinedItemCount ?? 0})"),
            ],
          ),
          key: ValueKey<FilteredResponses>(workers),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: YodelTheme.shadow.withOpacity(0.32),
              offset: Offset(0, 1),
            )
          ])),
      pinned: true,
    );
  }

  List<Widget> _buildShiftApprovedSlivers(ManageShift shift, bool isLoading) {
    if (isLoading) {
      return [
        SliverFillRemaining(
          child: LoadingIndicator(),
        )
      ];
    }

    final approved = shift.responses.approved;

    return [
      approved.isEmpty
          ? SliverFillRemaining(
              child: Container(
                color: YodelTheme.paleGrey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        YodelImages.emptyState_noApproved,
                        height: 64,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "No employees have been approved for this shift",
                          style: YodelTheme.bodyHyperText,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : SliverStickyHeaderBuilder(
              builder: (context, state) => Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ShiftWorkersSearchScreen(
                        bloc: _bloc,
                        filterType: ShiftResponseFilterType.approved,
                      ),
                      fullscreenDialog: true,
                    ));
                  },
                  child: Hero(
                    tag: "WorkerSearch",
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: YodelTheme.paleGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.only(
                          left: 11.0, top: 14.0, bottom: 14.0, right: 11.0),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.search),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Search", style: YodelTheme.bodyInactive),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == 0) {
                      return SectionHeader(
                        padding: const EdgeInsets.only(top: 8),
                      );
                    }

                    if (i == approved.length + 1) {
                      return SectionHeader(
                        padding: const EdgeInsets.only(top: 8),
                      );
                    }

                    final index = i - 1;
                    final worker = approved[index];

                    List<Widget> children = [
                      WorkerItem(
                        onChanged: (worker, _) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ContactDetailsScreen(
                                id: worker.id,
                              ),
                            ),
                          );
                        },
                        trailingBuilder: worker.rate != null
                            ? (context, worker) {
                                return Text("\$${worker.hourlyRate}/hr",
                                    style: YodelTheme.metaDefault
                                        .copyWith(color: YodelTheme.amber));
                              }
                            : null,
                        onRemoved: shift.isActive
                            ? (worker) async {
                                final proceed =
                                    await showConfirmDialog(context) ?? false;

                                if (proceed) {
                                  _bloc.add(UpdateResponseStatus(
                                    worker: worker,
                                    status: WorkerStatus.rejected,
                                  ));
                                }
                              }
                            : null,
                        worker: worker,
                      ),
                    ];

                    if (index != approved.length - 1) {
                      children.add(Separator());
                    }

                    return Column(
                      children: children,
                    );
                  },
                  childCount: approved.length + 2,
                ),
              ),
            ),
    ];
  }

  List<Widget> _buildShiftMoreInfoSlivers(ManageShift shift, bool isLoading) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    if (isLoading) {
      return [
        SliverFillRemaining(
          child: LoadingIndicator(),
        )
      ];
    }

    List<Widget> children = [
      Ink(
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text("Phone number", style: YodelTheme.metaRegularInactive),
          subtitle: Text(
            shift.site.contactPhone ?? "-",
            style: YodelTheme.bodyDefault,
          ),
          trailing: IconButton(
            color: YodelTheme.iris,
            iconSize: 30,
            icon: Icon(YodelIcons.contact_call),
            onPressed: shift.site.contactPhone != null
                ? () {
                    openTel(shift.site.contactPhone);
                  }
                : null,
          ),
        ),
      ),
      Separator(),
      Ink(
        color: Colors.white,
        child: ListTile(
          onTap: () {
            openMapForSite(shift.site);
          },
          contentPadding: EdgeInsets.all(16),
          title: Text("Address", style: YodelTheme.metaRegularInactive),
          subtitle: Text(shift.site.address,
              style: YodelTheme.bodyDefault.copyWith(
                color: YodelTheme.iris,
              )),
        ),
      ),
      Separator(),
      ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text("Description", style: YodelTheme.metaRegularInactive),
        subtitle: Html(
            useRichText: true,
            data: shift.description ?? "-",
            defaultTextStyle: YodelTheme.bodyDefault,
            linkStyle:
                YodelTheme.bodyHyperText.copyWith(color: YodelTheme.iris),
            onLinkTap: (url) {
              openWeb(url);
            }),
      ),
      SectionHeader(
        child: Text(
          "Skills required",
          style: YodelTheme.metaRegular,
        ),
      ),
    ];

    int i = 0;
    shift.skills.forEach((skill) {
      children.add(SkillItem(
        backgroundColor: YodelTheme.lightPaleGrey,
        skill: skill,
      ));
      if (i < shift.skills.length - 1) {
        children.add(
          Separator(),
        );
      }
      i++;
    });

    if (shift.createdBy != null) {
      children.add(
        SectionHeader(
          child: Text(
            "Created by",
            style: YodelTheme.metaRegular,
          ),
        ),
      );

      final isMyShift =
          _isMyShift(shift, authBloc.sessionTracker.currentSession.userData);

      children.add(WorkerItem(
        backgroundColor: YodelTheme.lightPaleGrey,
        worker: shift.createdBy,
        trailingBuilder: isMyShift
            ? (context, worker) {
                return Text(
                  "You",
                  style:
                      YodelTheme.metaDefault.copyWith(color: YodelTheme.amber),
                  textAlign: TextAlign.right,
                );
              }
            : null,
      ));
    }

    return [
      SliverList(
        delegate: SliverChildListDelegate(children),
      ),
    ];
  }

  List<Widget> _buildDeclinedResponsesSlivers(ManageShift shift) {
    final responses = shift.responses.declined;

    return [
      responses.isEmpty
          ? SliverFillRemaining(
              child: Container(
                color: YodelTheme.paleGrey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        YodelImages.emptyState_noResponses,
                        height: 54,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "No employees have been declined",
                          style: YodelTheme.bodyHyperText,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Column(
                    children: <Widget>[
                      WorkerItem(
                        onChanged: (worker, _) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ContactDetailsScreen(
                                id: worker.id,
                              ),
                            ),
                          );
                        },
                        worker: responses[index],
                      ),
                      index == responses.length - 1
                          ? SectionHeader(
                              padding: const EdgeInsets.only(top: 8),
                            )
                          : Separator()
                    ],
                  );
                },
                childCount: responses.length,
              ),
            )
    ];
  }

  List<Widget> _buildInvitedResponsesSlivers(ManageShift shift) {
    final responses = shift.responses.invited;

    return [
      responses.isEmpty
          ? SliverFillRemaining(
              child: Container(
                color: YodelTheme.paleGrey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        YodelImages.emptyState_noResponses,
                        height: 54,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "No employees have been invited",
                          style: YodelTheme.bodyHyperText,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Column(
                    children: <Widget>[
                      WorkerItem(
                        onChanged: (worker, _) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ContactDetailsScreen(
                                id: worker.id,
                              ),
                            ),
                          );
                        },
                        worker: responses[index],
                        trailingBuilder: (context, worker) {
                          return Text(
                            worker.shiftViewedStatus,
                            style: YodelTheme.metaDefaultInactive,
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                      if (index == responses.length - 1)
                        SectionHeader(
                          padding: const EdgeInsets.only(top: 8),
                        )
                      else
                        Separator()
                    ],
                  );
                },
                childCount: responses.length,
              ),
            )
    ];
  }

  List<Widget> _buildToReviewResponsesSlivers(ManageShift shift,
      {ManageShiftState state}) {
    final workers = shift.responses;

    return [
      workers.reviews.isEmpty
          ? SliverFillRemaining(
              child: Container(
                color: YodelTheme.paleGrey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        YodelImages.emptyState_noResponses,
                        height: 54,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "No employees have responded to this request",
                          style: YodelTheme.bodyHyperText,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverFixedExtentList(
                itemExtent: 168,
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    bool isLoading = false;
                    final worker = workers.reviews[index];
                    if (state is ManageShiftActionLoading) {
                      isLoading = state.shiftId == shift.id &&
                          state.workerId == worker.id;
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ShiftResponseCard(
                        shift: shift,
                        isLoading: isLoading,
                        worker: worker,
                        leftButtonPressed: shift.isActive
                            ? () {
                                _bloc.add(UpdateResponseStatus(
                                    worker: workers.reviews[index],
                                    status: WorkerStatus.awarded));
                              }
                            : null,
                        rightButtonPressed: () {
                          router.navigateTo(context, "/contact/${worker.id}",
                              transition: TransitionType.native);
                        },
                      ),
                    );
                  },
                  childCount: workers.reviews.length,
                ),
              ),
            )
    ];
  }

  bool _isMyShift(ManageShift shift, UserData user) {
    return shift?.createdBy?.id == user?.userId;
  }
}

class SliverShiftDateWidgetDelegate extends SliverPersistentHeaderDelegate {
  final Shift shift;
  final Color color;
  final Widget child;
  final bool hasBorder;

  SliverShiftDateWidgetDelegate({
    @required this.shift,
    @required this.color,
    @required this.child,
    this.hasBorder = false,
  })  : assert(shift != null),
        assert(color != null);

  @override
  double get minExtent => 95;
  @override
  double get maxExtent => 95;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ShiftDateWidget(
      color: color,
      shift: shift,
      child: child,
      hasBorder: hasBorder,
    );
  }

  @override
  bool shouldRebuild(SliverShiftDateWidgetDelegate oldDelegate) {
    return oldDelegate.shift != this.shift;
  }
}
