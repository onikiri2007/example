import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class ShiftWorkersSearchScreen extends StatefulWidget {
  final ManageShiftBloc bloc;
  final ShiftResponseFilterType filterType;

  ShiftWorkersSearchScreen({
    @required this.bloc,
    this.filterType = ShiftResponseFilterType.approved,
  }) : assert(bloc != null);

  @override
  _ShiftWorkersSearchScreenState createState() =>
      _ShiftWorkersSearchScreenState();
}

class _ShiftWorkersSearchScreenState extends State<ShiftWorkersSearchScreen>
    with PostBuildActionMixin {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    onWidgetDidBuild(() async {
      await Future.delayed(Duration(milliseconds: 350));
      if (focusNode != null && mounted) {
        FocusScope.of(context).requestFocus(focusNode);
      }
      widget.bloc.onQueryChanged(
          ShiftWorkerSearchCriteria(filter: widget.filterType, query: ""));
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();

    super.dispose();
  }

  ManageShiftBloc get _bloc => widget.bloc;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: KeyboardDismissable(
        child: Scaffold(
          backgroundColor: YodelTheme.lightPaleGrey,
          appBar: AppBar(
            title: Text(
              "Approved for Shift",
              style: YodelTheme.titleWhite,
            ),
            leading: OverflowBox(
              maxWidth: 100.0,
              child: NavbarButton(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text("Close",
                    style: Theme.of(context).appBarTheme.textTheme.button),
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  Navigator.pop(context);
                },
              ),
            ),
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Hero(
                  tag: "WorkerSearch",
                  child: Material(
                    type: MaterialType.transparency,
                    child: SearchField(
                      focusNode: focusNode,
                      controller: controller,
                      hasBorder: true,
                      autofocus: false,
                      onQueryChanged: (query) {
                        _bloc.onQueryChanged(ShiftWorkerSearchCriteria(
                          filter: widget.filterType,
                          query: query ?? "",
                        ));
                      },
                      onClear: () {
                        _bloc.onQueryChanged(ShiftWorkerSearchCriteria(
                          filter: widget.filterType,
                          query: "",
                        ));
                      },
                      hintText: "Search",
                    ),
                  ),
                ),
              ),
              preferredSize: Size.fromHeight(66),
            ),
          ),
          body: BlocBuilder(
            bloc: _bloc,
            builder: (BuildContext context, ManageShiftState state) {
              if (state is ManageShiftLoading) {
                return LoadingIndicator();
              }

              return _buildList(_bloc.currentShift);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(ManageShift shift) {
    return StreamBuilder<List<Worker>>(
      initialData: [],
      stream: _bloc.workers,
      builder: (context, snapshot) {
        final workers = snapshot.data;
        return ListView.separated(
          itemCount: workers.isEmpty ? 0 : workers.length + 1,
          separatorBuilder: (context, i) {
            if (i == workers.length - 1) {
              return SectionHeader(
                padding: const EdgeInsets.only(top: 8),
              );
            }

            return Separator();
          },
          itemBuilder: (context, i) {
            if (i == workers.length) {
              return Container();
            }
            return WorkerItem(
              worker: workers[i],
              onRemoved: shift.isActive
                  ? (worker) async {
                      final proceed = await showConfirmDialog(context) ?? false;

                      if (proceed) {
                        _bloc.add(UpdateResponseStatus(
                          worker: worker,
                          status: WorkerStatus.rejected,
                        ));
                      }
                    }
                  : null,
              trailingBuilder: (context, worker) {
                return worker.rate != null
                    ? Text(
                        "\$${worker.hourlyRate}/hr",
                        style: YodelTheme.metaDefault
                            .copyWith(color: YodelTheme.amber),
                        textAlign: TextAlign.right,
                      )
                    : Container();
              },
            );
          },
        );
      },
    );
  }
}
