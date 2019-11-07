import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class CreateShiftStep3Form extends StatefulWidget {
  final CreateShiftStep3FormBloc formBloc;

  CreateShiftStep3Form({
    Key key,
    @required this.formBloc,
  }) : super(key: key);

  @override
  _CreateShiftStep3FormState createState() => _CreateShiftStep3FormState();
}

class _CreateShiftStep3FormState extends State<CreateShiftStep3Form> {
  CreateShiftBloc _bloc;
  ScrollController controller;
  GlobalKey<AnimatedItemListState> _workerListKey = GlobalKey();
  @override
  void initState() {
    controller = ScrollController();

    super.initState();
  }

  CreateShiftStep3FormBloc get _formBloc => widget.formBloc;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<CreateShiftBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              SectionHeader(
                child: Text(
                  "How would you like to approve employees?",
                  style: YodelTheme.metaRegular,
                ),
              ),
              StreamBuilder<ShiftApprovalMode>(
                  initialData: _formBloc.selectedMode,
                  stream: _formBloc.mode,
                  builder: (context, snapshot) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.white,
                      child: YodelToggleButton(
                        defaultColor: YodelTheme.iris,
                        defaultStyle: YodelTheme.toggleButtonTextNotSelected,
                        selectedColor: YodelTheme.iris,
                        selectedStyle: YodelTheme.bodyWhite,
                        onChanged: (item) => _formBloc
                            .selectMode(ShiftApprovalMode.values[item.id]),
                        items: ShiftApprovalMode.values
                            .map((mode) => ToggleItem(
                                id: mode.index,
                                text: ReCase(describeEnum(mode)).pascalCase,
                                isSelected: mode == snapshot.data))
                            .toList(),
                      ),
                    );
                  }),
              StreamBuilder<ShiftApprovalMode>(
                  initialData: _formBloc.selectedMode,
                  stream: _formBloc.mode,
                  builder: (context, snapshot) {
                    return snapshot.data == ShiftApprovalMode.automatic
                        ? Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            child: Text(
                              "This shift will be filled on first come first service basis until all positions are filled",
                              style: YodelTheme.metaDefault,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container();
                  }),
              StreamBuilder<ShiftApprovalMode>(
                  initialData: _formBloc.selectedMode,
                  stream: _formBloc.mode,
                  builder: (context, snapshot) {
                    return Offstage(
                      offstage: snapshot.data == ShiftApprovalMode.manual
                          ? false
                          : true,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity:
                            snapshot.data == ShiftApprovalMode.manual ? 1 : 0,
                        child: Column(
                          children: <Widget>[
                            SectionHeader(
                              child: Text(
                                "Who can approve employees for this shift?",
                                style: YodelTheme.metaRegular,
                              ),
                            ),
                            StreamBuilder<ShiftApprovalPermission>(
                                initialData:
                                    _formBloc.selectedApprovalPrivacyMode,
                                stream: _formBloc.approvalPrivacy,
                                builder: (context, snapshot) {
                                  return Container(
                                    padding: EdgeInsets.all(16),
                                    color: Colors.white,
                                    child: YodelToggleButton(
                                      defaultColor: YodelTheme.iris,
                                      defaultStyle: YodelTheme
                                          .toggleButtonTextNotSelected,
                                      selectedColor: YodelTheme.iris,
                                      selectedStyle: YodelTheme.bodyWhite,
                                      onChanged: (item) =>
                                          _formBloc.selectPrivacyMode(
                                              ShiftApprovalPermission
                                                  .values[item.id]),
                                      items: ShiftApprovalPermission.values
                                          .map((mode) => ToggleItem(
                                                id: mode.index,
                                                text: ReCase(describeEnum(mode)
                                                        .replaceAll("_", " "))
                                                    .sentenceCase,
                                                isSelected:
                                                    mode == snapshot.data,
                                              ))
                                          .toList(),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    );
                  }),
              SectionHeader(
                child: Text(
                  "Who should receive notifications about this shift?",
                  style: YodelTheme.metaRegular,
                ),
              ),
              ...[
                WorkerItem(
                  worker: _formBloc.currentWorker,
                  multiSelect: false,
                  trailingBuilder: (context, worker) => Text(
                    "You",
                    style: YodelTheme.metaRegularManage,
                    textAlign: TextAlign.right,
                  ),
                ),
                Separator(),
              ],
              StreamBuilder<List<Worker>>(
                  initialData: _formBloc.selectedWorkers,
                  stream: _formBloc.workers,
                  builder: (context, snapshot) {
                    return AnimatedItemList(
                      key: _workerListKey,
                      initialItemCount: snapshot.data.length,
                      onRemoved: (index) {
                        _formBloc.removeWorker(snapshot.data[index]);
                      },
                      itemBuilder: (context, index, animation) {
                        return [
                          WorkerItem(
                            worker: snapshot.data[index],
                            multiSelect: false,
                            onRemoved: (worker) {
                              _workerListKey.currentState.removeItem(index,
                                  (context, animation) {
                                return [
                                  SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.vertical,
                                    child: WorkerItem(
                                      worker: worker,
                                      multiSelect: false,
                                    ),
                                  ),
                                  Separator(),
                                ];
                              });
                            },
                          ),
                          Separator(),
                        ];
                      },
                    );
                  }),
              StreamBuilder<List<Worker>>(
                  initialData: _formBloc.selectedWorkers,
                  stream: _formBloc.workers,
                  builder: (context, snapshot) {
                    return ListTile(
                      onTap: () async {
                        var workers = await Navigator.of(context)
                            .push<List<Worker>>(MaterialPageRoute(
                                builder: (context) => WorkerSearchScreen(
                                      multiSelect: true,
                                      selected: snapshot.data,
                                      currentWorker: _bloc.currentWorker,
                                      currentLocation: _formBloc
                                          .step1FormBloc.currentLocation,
                                      title: Text(
                                        "Who should be notified?",
                                        style: YodelTheme.titleWhite,
                                      ),
                                    )));
                        if (workers != null) {
                          _formBloc.addWorkers(workers);
                        }
                      },
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 200,
                        height: 50,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.add,
                              color: YodelTheme.iris,
                            ),
                            Text("Add manager", style: YodelTheme.bodyActive),
                          ],
                        ),
                      ),
                    );
                  }),
              SectionHeader(
                padding: const EdgeInsets.only(top: 8),
              ),
              Container(
                height: 100,
              )
            ],
          ),
        ),
      ],
    );
  }
}
