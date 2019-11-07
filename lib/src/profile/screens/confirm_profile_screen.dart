import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/theme/themes.dart';
import 'package:provider/provider.dart';

class ConfirmProfileScreen extends StatelessWidget with PostBuildActionMixin {
  ConfirmProfileScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      builder: (context) => ProfileBloc(
        authBloc: BlocProvider.of<AuthenticationBloc>(context),
      ),
      child: Consumer<ProfileBloc>(builder: (context, bloc, child) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: SafeArea(
            child: KeyboardDismissable(
                child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                elevation: 0.0,
                automaticallyImplyLeading: false,
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
                          "Step 1 of 2",
                          style: YodelTheme.metaWhite,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Confirm your details",
                          style: YodelTheme.mainTitle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Looks like it’s your first time using Yodel. To begin, review your details below and make any necessary adjustments.",
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

                  if (state is ProfileConfirmed) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<ProfileBloc>.value(
                            value: bloc,
                            child: AddProfilePicScreen(),
                          ),
                        ));
                  }
                },
                child: ProfileDetailsForm(
                  isEdit: true,
                  mode: ProfileMode.confirm,
                  buttonText: "Confirm details",
                  onSubmit: (profile) {
                    bloc.add(
                      ConfirmProfileDetails(
                        profile: profile,
                      ),
                    );
                  },
                ),
              ),
            )),
          ),
        );
      }),
    );
  }
}
