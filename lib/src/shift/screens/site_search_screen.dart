import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

enum SiteSelectionMode {
  SiteLocation,
  ShiftLocation,
}

class SiteSearchScreen extends StatefulWidget {
  final bool multiSelect;
  final List<Site> selected;
  final Site location;
  final Widget title;
  final SiteSelectionMode mode;
  final Widget header;

  SiteSearchScreen({
    Key key,
    this.title,
    @required this.header,
    this.multiSelect = false,
    this.location,
    this.selected = const [],
    this.mode = SiteSelectionMode.ShiftLocation,
  })  : assert(header != null),
        super(key: key);

  _SiteSearchScreenState createState() => _SiteSearchScreenState();
}

class _SiteSearchScreenState extends State<SiteSearchScreen>
    with SessionProviderMixin {
  TextEditingController searchTextController;
  SiteSearchBloc _bloc;
  SiteSelectBloc _selectBloc;

  @override
  void initState() {
    searchTextController = TextEditingController();
    _selectBloc = SiteSelectBloc(
      currentLocation: widget.location,
      selectedSites: widget.selected,
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
    return SafeArea(
      child: KeyboardDismissable(
        child: Scaffold(
          backgroundColor: YodelTheme.lightPaleGrey,
          appBar: AppBar(
            title: widget.title,
            centerTitle: true,
            leading: OverflowBox(
              maxWidth: 90.0,
              child: NavbarButton(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Back",
                ),
                onPressed: () {
                  Navigator.pop(context, _selectBloc.selectedSites);
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
                        currentLocation: widget.location,
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
                      bloc: _selectBloc,
                      builder: (context, SiteSelectState state) {
                        return NavbarButton(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            "Done",
                          ),
                          onPressed: state.selectedSites.length > 0
                              ? () {
                                  Navigator.pop(context, state.selected);
                                }
                              : null,
                        );
                      },
                    )
                  ]
                : null,
          ),
          body: BlocBuilder(
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
          final selectedSiteIds = state.selectedSites.map((s) => s.id).toList();
          final sites = searchState.sites;
          return ListView.separated(
              separatorBuilder: (context, i) => Container(
                    width: double.infinity,
                    height: 1,
                    color: YodelTheme.paleGrey,
                  ),
              itemCount: sites.length,
              itemBuilder: (context, i) {
                final child = SiteItem(
                  multiSelect: widget.multiSelect,
                  isSelected: selectedSiteIds.contains(sites[i].id),
                  onChanged: (site, selected) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (!widget.multiSelect) {
                      Navigator.of(context).maybePop([site]);
                    } else {
                      _selectBloc
                          .add(SelectSite(site: site, isSelected: selected));
                    }
                  },
                  site: sites[i],
                  trailingBuilder: (context, site) {
                    if (widget.mode == SiteSelectionMode.SiteLocation) {
                      if (session.siteIds.contains(site.id)) {
                        return Container(
                          width: 120,
                          alignment: Alignment.center,
                          child: LinkButton(
                              highlightStyle:
                                  YodelTheme.metaRegularManage.copyWith(
                                color: YodelTheme.amber.withOpacity(0.8),
                              ),
                              style: YodelTheme.metaRegularManage,
                              onPressed: () async {
                                final url = UrlHelper.getMapUrl(
                                    address: site.address,
                                    lat: site.latitude,
                                    long: site.longitude);
                                if (await canLaunch(url)) {
                                  await launch(url);
                                }
                              },
                              child: Text(
                                "Your store",
                                textAlign: TextAlign.right,
                              )),
                        );
                      } else {
                        return SizedBox(
                          width: 75,
                        );
                      }
                    } else {
                      if (widget.location == null) {
                        return null;
                      }

                      if (widget.location.id == site.id) {
                        return Container(
                          width: 120,
                          height: 60,
                          alignment: Alignment.centerRight,
                          child: LinkButton(
                            highlightStyle:
                                YodelTheme.metaRegularManage.copyWith(
                              color: YodelTheme.amber.withOpacity(0.8),
                            ),
                            style: YodelTheme.metaRegularManage,
                            child: Text(
                              "Shift location",
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
                    }
                  },
                );

                if (i == sites.length - 1) {
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
              });
        },
      );
    }

    if (searchState is SiteSearchError) {
      return ErrorView(error: searchState.error);
    }

    if (searchState is SiteSearchLoading) {
      return LoadingIndicator();
    }

    return Container();
  }
}
