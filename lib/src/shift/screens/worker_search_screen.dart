import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class WorkerSearchScreen extends StatefulWidget {
  final bool multiSelect;
  final List<Worker> selected;
  final Widget title;
  final Worker currentWorker;
  final Site currentLocation;

  WorkerSearchScreen({
    Key key,
    this.multiSelect = false,
    this.selected = const [],
    this.title,
    this.currentWorker,
    this.currentLocation,
  }) : super(key: key);

  _WorkerSearchScreenState createState() => _WorkerSearchScreenState();
}

class _WorkerSearchScreenState extends State<WorkerSearchScreen> {
  TextEditingController searchTextController;
  WorkerSearchBloc _bloc;
  WorkerSelectBloc _selectBloc;

  @override
  void initState() {
    searchTextController = TextEditingController();
    _selectBloc = WorkerSelectBloc(
      selectedWorkers: widget.selected,
      currentWorker: widget.currentWorker,
    );

    _bloc = WorkerSearchBloc();
    _bloc.add(LoadWorkers(
      siteId: widget.currentLocation?.id,
    ));

    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    _bloc.dispose();
    _selectBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: KeyboardDismissable(
        child: Scaffold(
          backgroundColor: YodelTheme.lightPaleGrey,
          appBar: YodelAppBar(
            leadingWidth: 90,
            title: widget.title,
            centerTitle: true,
            leading: NavbarButton(
              padding: const EdgeInsets.only(left: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                "Back",
              ),
              onPressed: () {
                Navigator.pop(
                    context, _selectBloc.initialState.selectedWorkers);
              },
            ),
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchField(
                  autofocus: false,
                  onQueryChanged: (val) {
                    _bloc.add(
                      SearchWorker(
                        query: val,
                      ),
                    );
                  },
                  onClear: () {
                    _bloc.add(SearchWorker(
                      query: "",
                      siteId: widget.currentLocation?.id,
                    ));
                  },
                  controller: searchTextController,
                  hintText: "Search",
                ),
              ),
              preferredSize: Size.fromHeight(66),
            ),
            actions: widget.multiSelect
                ? <Widget>[
                    BlocBuilder(
                      bloc: _selectBloc,
                      builder: (context, WorkerSelectState state) {
                        return NavbarButton(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Text(
                              "Done",
                            ),
                            onPressed: () {
                              Navigator.pop(
                                  context,
                                  state.selectedWorkers
                                      .where((w) =>
                                          w.mode == WorkerType.individual)
                                      .toList());
                            });
                      },
                    )
                  ]
                : null,
          ),
          body: BlocBuilder(
            bloc: _bloc,
            builder: (context, WorkerSearchState state) {
              if (state is SiteSearchNoTerm) {
                return LoadingIndicator();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  WorkerItem(
                    activeColor: YodelTheme.lightGreyBlue,
                    multiSelect: true,
                    isSelected: true,
                    worker: _selectBloc.currentWorker,
                    trailingBuilder: (context, worker) => Text(
                      "You",
                      style: YodelTheme.metaRegularManage,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SectionHeader(
                    child: Text(
                      "Select managers",
                      style: YodelTheme.metaRegular,
                    ),
                  ),
                  Expanded(
                    child: _buildSearchResults(state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  _buildSearchResults(WorkerSearchState searchState) {
    if (searchState is WorkerSearchSuccess) {
      final workers = searchState.workers
          .where((w) => w.name != _selectBloc.currentWorker.name)
          .toList();
      return BlocBuilder(
        bloc: _selectBloc,
        builder: (context, WorkerSelectState state) {
          final selectedWorkers =
              state.selectedWorkers.map((s) => s.id).toList();
          return ListView.separated(
            separatorBuilder: (context, i) => Separator(),
            itemCount: workers.length,
            itemBuilder: (context, i) {
              final data = workers[i];
              if (data.mode == WorkerType.all) {
                return WorkerItem(
                  multiSelect: widget.multiSelect,
                  isSelected: state.isAllWorkers,
                  onChanged: (employee, selected) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _selectBloc.add(SelectAllWorkers(
                      allWorkers: List.from(workers),
                      isSelected: selected,
                    ));
                  },
                  worker: data,
                );
              }

              final child = WorkerItem(
                multiSelect: widget.multiSelect,
                isSelected: selectedWorkers.contains(data.id),
                onChanged: (worker, selected) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (!widget.multiSelect) {
                    Navigator.of(context).pop([worker]);
                  } else {
                    _selectBloc.add(
                        SelectEmployee(workers: worker, isSelected: selected));
                  }
                },
                worker: data,
              );
              if (i == workers.length - 1) {
                return Column(
                  children: <Widget>[
                    child,
                    SectionHeader(
                      padding: const EdgeInsets.only(top: 8),
                    ),
                  ],
                );
              }

              return child;
            },
          );
        },
      );
    }

    if (searchState is WorkerSearchError) {
      return ErrorView(error: searchState.error);
    }

    if (searchState is WorkerSearchLoading) {
      return LoadingIndicator();
    }

    return Container();
  }
}
