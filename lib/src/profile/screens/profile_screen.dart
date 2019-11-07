import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/api/models/authentication.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/contact/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/reset_password/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/widgets/separator.dart';
import 'package:yodel/src/shift/widgets/widgets.dart';
import 'package:yodel/src/theme/themes.dart';
import 'package:provider/provider.dart';

const double _kMenuHeight = 120;

class ProfileScreen extends StatelessWidget
    with PostBuildActionMixin, OpenUrlMixin {
  final format = DateFormat("dd MMMM yyyy");

  ProfileScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: YodelTheme.tealish,
      ),
      child: StreamBuilder<Session>(
        stream: authBloc.sessionTracker.session,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingIndicator();
          }

          final user = snapshot.data?.userData;

          return BlocProvider<ProfileBloc>(
            builder: (context) => ProfileBloc(
              authBloc: BlocProvider.of<AuthenticationBloc>(context),
            ),
            child: Consumer<ProfileBloc>(
              builder: (context, bloc, child) {
                return WillPopScope(
                  onWillPop: () {
                    return Future.value(false);
                  },
                  child: SafeArea(
                    child: DefaultTabController(
                      length: 2,
                      initialIndex: 0,
                      child: Scaffold(
                        backgroundColor: YodelTheme.lightPaleGrey,
                        appBar: _buildAppBar(context, bloc, authBloc, user),
                        body: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoading) {
                              return LoadingIndicator();
                            }

                            return TabBarView(
                              children: <Widget>[
                                RefreshIndicator(
                                  onRefresh: () async =>
                                      bloc.add(SyncProfile()),
                                  child: ListView(
                                    key: PageStorageKey(0),
                                    children: <Widget>[
                                      ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        title: Text("Phone number",
                                            style:
                                                YodelTheme.metaRegularInactive),
                                        subtitle: Text(
                                          user.phone ?? "-",
                                          style:
                                              YodelTheme.bodyDefault.copyWith(
                                            color: YodelTheme.darkGreyBlue,
                                          ),
                                        ),
                                      ),
                                      Separator(),
                                      ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        title: Text("Email address",
                                            style:
                                                YodelTheme.metaRegularInactive),
                                        subtitle: Text(
                                          user.email,
                                          style:
                                              YodelTheme.bodyDefault.copyWith(
                                            color: YodelTheme.darkGreyBlue,
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
                                              style: YodelTheme
                                                  .metaRegularInactive),
                                          subtitle: user.rate != null
                                              ? Text(
                                                  "\$${user.hourlyRate} p/hr",
                                                  style: YodelTheme.bodyDefault
                                                      .copyWith(
                                                    color:
                                                        YodelTheme.darkGreyBlue,
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
                                            style:
                                                YodelTheme.metaRegularInactive),
                                        subtitle: Text(
                                          user.dateOfBirth != null
                                              ? format.format(DateTime.tryParse(
                                                  user.dateOfBirth))
                                              : "-",
                                          style:
                                              YodelTheme.bodyDefault.copyWith(
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
                                              onChanged: (site, _) {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SiteDetailsScreen(
                                                      site: site,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (site.id != user.siteIds.last)
                                              Separator(),
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
                                      bloc.add(SyncProfile()),
                                  child: ListView(
                                    key: PageStorageKey(1),
                                    children: <Widget>[
                                      ...user.skills.map((skill) {
                                        return Column(
                                          children: <Widget>[
                                            SkillItem(
                                              skill: skill,
                                            ),
                                            if (skill.id != user.skillIds.last)
                                              Separator(),
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
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ProfileBloc bloc,
      AuthenticationBloc authBloc, UserData user) {
    return YodelAppBar(
      leadingWidth: 300,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      leading: NavbarButton(
        alignment: Alignment.centerLeft,
        style: YodelTheme.bodyActive.copyWith(color: YodelTheme.tealish),
        highlightedStyle: YodelTheme.bodyActive
            .copyWith(color: YodelTheme.tealish.withOpacity(0.8)),
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(
          "Edit details",
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider<ProfileBloc>.value(
                value: bloc,
                child: EditProfileDetailsScreen(),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        StreamBuilder<bool>(
            initialData: false,
            stream: bloc.menuEnabled,
            builder: (context, snapshot) {
              return BubbleTooltip(
                onClose: () {
                  bloc.enableMenu(false);
                },
                showTooltip: snapshot.data,
                arrowTipDistance: 10.0,
                arrowBaseWidth: 25,
                arrowLength: 15,
                borderWidth: 0,
                minimumOutSidePadding: 16,
                borderRadius: 10,
                touchThroughAreaShape: ClipAreaShape.rectangle,
                outsideBackgroundColor: YodelTheme.shadow.withOpacity(0.32),
                popupDirection: TooltipDirection.down,
                borderColor: Colors.transparent,
                shadows: [
                  BoxShadow(
                    blurRadius: 4,
                    color: YodelTheme.shadow.withOpacity(0.32),
                    offset: Offset(0, 1),
                  )
                ],
                content: Container(
                    width: 200,
                    height: _kMenuHeight,
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16.0),
                            child: LinkButton(
                              alignment: Alignment.centerLeft,
                              onPressed: () async {
                                bloc.enableMenu(false);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangePasswordScreen(),
                                  ),
                                );
                              },
                              style: YodelTheme.bodyActive,
                              disabledStyle: YodelTheme.bodyInactive,
                              highlightStyle: YodelTheme.bodyActive.copyWith(
                                  color: Colors.redAccent.withOpacity(0.8)),
                              child: Text(
                                "Reset password",
                              ),
                            ),
                          ),
                        ),
                        Separator(),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16.0),
                            child: LinkButton(
                              alignment: Alignment.centerLeft,
                              onPressed: () async {
                                bloc.enableMenu(false);
                                authBloc.add(Loggedout());
                              },
                              style: YodelTheme.bodyActive,
                              disabledStyle: YodelTheme.bodyInactive,
                              highlightStyle: YodelTheme.bodyActive.copyWith(
                                  color: YodelTheme.bodyActive.color
                                      .withOpacity(0.8)),
                              child: Text(
                                "Log out",
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                child: IconLinkButton(
                    icon: Icon(YodelIcons.moreactions),
                    color: YodelTheme.tealish,
                    highlightColor: YodelTheme.tealish.withOpacity(0.8),
                    disabledColor: YodelTheme.lightGreyBlue,
                    onPressed: () {
                      bloc.enableMenu(!snapshot.data);
                    }),
              );
            })
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(100 + kTextTabBarHeight),
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
                    InkResponse(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                BlocProvider<ProfileBloc>.value(
                              value: bloc,
                              child: EditProfilePicScreen(),
                            ),
                          ),
                        );
                      },
                      highlightShape: BoxShape.circle,
                      child: Stack(
                        children: <Widget>[
                          ClipOval(
                            child: Ink(
                              width: 64,
                              height: 64,
                              child: user.profilePhoto != null
                                  ? CachedNetworkImage(
                                      imageUrl: ImageHelper.toImageUrl(
                                        user.profilePhoto,
                                        width: 200,
                                        height: 200,
                                      ),
                                      placeholder: (context, url) {
                                        return SvgPicture.asset(
                                          YodelImages.profilePlaceHolder,
                                        );
                                      },
                                      errorWidget: (context, url, error) {
                                        return SvgPicture.asset(
                                          YodelImages.profilePlaceHolder,
                                        );
                                      },
                                    )
                                  : SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: SvgPicture.asset(
                                        YodelImages.profilePlaceHolder,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            width: 24,
                            height: 24,
                            bottom: 0,
                            right: 0,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: FractionalTranslation(
                                translation: Offset(-0.1, -0.1),
                                child: Icon(
                                  YodelIcons.update_photo,
                                  color: YodelTheme.tealish,
                                  size: 10,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${user.fullName}",
                            style: YodelTheme.mainTitle
                                .copyWith(color: Colors.white, fontSize: 20),
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
                  indicatorColor: YodelTheme.tealish,
                  indicatorWeight: 4.0,
                  unselectedLabelColor: YodelTheme.lightGreyBlue,
                  indicatorPadding:
                      EdgeInsets.only(left: 9.0, right: 9.0, top: 0, bottom: 0),
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
    );
  }
}
