import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/contact/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class ContactsScreen extends StatefulWidget {
  ContactsScreen({
    Key key,
  }) : super(key: key);

  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with PostBuildActionMixin {
  TextEditingController searchTextController;
  ContactsBloc _bloc;

  @override
  void initState() {
    searchTextController = TextEditingController();
    _bloc = ContactsBloc();
    _bloc.add(
      FetchContacts(),
    );
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    _bloc.close();
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
            builder: (context, ContactsState state) {
              if (state is ContactsLoading) {
                return LoadingIndicator();
              }

              return StreamBuilder<List<Contact>>(
                  initialData: [],
                  stream: _bloc.contacts,
                  builder: (context, snapshot) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _bloc.add(FetchContacts());
                      },
                      displacement: 20,
                      child: CustomScrollView(
                          slivers: _buildSlivers(
                        context,
                        state,
                        snapshot.hasData ? snapshot.data : [],
                      )),
                    );
                  });
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(
      BuildContext context, ContactsState state, List<Contact> contacts) {
    List<Widget> slivers = [
      SliverAppBar(
        title: Text("Contacts", style: YodelTheme.bodyWhite),
        centerTitle: true,
        pinned: true,
        leading: OverflowBox(
          maxWidth: 90.0,
          child: NavbarButton(
            style: YodelTheme.bodyDefault.copyWith(
              color: YodelTheme.amber,
            ),
            highlightedStyle: YodelTheme.bodyDefault.copyWith(
              color: YodelTheme.amber.withOpacity(0.8),
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
        actions: <Widget>[
          NavbarButton(
            style: YodelTheme.bodyDefault.copyWith(
              color: YodelTheme.amber,
            ),
            highlightedStyle: YodelTheme.bodyDefault.copyWith(
              color: YodelTheme.amber.withOpacity(0.8),
            ),
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              "Invite user",
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InviteUserScreen(),
                  ));
            },
          ),
        ],
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchField(
              autofocus: false,
              onQueryChanged: _bloc.onQueryChanaged,
              onClear: () {
                _bloc.onQueryChanaged("");
              },
              controller: searchTextController,
              hintText: "Search",
            ),
          ),
          preferredSize: Size.fromHeight(66),
        ),
      ),
    ];

    if (state is ContactsError) {
      slivers.add(SliverFillRemaining(
        child: ErrorView(error: state.error),
      ));
    } else if (state is ContactsLoading) {
      slivers.add(
        SliverFillRemaining(
          child: LoadingIndicator(),
        ),
      );
    }

    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    final sites = [...authBloc.sessionTracker?.currentSession?.userData?.sites];

    sites.insert(
        0,
        Site(
          id: 0,
          name: "All sites",
        ));
    final double height = 60.0 * sites.length;
    slivers.add(SliverList(
      delegate: SliverChildListDelegate([
        StreamBuilder<int>(
            initialData: _bloc.currentFilter,
            stream: _bloc.siteFilter,
            builder: (context, snapshot) {
              Site selected = sites.firstWhere((s) => s.id == snapshot.data,
                  orElse: () => sites[0]);
              return Ink(
                color: Colors.white,
                child: ListTile(
                  onTap: () async {
                    final site = await showDialog<Site>(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return Dialog(
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SizedBox(
                              height: height,
                              child: ListView.separated(
                                itemBuilder: (context, i) {
                                  final site = sites[i];
                                  return ListTile(
                                    onTap: () {
                                      Navigator.pop(context, site);
                                    },
                                    title: Text(
                                      site.name,
                                      style: YodelTheme.bodyDefault,
                                    ),
                                  );
                                },
                                separatorBuilder: (context, i) {
                                  return Separator();
                                },
                                itemCount: sites.length,
                              ),
                            ),
                          );
                        });
                    if (site != null) {
                      _bloc.onFilterChanged(site.id);
                    }
                  },
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text("View contacts from",
                      style: YodelTheme.metaRegularInactive),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(selected.name, style: YodelTheme.bodyDefault),
                      Text(
                        "Change site",
                        textAlign: TextAlign.end,
                        style: YodelTheme.metaRegularActive
                            .copyWith(color: YodelTheme.iris),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ]),
    ));

    Map<String, List<Worker>> map = {};
    contacts.forEach((contact) {
      final v = contact.fullName.substring(0, 1);

      final worker = Worker(
        id: contact.id,
        name: contact.fullName,
        imagePath: contact.profilePhoto,
      );
      map.update(v, (s) => s..add(worker), ifAbsent: () => [worker]);
    });

    int index = 0;
    final keys = map.keys.toList();
    keys.sort();
    keys.forEach((key) {
      List<Worker> workers = List.from(map[key]);
      workers.sort((w1, w2) => w1.name.compareTo(w2.name));
      final widget = _buildSliverBuilderLists(context, key, index, map[key]);
      index++;
      slivers.add(widget);
    });

    return slivers;
  }

  Widget _buildSliverBuilderLists(
      BuildContext context, String stringIndex, int index, List<Worker> users) {
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
            final child = WorkerItem(
              onChanged: (worker, _) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ContactDetailsScreen(
                      id: worker.id,
                    ),
                  ),
                );
              },
              worker: users[i],
            );

            if (i == users.length - 1) {
              return child;
            } else {
              return Column(
                children: <Widget>[child, Separator()],
              );
            }
          },
          childCount: users.length,
        ),
      ),
    );
  }
}
