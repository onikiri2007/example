import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class MyShiftCard extends StatefulWidget {
  const MyShiftCard({
    Key key,
    this.padding = const EdgeInsets.all(16),
    this.shift,
    this.onTap,
    this.highlightColor,
    this.splashColor,
    this.color,
  }) : super(key: key);

  final Shift shift;
  final EdgeInsets padding;
  final VoidCallback onTap;
  final Color highlightColor;
  final Color splashColor;
  final Color color;

  @override
  _MyShiftCardState createState() => _MyShiftCardState();
}

class _MyShiftCardState extends State<MyShiftCard> {
  MyShiftBloc _bloc;

  @override
  void didChangeDependencies() {
    _createBloc();
    super.didChangeDependencies();
  }

  void _createBloc() {
    _bloc?.close();
    _bloc = MyShiftBloc(
      shift: widget.shift,
      refresherBloc: BlocProvider.of<ShiftsSyncBloc>(context),
      shiftsBloc: BlocProvider.of<MyShiftsBloc>(context),
    );
  }

  @override
  void didUpdateWidget(MyShiftCard oldWidget) {
    if (oldWidget.shift != widget.shift) {
      _createBloc();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return BlocProvider<MyShiftBloc>.value(
      value: _bloc,
      child: BlocBuilder(
        bloc: _bloc,
        builder: (context, MyShiftState state) {
          return StreamBuilder<MyShift>(
              initialData: _bloc.currentShift,
              stream: _bloc.shift,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                MyShift shift = snapshot.data;

                final DateFormat timeformat = DateFormat("h:mm a");

                Color sidebarColor = YodelTheme.iris;

                final Worker worker = shift.worker;

                if (worker != null) {
                  if (worker.isApproved) {
                    sidebarColor = YodelTheme.tealish;
                  } else if (worker.isRequested) {
                    sidebarColor = YodelTheme.amber;
                  } else {
                    sidebarColor = YodelTheme.iris;
                  }
                }

                if (!shift.isActive || !worker.isActive) {
                  sidebarColor = YodelTheme.lightGreyBlue;
                }

                double boxHeight = _showActions(shift, worker)
                    ? (state is MyShiftError ? 162 : 142)
                    : 110;

                return ListTile(
                  contentPadding: widget.padding,
                  leading: Container(
                    width: 55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          timeformat.format(shift.startOn).toLowerCase(),
                          style: YodelTheme.metaRegular,
                        ),
                        Text(
                          timeformat.format(shift.finishOn).toLowerCase(),
                          style: YodelTheme.metaDefault,
                        ),
                      ],
                    ),
                  ),
                  title: Container(
                    width: double.infinity,
                    height: boxHeight,
                    decoration: BoxDecoration(
                        color: widget.color ?? Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: YodelTheme.shadow.withOpacity(0.32),
                            offset: Offset(0, 1),
                          )
                        ]),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        splashColor:
                            widget.splashColor ?? Theme.of(context).splashColor,
                        highlightColor: widget.highlightColor ??
                            Theme.of(context).highlightColor,
                        onTap: widget.onTap,
                        enableFeedback: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              width: 8,
                              decoration: BoxDecoration(
                                color: sidebarColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                SiteAvatarImage(
                                                  site: shift.site,
                                                  size: 20,
                                                ),
                                                SizedBox(
                                                  width: 6,
                                                ),
                                                ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxWidth: 125,
                                                  ),
                                                  child: Text(shift.site.name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: YodelTheme
                                                          .metaDefault),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              shift.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: YodelTheme.bodyStrong
                                                  .copyWith(
                                                color: (!shift.isActive ||
                                                        !worker.isActive)
                                                    ? YodelTheme.lightGreyBlue
                                                    : YodelTheme.darkGreyBlue,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            ..._buildStatusText(worker, shift),
                                            if (state is MyShiftError)
                                              Text(
                                                state.error,
                                                overflow: TextOverflow.ellipsis,
                                                style: YodelTheme.metaRegular
                                                    .copyWith(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            if (state is MyShiftError)
                                              SizedBox(height: 4),
                                          ],
                                        ),
                                      ),
                                      if (_showActions(shift, worker))
                                        Separator(),
                                      if (_showActions(shift, worker))
                                        Container(
                                          height: 50,
                                          child: _ShiftStatusActionButtons(
                                            shift: shift,
                                            worker: worker,
                                            isLoading:
                                                state is MyShiftActionLoading,
                                            onWorkStatusUpdatePressed:
                                                (worker, status) {
                                              _bloc.add(
                                                UpdateMyStatus(
                                                  status: status,
                                                  shiftId: shift.id,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (worker.isNew &&
                                      shift.isActive &&
                                      worker.isActive)
                                    Positioned(
                                      height: 32,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: YodelTheme.iris,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4)),
                                        ),
                                        padding: EdgeInsets.all(8),
                                        alignment: Alignment.center,
                                        child: Text("New",
                                            style:
                                                YodelTheme.metaRegular.copyWith(
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  bool _showActions(Shift shift, Worker worker) {
    return shift.isActive && worker.isActive && !worker.isApproved;
  }

  List<Widget> _buildStatusText(Worker worker, Shift shift) {
    List<Widget> children = [];

    if (shift.isPastShift) {
      children
          .add(Text("Shift Complete", style: YodelTheme.metaDefaultInactive));
    } else if (worker.isInvited) {
      children.add(
        Text(
          shift.approval == ShiftApprovalMode.manual
              ? "Approval Required"
              : "No Approval Required",
          style: YodelTheme.metaDefault,
        ),
      );
    } else if (worker.isRequested) {
      children.add(
        Text(
          "Shift Requested",
          style: YodelTheme.metaDefault,
        ),
      );
    } else if (worker.isApproved) {
      children.add(
        Text(
          "Shift Approved",
          style: YodelTheme.metaDefault.copyWith(
            color: YodelTheme.tealish,
          ),
        ),
      );
    } else if (!worker.isActive) {
      children.add(
        Text(
          "${ReCase(describeEnum(worker.status)).sentenceCase} Shift",
          style: YodelTheme.metaDefaultInactive,
        ),
      );
    }

    return children;
  }
}

typedef WorkStatusCallback = void Function(Worker worker, WorkerStatus status);

class _ShiftStatusActionButtons extends StatelessWidget {
  final Shift shift;
  final Worker worker;
  final bool isLoading;
  final WorkStatusCallback onWorkStatusUpdatePressed;

  const _ShiftStatusActionButtons({
    @required this.shift,
    @required this.worker,
    this.isLoading = false,
    this.onWorkStatusUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(),
        ),
      );
    }

    List<Widget> children = [];
    if (worker.isInvited) {
      final isAuto = shift.approval == ShiftApprovalMode.automatic;

      children = [
        Expanded(
          child: FlatButton(
            onPressed: () {
              if (onWorkStatusUpdatePressed != null) {
                onWorkStatusUpdatePressed(worker, WorkerStatus.applied);
              }
            },
            child: Text(isAuto ? "Accept" : "Request",
                style: YodelTheme.bodyActive),
          ),
        ),
        Separator(
          axis: SeparatorAxis.vertical,
        ),
        Expanded(
          child: FlatButton(
              onPressed: () {
                if (onWorkStatusUpdatePressed != null) {
                  onWorkStatusUpdatePressed(worker, WorkerStatus.declined);
                }
              },
              disabledColor: YodelTheme.lightPaleGrey,
              child: Text(
                "Decline",
                style: YodelTheme.bodyInactive,
              )),
        )
      ];
    }

    if (worker.isRequested) {
      children.add(Expanded(
        child: FlatButton(
            onPressed: () {
              if (onWorkStatusUpdatePressed != null) {
                onWorkStatusUpdatePressed(worker, WorkerStatus.declined);
              }
            },
            disabledColor: YodelTheme.lightPaleGrey,
            child: Text(
              "Cancel Shift Request",
              style: YodelTheme.bodyInactive,
            )),
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
}
