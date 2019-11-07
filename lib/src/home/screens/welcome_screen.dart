import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/contact/index.dart';
import 'package:yodel/src/home/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/widgets/separator.dart';
import 'package:yodel/src/shift/widgets/widgets.dart';
import 'package:yodel/src/theme/themes.dart';

class WelcomeScreen extends StatelessWidget with PostBuildActionMixin {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CompanyBloc>(context);
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    final user = authBloc.sessionTracker.currentSession.userData;

    return WillPopScope(
      onWillPop: () async {
        await sl<AppService>().minimise();
        return Future.value(false);
      },
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0.0,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60 + kTextTabBarHeight),
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
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Welcome to Yodel!",
                        style: YodelTheme.mainTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "You’re now all set up to use Yodel. The following information has been assigned to you.",
                        style: YodelTheme.metaWhite,
                      ),
                      SizedBox(
                        height: 16,
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
            body: BlocListener(
              bloc: bloc,
              listener: (context, CompanyState state) {
                if (state is InitialCompanyState) {
                  bloc.add(Fetch());
                }

                if (state is CompanyError) {
                  showErrorOnPostBuild(context, state.error);
                }
              },
              child: BlocBuilder(
                bloc: bloc,
                builder: (BuildContext context, CompanyState state) {
                  if (state is CompanyLoading) {
                    return LoadingIndicator();
                  }

                  if (state is CompanyLoaded) {
                    return Stack(
                      children: <Widget>[
                        TabBarView(
                          children: <Widget>[
                            ListView(
                              key: PageStorageKey(0),
                              children: <Widget>[
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  title: Text("Role",
                                      style: YodelTheme.metaRegularInactive),
                                  subtitle: Text(
                                    user.role,
                                    style: YodelTheme.bodyDefault.copyWith(
                                      color: YodelTheme.darkGreyBlue,
                                    ),
                                  ),
                                ),
                                if (user.isWorker) Separator(),
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
                                            style:
                                                YodelTheme.bodyDefault.copyWith(
                                              color: YodelTheme.darkGreyBlue,
                                            ),
                                          )
                                        : null,
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
                            ListView(
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
                            )
                          ],
                        ),
                        Positioned(
                          width: MediaQuery.of(context).size.width,
                          height: 132,
                          bottom: 0,
                          child: Container(
                            color: YodelTheme.darkGreyBlue,
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                    "Please contact your site admin/manager if you require any changes to be made.",
                                    style: YodelTheme.metaWhite),
                                SizedBox(
                                  height: 10,
                                ),
                                ProgressButton(
                                  child: Text("Continue to Yodel",
                                      style: YodelTheme.bodyStrong),
                                  color: YodelTheme.amber,
                                  width: double.infinity,
                                  onPressed: () {
                                    authBloc.add(WelcomeUser());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
