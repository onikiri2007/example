import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/contact/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/widgets/separator.dart';
import 'package:yodel/src/shift/widgets/widgets.dart';
import 'package:yodel/src/theme/themes.dart';

class ContactDetailsScreen extends StatefulWidget
    with PostBuildActionMixin, OpenUrlMixin {
  final int id;
  final String title;
  ContactDetailsScreen({
    Key key,
    @required this.id,
    this.title = "Contacts",
  })  : assert(id != null),
        super(key: key);

  @override
  _ContactDetailsScreenState createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen>
    with OpenUrlMixin {
  final format = DateFormat("dd MMMM yyyy");
  ContactBloc _bloc;

  @override
  void initState() {
    _bloc = ContactBloc();

    _bloc.add(FetchContactDetails(
      widget.id,
    ));

    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, ContactState state) {
        if (state is ContactLoading || state is InitialContactState) {
          return LoadingIndicator();
        }

        if (state is ContactError) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                automaticallyImplyLeading: false,
                title: Text(
                  widget.title,
                  style: YodelTheme.bodyWhite,
                ),
                leading: OverflowBox(
                  maxWidth: 90.0,
                  child: NavbarButton(
                      padding: const EdgeInsets.only(left: 16.0),
                      style: YodelTheme.bodyDefault.copyWith(
                        color: YodelTheme.amber,
                      ),
                      highlightedStyle: YodelTheme.bodyDefault.copyWith(
                        color: YodelTheme.amber.withOpacity(0.8),
                      ),
                      child: Text(
                        "Back",
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              ),
              body: ErrorView(error: state.error),
            ),
          );
        }

        if (state is ContactLoaded) {
          final user = state.user;
          return SafeArea(
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Scaffold(
                backgroundColor: YodelTheme.lightPaleGrey,
                appBar: AppBar(
                  elevation: 0.0,
                  automaticallyImplyLeading: false,
                  title: Text(
                    widget.title,
                    style: YodelTheme.bodyWhite,
                  ),
                  leading: OverflowBox(
                    maxWidth: 90.0,
                    child: NavbarButton(
                        padding: const EdgeInsets.only(left: 16.0),
                        style: YodelTheme.bodyDefault.copyWith(
                          color: YodelTheme.amber,
                        ),
                        highlightedStyle: YodelTheme.bodyDefault.copyWith(
                          color: YodelTheme.amber.withOpacity(0.8),
                        ),
                        child: Text(
                          "Back",
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(80 + kTextTabBarHeight),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: YodelTheme.darkGreyBlue.withOpacity(0.16),
                            offset: Offset(0, 1),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: <Widget>[
                                Ink(
                                  child: Stack(
                                    children: <Widget>[
                                      ClipOval(
                                        child: Container(
                                          width: 64,
                                          height: 64,
                                          child: user.profilePhoto != null
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      ImageHelper.toImageUrl(
                                                    user.profilePhoto,
                                                    width: 200,
                                                    height: 200,
                                                  ),
                                                  placeholder: (context, url) {
                                                    return SvgPicture.asset(
                                                      YodelImages
                                                          .profilePlaceHolder,
                                                    );
                                                  },
                                                  errorWidget:
                                                      (context, url, error) {
                                                    return SvgPicture.asset(
                                                      YodelImages
                                                          .profilePlaceHolder,
                                                    );
                                                  },
                                                )
                                              : SizedBox(
                                                  width: 80,
                                                  height: 80,
                                                  child: SvgPicture.asset(
                                                    YodelImages
                                                        .profilePlaceHolder,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: MediaQuery.of(context).size.width -
                                          64 -
                                          16 -
                                          16 -
                                          20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "${user.fullName}",
                                        style: YodelTheme.mainTitle.copyWith(
                                            color: Colors.white, fontSize: 20),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        user.role,
                                        style: YodelTheme.metaWhite,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: YodelTheme.lightPaleGrey,
                            height: 1,
                          ),
                          SizedBox(
                            height: kTextTabBarHeight,
                            child: TabBar(
                              labelPadding: EdgeInsets.only(top: 10),
                              labelColor: Colors.white,
                              indicatorWeight: 4.0,
                              unselectedLabelColor: YodelTheme.lightGreyBlue,
                              indicatorPadding: EdgeInsets.only(
                                  left: 9.0, right: 9.0, top: 0, bottom: 0),
                              labelStyle: YodelTheme.tabFilterActive,
                              unselectedLabelStyle: YodelTheme.tabFilterDefault,
                              tabs: [
                                Tab(
                                  text: "Info",
                                ),
                                Tab(text: "Skills"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  children: <Widget>[
                    RefreshIndicator(
                      onRefresh: () async =>
                          _bloc.add(FetchContactDetails(widget.id)),
                      child: ListView(
                        key: PageStorageKey(0),
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text("Phone number",
                                style: YodelTheme.metaRegularInactive),
                            subtitle: Text(
                              user.phone ?? "-",
                              style: YodelTheme.bodyDefault,
                            ),
                            trailing: SizedBox(
                              width: 160,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  IconButton(
                                    color: YodelTheme.iris,
                                    iconSize: 30,
                                    icon: Icon(YodelIcons.contact_sms),
                                    onPressed: user?.phone != null
                                        ? () {
                                            openSms(user.phone);
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    color: YodelTheme.iris,
                                    iconSize: 30,
                                    icon: Icon(YodelIcons.contact_call),
                                    onPressed: user?.phone != null
                                        ? () {
                                            openTel(user.phone);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Separator(),
                          ListTile(
                            onTap: () async {
                              await openMail(user.email);
                            },
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text("Email address",
                                style: YodelTheme.metaRegularInactive),
                            subtitle: Text(
                              user.email,
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.iris,
                              ),
                            ),
                          ),
                          Separator(),
                          if (user.isWorker)
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text("Hourly rate",
                                  style: YodelTheme.metaRegularInactive),
                              subtitle: user.rate != null
                                  ? Text(
                                      "\$${user.hourlyRate} p/hr",
                                      style: YodelTheme.bodyDefault.copyWith(
                                        color: YodelTheme.darkGreyBlue,
                                      ),
                                    )
                                  : null,
                            ),
                          if (user.isWorker) Separator(),
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text("Date of birth",
                                style: YodelTheme.metaRegularInactive),
                            subtitle: Text(
                              user.dateOfBirth != null
                                  ? format.format(
                                      DateTime.tryParse(user.dateOfBirth))
                                  : "-",
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.darkGreyBlue,
                              ),
                            ),
                          ),
                          SectionHeader(
                            child: Text(
                              "Sites",
                              style: YodelTheme.metaRegular,
                            ),
                          ),
                          ...user.sites.map((site) {
                            return Column(
                              children: <Widget>[
                                SiteItem(
                                  site: site,
                                  backgroundColor: Colors.white,
                                  onChanged: (site, _) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SiteDetailsScreen(
                                          site: site,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (site != user.sites.last) Separator(),
                              ],
                            );
                          }).toList(),
                          SectionHeader(
                            padding: const EdgeInsets.only(top: 8),
                          ),
                          SizedBox(
                            height: 132,
                          )
                        ],
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: () async =>
                          _bloc.add(FetchContactDetails(widget.id)),
                      child: ListView(
                        key: PageStorageKey(1),
                        children: <Widget>[
                          ...user.skills.map((skill) {
                            return Column(
                              children: <Widget>[
                                SkillItem(
                                  skill: skill,
                                ),
                                if (skill != user.skills.last) Separator(),
                              ],
                            );
                          }).toList(),
                          SectionHeader(
                            padding: const EdgeInsets.only(top: 8),
                          ),
                          SizedBox(
                            height: 132,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
