import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/authentication/bloc/authentication_bloc.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/theme/themes.dart';

class InviteUserScreen extends StatelessWidget with OpenUrlMixin {
  final Widget child;

  InviteUserScreen({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: OverflowBox(
          maxWidth: 90.0,
          child: NavbarButton(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Back",
                style: YodelTheme.bodyDefault.copyWith(
                  color: YodelTheme.amber,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        title: Text("Invite User"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                child: Text(
                  "Have a new employee or manager you want to invite to Yodel?",
                  style: YodelTheme.bodyStrong.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                height: 13.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 16, right: 16),
                child: Text(
                  "Unfortunately, we do not yet have the ability to add users via our mobile app.",
                  style: YodelTheme.bodyDefault,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  "Press button below to log in to the web platform where you can add and manage users.",
                  style: YodelTheme.bodyDefault,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  "Otherwise, contact your site admin to help you invite them.",
                  style: YodelTheme.bodyDefault,
                ),
              ),
            ],
          ),
          Positioned(
            height: 80,
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ProgressButton(
                child: Text("Invite user", style: YodelTheme.bodyStrong),
                color: YodelTheme.amber,
                width: double.infinity,
                onPressed: () async {
                  await openWeb("${Config.inviteUrseUrl}");
                },
              ),
            ),
          )
        ],
      ),
    ));
  }
}
