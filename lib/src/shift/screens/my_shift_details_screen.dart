import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class MyShiftDetailsScreen extends StatefulWidget {
  final MyShift shift;
  final int shiftId;

  MyShiftDetailsScreen({
    @required this.shiftId,
    this.shift,
  }) : assert(shiftId != null);

  @override
  _MyShiftDetailsScreenState createState() => _MyShiftDetailsScreenState();
}

class _MyShiftDetailsScreenState extends State<MyShiftDetailsScreen>
    with PostBuildActionMixin, TickerProviderStateMixin, OpenUrlMixin {
  ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  MyShiftBloc _bloc;

  @override
  void initState() {
    _bloc = MyShiftBloc(
      refresherBloc: BlocProvider.of<ShiftsSyncBloc>(context),
      shiftsBloc: BlocProvider.of<MyShiftsBloc>(context),
      shift: widget.shift,
    );

    _bloc.add(FetchAndUpdateMyStatus(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: YodelTheme.tealish,
      ),
      child: BlocBuilder(
          bloc: _bloc,
          builder: (context, MyShiftState state) {
            return SafeArea(
              child: Scaffold(
                backgroundColor: YodelTheme.lightPaleGrey,
                body: BlocListener(
                  bloc: _bloc,
                  listener: (context, state) {
                    if (state is MyShiftError) {
                      showErrorOnPostBuild(context, state.error);
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      RefreshIndicator(
                        onRefresh: () async {
                          _bloc.add(FetchMyShift(widget.shiftId));
                        },
                        displacement: 60,
                        child: StreamBuilder<MyShift>(
                            stream: _bloc.shift,
                            builder: (context, snapshot) {
                              return CustomScrollView(
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
                      StreamBuilder<MyShift>(
                          stream: _bloc.shift,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }

                            final shift = snapshot.data;
                            final worker = shift.worker;

                            if (!shift.isActive ||
                                worker.isApproved ||
                                !worker.isActive ||
                                state is MyShiftLoading) {
                              return Container();
                            }

                            return Positioned(
                              height: worker.isRequested ||
                                      state is MyShiftActionLoading
                                  ? 60
                                  : 126,
                              width: MediaQuery.of(context).size.width,
                              bottom: 0,
                              child: Container(
                                color: YodelTheme.darkGreyBlue,
                                padding: state is! MyShiftActionLoading &&
                                        (worker.isApprovalRequired(shift) ||
                                            worker.isInvited)
                                    ? EdgeInsets.only(
                                        top: 16,
                                        left: 16,
                                        right: 16,
                                        bottom: 8,
                                      )
                                    : null,
                                child: Column(
                                  children: [
                                    if (worker.isApprovalRequired(shift) ||
                                        worker.isInvited)
                                      ProgressButton(
                                        child: Text(
                                            worker.isApprovalRequired(shift)
                                                ? "Request Shift"
                                                : "Accept Shift",
                                            style: YodelTheme.bodyStrong),
                                        color: YodelTheme.amber,
                                        isLoading:
                                            state is MyShiftActionLoading,
                                        width: double.infinity,
                                        onPressed: !snapshot.hasData
                                            ? null
                                            : () {
                                                _bloc.add(UpdateMyStatus(
                                                  status: WorkerStatus.applied,
                                                  shiftId: shift.id,
                                                ));
                                              },
                                      ),
                                    if (worker.isRequested)
                                      ProgressButton(
                                        height: 50,
                                        child: Text(
                                          "Cancel Shift Request",
                                          style: YodelTheme.metaRegularInactive,
                                        ),
                                        color: YodelTheme.darkGreyBlue,
                                        isLoading:
                                            state is MyShiftActionLoading,
                                        width: double.infinity,
                                        onPressed: !snapshot.hasData
                                            ? null
                                            : () {
                                                final shift = snapshot.data;
                                                _bloc.add(UpdateMyStatus(
                                                  status: WorkerStatus.declined,
                                                  shiftId: shift.id,
                                                ));
                                              },
                                      ),
                                    if (state is! MyShiftActionLoading &&
                                        (worker.isApprovalRequired(shift) ||
                                            worker.isInvited))
                                      SizedBox(height: 8),
                                    if (state is! MyShiftActionLoading &&
                                        (worker.isApprovalRequired(shift) ||
                                            worker.isInvited))
                                      SizedBox(
                                        width: double.infinity,
                                        height: 30,
                                        child: FlatButton(
                                          child: Text("Decline shift",
                                              style: YodelTheme
                                                  .metaRegularInactive),
                                          onPressed: !snapshot.hasData
                                              ? null
                                              : () {
                                                  final shift = snapshot.data;
                                                  _bloc.add(UpdateMyStatus(
                                                    status:
                                                        WorkerStatus.declined,
                                                    shiftId: shift.id,
                                                  ));
                                                },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  List<Widget> _buildSlivers(
      BuildContext context, MyShiftState state, MyShift shift) {
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
      slivers.add(_buildCalendarWidget(shift));
    }
    slivers.addAll(_buildShiftMoreInfoSlivers(shift, state is MyShiftLoading));

    return slivers;
  }

  SliverPersistentHeader _buildCalendarWidget(MyShift shift) {
    final worker = shift.worker;

    String status;
    TextStyle style;
    if (worker.isApprovalRequired(shift)) {
      status = "Approval required";
      style = YodelTheme.metaRegular.copyWith(
        color: Colors.white,
      );
    } else if (worker.isInvited) {
      status = "Approval not required";
      style = YodelTheme.metaRegular.copyWith(
        color: Colors.white,
      );
    } else if (worker.isRequested) {
      status = "Shift requested";
      style = YodelTheme.metaRegular.copyWith(
        color: Colors.amber,
      );
    } else if (worker.isApproved) {
      status = "Shift approved";
      style = YodelTheme.metaRegular.copyWith(
        color: Colors.teal,
      );
    } else if (shift.isPastShift) {
      status = "Shift Complete";
      style = YodelTheme.metaDefaultInactive;
    } else if (!worker.isActive) {
      status = "${ReCase(describeEnum(worker.status)).sentenceCase} Shift";
      style = YodelTheme.metaDefaultInactive;
    }

    return SliverPersistentHeader(
      delegate: SliverShiftDateWidgetDelegate(
        shift: shift,
        color: YodelTheme.tealish,
        hasBorder: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (status != null)
              Text(
                status,
                style: style,
              ),
          ],
        ),
      ),
      pinned: true,
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, MyShift shift) {
    return SliverAppBar(
      forceElevated: false,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: YodelTheme.darkGreyBlue,
      centerTitle: true,
      expandedHeight: kExpandedHeight,
      floating: false,
      pinned: true,
      leading: OverflowBox(
        maxWidth: 100.0,
        child: NavbarButton(
          style: YodelTheme.bodyActive.copyWith(color: YodelTheme.tealish),
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "Close",
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                            maxLines: 1,
                            style: YodelTheme.mainTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            shift.site.name,
                            maxLines: 1,
                            style: YodelTheme.metaWhite,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ))
                  : null,
            )
          : null,
    );
  }

  List<Widget> _buildShiftMoreInfoSlivers(MyShift shift, bool isLoading) {
    if (isLoading) {
      return [
        SliverFillRemaining(
          child: MiniLoadingIndicator(),
        )
      ];
    }

    final Worker worker = shift.worker;

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
          subtitle: Text(
            shift.site.address,
            style: YodelTheme.bodyDefault.copyWith(
              color: YodelTheme.iris,
            ),
          ),
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

    if (shift.manager != null) {
      children.add(
        SectionHeader(
          child: Text(
            "Created by",
            style: YodelTheme.metaRegular,
          ),
        ),
      );

      children.add(WorkerItem(
        backgroundColor: YodelTheme.lightPaleGrey,
        worker: shift.manager,
      ));
    }

    if (shift.isActive && !worker.isApproved && worker.isActive) {
      children.add(Container(
        height: 135,
      ));
    }

    return [
      SliverStickyHeaderBuilder(
        builder: (context, state) {
          if (worker.isRequested &&
              shift.approval == ShiftApprovalMode.manual) {
            return Container(
              color: YodelTheme.amber,
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                "Pending Approval",
                textAlign: TextAlign.center,
                style: YodelTheme.metaRegular.copyWith(
                  color: Colors.white,
                ),
              ),
            );
          }

          if (worker.isApproved) {
            return Container(
              color: YodelTheme.tealish,
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                "Shift approved",
                textAlign: TextAlign.center,
                style: YodelTheme.metaRegular.copyWith(
                  color: Colors.white,
                ),
              ),
            );
          }

          return Container();
        },
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            children,
          ),
        ),
      )
    ];
  }
}
