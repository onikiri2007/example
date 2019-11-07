import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raygun/raygun.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ProfilePictureSelector extends StatefulWidget {
  final String buttonText;

  ProfilePictureSelector({
    Key key,
    this.buttonText = "Complete profile",
  }) : super(key: key);

  @override
  _ProfilePictureSelectorState createState() => _ProfilePictureSelectorState();
}

class _ProfilePictureSelectorState extends State<ProfilePictureSelector>
    with PostBuildActionMixin {
  ProfileBloc _bloc;
  bool hasProfileImageSelected = false;
  File imageFile;

  @override
  void initState() {
    _bloc = BlocProvider.of<ProfileBloc>(context);
    hasProfileImageSelected = _bloc.initialState.profile.profilePhoto != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, ProfileState state) {
        final isLoading = state is ProfileUpdating;
        return LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    _pickImage();
                                  },
                            child: ClipOval(
                              child: Container(
                                width: 150,
                                height: 150,
                                child: imageFile != null
                                    ? Image.file(
                                        imageFile,
                                        fit: BoxFit.cover,
                                      )
                                    : (hasProfileImageSelected
                                        ? CachedNetworkImage(
                                            imageUrl: ImageHelper.toImageUrl(
                                              _bloc.state.profile.profilePhoto,
                                              width: 300,
                                              height: 300,
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
                                            width: 150,
                                            height: 150,
                                            child: SvgPicture.asset(
                                              YodelImages.profilePlaceHolder,
                                            ),
                                          )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          LinkButton(
                            style: YodelTheme.metaRegularActive,
                            child: Text(hasProfileImageSelected
                                ? "Update photo"
                                : "Add photo"),
                            onPressed: isLoading
                                ? null
                                : () {
                                    _pickImage();
                                  },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: BlocBuilder(
                          bloc: _bloc,
                          builder: (context, ProfileState state) {
                            return ProgressButton(
                              width: double.infinity,
                              height: 60,
                              color: YodelTheme.amber,
                              isLoading: isLoading,
                              onPressed: () {
                                _bloc.add(
                                  UpdateProfile(
                                    profile: _bloc.state.profile,
                                    profileImagePath: imageFile?.path,
                                  ),
                                );
                              },
                              child: Text(
                                widget.buttonText,
                                style: YodelTheme.bodyStrong,
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _pickImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                onTap: () async {
                  final PermissionStatus permission = await PermissionHandler()
                      .checkPermissionStatus(PermissionGroup.camera);

                  if (permission == PermissionStatus.denied) {
                    await _showSettingsDialog(
                        "You have denied Yodel to access the camera, To enable it, click Settings -> Camera");
                  } else {
                    final image = await _getImage(context, ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        imageFile = image;
                      });
                    }
                  }
                },
                title: Text(
                  "Take a photo",
                  style: YodelTheme.bodyStrong.copyWith(
                    color: YodelTheme.iris,
                  ),
                ),
              ),
              Separator(),
              ListTile(
                onTap: () async {
                  final image = await _getImage(context, ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      imageFile = image;
                    });
                  }
                },
                title: Text(
                  "Choose from gallery",
                  style: YodelTheme.bodyStrong.copyWith(
                    color: YodelTheme.iris,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File> _getImage(BuildContext context, ImageSource source) async {
    try {
      final image = await ImagePicker.pickImage(
        source: source,
      );

      Navigator.of(context).maybePop();

      if (image != null) {
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;

        var result = await FlutterImageCompress.compressAndGetFile(
          image.absolute.path,
          "$tempPath/${Uuid().v4()}.jpg",
          quality: 90,
          autoCorrectionAngle: true,
          minWidth: 500,
          minHeight: 500,
        );

        return result;
      }
    } on PlatformException catch (ex, stackTrace) {
      FlutterRaygun().logException(ex, stackTrace);
    }

    return null;
  }

  Future<void> _showSettingsDialog(
    String title,
  ) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    width: 1,
                    color: Colors.white,
                  )),
              child: Container(
                height: 160,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(title, style: YodelTheme.bodyStrong),
                    ),
                    Separator(),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              onPressed: () async {
                                await PermissionHandler().openAppSettings();
                              },
                              disabledColor: YodelTheme.lightPaleGrey,
                              child: Text(
                                "Settings",
                                style: YodelTheme.bodyActive
                                    .copyWith(color: YodelTheme.iris),
                              ),
                            ),
                          ),
                          Separator(
                            axis: SeparatorAxis.vertical,
                          ),
                          Expanded(
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                disabledColor: YodelTheme.lightPaleGrey,
                                child: Text(
                                  "Cancel",
                                  style: YodelTheme.bodyInactive,
                                )),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}
