import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/theme/themes.dart';

class EditProfileDetailsScreen extends StatelessWidget
    with PostBuildActionMixin {
  EditProfileDetailsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    return SafeArea(
      child: KeyboardDismissable(
          child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "Edit Details",
            style: YodelTheme.bodyWhite,
          ),
          actions: <Widget>[
            NavbarButton(
              padding: const EdgeInsets.only(right: 16.0),
              style: YodelTheme.bodyDefault.copyWith(
                color: YodelTheme.tealish,
              ),
              highlightedStyle: YodelTheme.bodyDefault.copyWith(
                color: YodelTheme.tealish.withOpacity(0.8),
              ),
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: BlocListener(
          bloc: bloc,
          listener: (context, state) {
            if (state is ProfileUpdateFailure) {
              showErrorOnPostBuild(context, state.error);
            }

            if (state is ProfileConfirmed) {
              bloc.add(ProfileInitialise(profile: bloc.state.profile));
              showSuccessOnPostBuild(context, "Details updated successfully",
                  callback: () {
                Navigator.pop(context);
              });
            }
          },
          child: ProfileDetailsForm(
            isEdit: true,
            mode: ProfileMode.edit,
            buttonText: "Save details",
            onSubmit: (profile) {
              bloc.add(ConfirmProfileDetails(profile: profile));
            },
          ),
        ),
      )),
    );
  }
}
