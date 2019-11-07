import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/home/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/widgets/separator.dart';
import 'package:yodel/src/shift/widgets/widgets.dart';
import 'package:yodel/src/theme/themes.dart';

class SiteDetailsScreen extends StatefulWidget {
  final Site site;

  SiteDetailsScreen({
    Key key,
    @required this.site,
  })  : assert(site != null),
        super(key: key);

  @override
  _SiteDetailsScreenState createState() => _SiteDetailsScreenState();
}

class _SiteDetailsScreenState extends State<SiteDetailsScreen>
    with PostBuildActionMixin, OpenUrlMixin {
  CompanyBloc _companyBloc;
  @override
  void initState() {
    _companyBloc = BlocProvider.of<CompanyBloc>(context);
    _companyBloc.add(Fetch());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _companyBloc,
        builder: (context, CompanyState state) {
          if (state is CompanyLoading) {
            return SafeArea(
                child: Scaffold(
              body: LoadingIndicator(),
            ));
          }

          Site site = widget.site;

          if (state is CompanyLoaded) {
            site = state.data.sites.firstWhere((s) => s.id == widget.site.id,
                orElse: () => widget.site);
          }

          return SafeArea(
            child: Scaffold(
              backgroundColor: YodelTheme.lightPaleGrey,
              appBar: AppBar(
                elevation: 0.0,
                automaticallyImplyLeading: false,
                leading: OverflowBox(
                  maxWidth: 90.0,
                  child: NavbarButton(
                      padding: const EdgeInsets.only(left: 16.0),
                      style: YodelTheme.bodyDefault.copyWith(
                        color: YodelTheme.tealish,
                      ),
                      highlightedStyle: YodelTheme.bodyDefault.copyWith(
                        color: YodelTheme.tealish.withOpacity(0.8),
                      ),
                      child: Text(
                        "Back",
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(80),
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
                              ClipOval(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  child: site.imagePath != null
                                      ? CachedNetworkImage(
                                          imageUrl: ImageHelper.toImageUrl(
                                            site.imagePath,
                                            width: 200,
                                            height: 200,
                                          ),
                                          placeholder: (context, url) {
                                            return SvgPicture.asset(
                                              YodelImages.sitePlaceHolder,
                                            );
                                          },
                                          errorWidget: (context, url, error) {
                                            return SvgPicture.asset(
                                              YodelImages.sitePlaceHolder,
                                            );
                                          },
                                        )
                                      : SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: SvgPicture.asset(
                                            YodelImages.sitePlaceHolder,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      "${site.name}",
                                      maxLines: 2,
                                      style: YodelTheme.mainTitle
                                          .copyWith(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  _companyBloc.add(Fetch());
                },
                child: ListView(
                  children: <Widget>[
                    Ink(
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text("Phone number",
                            style: YodelTheme.metaRegularInactive),
                        subtitle: Text(
                          site.contactPhone ?? "-",
                          style: YodelTheme.bodyDefault,
                        ),
                        trailing: IconButton(
                          color: YodelTheme.iris,
                          iconSize: 30,
                          icon: Icon(YodelIcons.contact_call),
                          onPressed: site.contactPhone != null
                              ? () {
                                  openTel(site.contactPhone);
                                }
                              : null,
                        ),
                      ),
                    ),
                    Separator(),
                    Ink(
                      color: Colors.white,
                      child: ListTile(
                        onTap: () async {
                          await openMail(site.contactEmail);
                        },
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text("Email address",
                            style: YodelTheme.metaRegularInactive),
                        subtitle: Text(
                          site.contactEmail ?? "-",
                          style: YodelTheme.bodyDefault.copyWith(
                            color: YodelTheme.iris,
                          ),
                        ),
                      ),
                    ),
                    Separator(),
                    Ink(
                      color: Colors.white,
                      child: ListTile(
                        onTap: () async {
                          await openMapForSite(site);
                        },
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text("Address",
                            style: YodelTheme.metaRegularInactive),
                        subtitle: Text(
                          site.address ?? "-",
                          style: YodelTheme.bodyDefault.copyWith(
                            color: YodelTheme.iris,
                          ),
                        ),
                      ),
                    ),
                    SectionHeader(
                      child: Text(
                        "Managers",
                        style: YodelTheme.metaRegular,
                      ),
                    ),
                    ...site.managers.map((manager) {
                      final worker = Worker.manager(manager);
                      return Column(
                        children: <Widget>[
                          WorkerItem(
                            backgroundColor: YodelTheme.lightPaleGrey,
                            worker: worker,
                          ),
                          if (manager != site.managers.last) Separator(),
                        ],
                      );
                    }).toList(),
                    SectionHeader(
                      padding: const EdgeInsets.only(top: 8),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
