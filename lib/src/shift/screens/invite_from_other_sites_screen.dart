import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class InviteFromOtherSitesScreen extends StatefulWidget {
  final bool multiSelect;
  final List<Site> selected;
  final Widget title;
  final Widget header;
  final Site location;

  InviteFromOtherSitesScreen({
    Key key,
    this.title,
    @required this.header,
    this.location,
    this.multiSelect = false,
    this.selected = const [],
  })  : assert(header != null),
        super(key: key);

  _InviteFromOtherSitesScreenState createState() =>
      _InviteFromOtherSitesScreenState();
}

class _InviteFromOtherSitesScreenState extends State<InviteFromOtherSitesScreen>
    with SessionProviderMixin, PostBuildActionMixin {
  TextEditingController searchTextController;
  SiteSearchBloc _bloc;
  SiteSelectBloc _selectBloc;

  @override
  void initState() {
    searchTextController = TextEditingController();
    _selectBloc = SiteSelectBloc(
      selectedSites: widget.selected,
      currentLocation: widget.location,
    );

    _bloc = SiteSearchBloc();
    _bloc.add(SiteSearchStarted(
      currentLocation: widget.location,
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
    final _shiftBloc = BlocProvider.of<ManageShiftBloc>(context);

    return SafeArea(
      child: KeyboardDismissable(
        child: Scaffold(
          appBar: AppBar(
            title: widget.title,
            centerTitle: true,
            leading: OverflowBox(
              maxWidth: 90.0,
              child: NavbarButton(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Close",
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchField(
                  autofocus: false,
                  onQueryChanged: (val) {
                    _bloc.add(
                      SearchSites(
                        query: val,
                      ),
                    );
                  },
                  onClear: () {
                    _bloc.add(SearchSites(
                      query: "",
                      currentLocation: widget.location,
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
                        bloc: _shiftBloc,
                        builder: (context, ManageShiftState shiftState) {
                          return BlocBuilder(
                            bloc: _selectBloc,
                            builder: (context, SiteSelectState state) {
                              return NavbarButton(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  "Invite",
                                ),
                                onPressed: state.selectedSites.length > 0 &&
                                        shiftState is! ManageShiftActionLoading
                                    ? () {
                                        _shiftBloc
                                            .add(InviteFromOtherSites(
                                          shiftId: _shiftBloc.currentShift.id,
                                          sites: state.selectedSites,
                                        ));
                                      }
                                    : null,
                              );
                            },
                          );
                        })
                  ]
                : null,
          ),
          body: BlocListener(
            bloc: _shiftBloc,
            listener: (context, state) {
              if (state is ManageShiftError) {
                _shiftBloc.add(ResetShiftActionResult());
                showErrorOnPostBuild(context, state.error);
              }

              if (state is ManageShiftLoaded) {
                if (state.actionResult == ManageShiftActionResult.success &&
                    state.action == ManageShiftAction.inviteFromOtherSite)
                  showSuccessOnPostBuild(context, state.actionMessage,
                      callback: () {
                    _shiftBloc.add(ResetShiftActionResult());
                    Navigator.pop(context);
                  });
              }
            },
            child: BlocBuilder(
                bloc: _shiftBloc,
                builder: (context, ManageShiftState shiftState) {
                  if (shiftState is ManageShiftActionLoading) {
                    return LoadingIndicator();
                  }

                  return BlocBuilder(
                    bloc: _bloc,
                    builder: (context, SiteSearchState state) {
                      if (state is SiteSearchNoTerm) {
                        return LoadingIndicator();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SectionHeader(
                            child: widget.header,
                          ),
                          Expanded(
                            child: _buildSearchResults(state),
                          ),
                        ],
                      );
                    },
                  );
                }),
          ),
        ),
      ),
    );
  }

  _buildSearchResults(SiteSearchState searchState) {
    if (searchState is SiteSearchSuccess) {
      return BlocBuilder(
        bloc: _selectBloc,
        builder: (context, SiteSelectState state) {
          final invitedSites = widget.selected.map((s) => s.id).toList();
          final selectedSiteIds = state.selected.map((s) => s.id).toList();
          final sites = searchState.sites;
          return ListView.separated(
            separatorBuilder: (context, i) => Container(
                  width: double.infinity,
                  height: 1,
                  color: YodelTheme.paleGrey,
                ),
            itemCount: sites.length,
            itemBuilder: (context, i) => SiteItem(
                  multiSelect: widget.multiSelect,
                  activeColor: invitedSites.contains(sites[i].id)
                      ? YodelTheme.lightGreyBlue
                      : YodelTheme.iris,
                  isSelected: selectedSiteIds.contains(sites[i].id) ||
                      invitedSites.contains(sites[i].id),
                  site: sites[i],
                  onChanged: invitedSites.contains(sites[i].id)
                      ? null
                      : (site, selected) {
                          _selectBloc.add(
                              SelectSite(site: site, isSelected: selected));
                        },
                  trailingBuilder: (context, site) {
                    if (invitedSites.contains(site.id)) {
                      return Container(
                        width: 120,
                        height: 60,
                        alignment: Alignment.centerRight,
                        child: LinkButton(
                          highlightStyle: YodelTheme.metaRegularManage.copyWith(
                            color: YodelTheme.amber.withOpacity(0.8),
                          ),
                          style: YodelTheme.metaRegularManage,
                          child: Text(
                            "Invited",
                            textAlign: TextAlign.right,
                          ),
                          onPressed: () async {
                            final url = UrlHelper.getMapUrl(
                                address: site.address,
                                lat: site.latitude,
                                long: site.longitude);
                            if (await canLaunch(url)) {
                              await launch(url);
                            }
                          },
                        ),
                      );
                    } else {
                      return Text(
                        site.distanceKm != null ? "${site.distanceKm}km" : "",
                        style: YodelTheme.metaDefaultInactive,
                        textAlign: TextAlign.right,
                      );
                    }
                  },
                ),
          );
        },
      );
    }

    if (searchState is SiteSearchError) {
      return Text(searchState.error);
    }

    if (searchState is SiteSearchEmpty) {
      return Text("data is empty");
    }

    if (searchState is SiteSearchLoading) {
      return LoadingIndicator();
    }

    return Container();
  }
}
