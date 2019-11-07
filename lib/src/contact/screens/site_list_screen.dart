import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/contact/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class SitesScreen extends StatefulWidget {
  SitesScreen({
    Key key,
  }) : super(key: key);

  _SitesScreenState createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> with PostBuildActionMixin {
  TextEditingController searchTextController;
  SiteSearchBloc _bloc;

  @override
  void initState() {
    searchTextController = TextEditingController();
    _bloc = SiteSearchBloc();
    _bloc.add(
      SearchSites(),
    );
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: KeyboardDismissable(
        child: Scaffold(
          backgroundColor: YodelTheme.lightPaleGrey,
          body: BlocBuilder(
            bloc: _bloc,
            builder: (context, SiteSearchState state) {
              if (state is SiteSearchNoTerm) {
                return LoadingIndicator();
              }

              return CustomScrollView(
                  slivers: _buildSlivers(
                context,
                state,
              ));
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, SiteSearchState state) {
    List<Widget> slivers = [
      SliverAppBar(
        title: Text("Sites", style: YodelTheme.bodyWhite),
        centerTitle: true,
        pinned: true,
        leading: OverflowBox(
          maxWidth: 90.0,
          child: NavbarButton(
            style: YodelTheme.bodyDefault.copyWith(
              color: YodelTheme.tealish,
            ),
            highlightedStyle: YodelTheme.bodyDefault.copyWith(
              color: YodelTheme.tealish.withOpacity(0.8),
            ),
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
                ));
              },
              controller: searchTextController,
              hintText: "Search",
            ),
          ),
          preferredSize: Size.fromHeight(66),
        ),
      ),
    ];

    if (state is SiteSearchError) {
      slivers.add(SliverFillRemaining(
        child: ErrorView(error: state.error),
      ));
    } else if (state is SiteSearchLoading) {
      slivers.add(
        SliverFillRemaining(
          child: LoadingIndicator(),
        ),
      );
    } else if (state is SiteSearchSuccess) {
      Map<String, List<Site>> map = {};
      state.sites.forEach((site) {
        final v = site.name.substring(0, 1);
        map.update(v, (s) => s..add(site), ifAbsent: () => [site]);
      });

      int index = 0;
      final keys = map.keys.toList();
      keys.sort();
      keys.forEach((key) {
        final widget = _buildSliverBuilderLists(context, key, index, map[key]);
        index++;
        slivers.add(widget);
      });
    } else {
      slivers.add(SliverFillRemaining(
        child: Container(),
      ));
    }

    return slivers;
  }

  Widget _buildSliverBuilderLists(
      BuildContext context, String stringIndex, int index, List<Site> sites) {
    return SliverStickyHeaderBuilder(
      builder: (context, state) => SectionHeader(
        child: Text(
          stringIndex,
          style: YodelTheme.metaRegular,
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final child = SiteItem(
              onChanged: (site, _) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SiteDetailsScreen(
                      site: site,
                    ),
                  ),
                );
              },
              site: sites[i],
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
            } else {
              return Column(
                children: <Widget>[child, Separator()],
              );
            }
          },
          childCount: sites.length,
        ),
      ),
    );
  }
}
