import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/routes.dart';
import 'package:yodel/src/theme/themes.dart';

class AddProfilePicScreen extends StatelessWidget with PostBuildActionMixin {
  AddProfilePicScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        bloc.add(ProfileInitialise(profile: bloc.state.profile));
        return true;
      },
      child: SafeArea(
        child: Scaffold(
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
              preferredSize: Size.fromHeight(116),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Step 2 of 2",
                      style: YodelTheme.metaWhite,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Add a profile picture",
                      style: YodelTheme.mainTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Help your colleagues identify who you are. This is especially helpful if you’re filling a shift.",
                      style: YodelTheme.metaWhite,
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdateFailure) {
                showErrorOnPostBuild(context, state.error);
              }

              if (state is ProfileUpdateCompleted) {
                router.navigateTo(context, "/welcome",
                    transition: TransitionType.native,
                    replace: true,
                    clearStack: true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ProfilePictureSelector(),
            ),
          ),
        ),
      ),
    );
  }
}
