import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/theme/themes.dart';

class EditProfilePicScreen extends StatelessWidget with PostBuildActionMixin {
  EditProfilePicScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            title: Text(
              "Edit Profile Picture",
              style: YodelTheme.bodyWhite,
            ),
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
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ProfilePictureSelector(
              buttonText: "Change Profile Picture",
            ),
          ),
        ),
      ),
      listener: (context, state) {
        final bloc = BlocProvider.of<ProfileBloc>(context);
        if (state is ProfileUpdateFailure) {
          showErrorOnPostBuild(context, state.error);
        }

        if (state is ProfileUpdateCompleted) {
          bloc.add(ProfileInitialise(profile: bloc.state.profile));
          Navigator.pop(context);
        }
      },
    );
  }
}
