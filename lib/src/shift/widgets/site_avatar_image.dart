import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/home/blocs/company/bloc.dart';
import 'package:yodel/src/theme/themes.dart';

class SiteAvatarImage extends StatelessWidget {
  final Site site;
  final int imageWidth;
  final int imageHeight;
  final double size;

  const SiteAvatarImage({
    Key key,
    this.site,
    this.imageWidth,
    this.imageHeight,
    this.size = 50,
  })  : assert(site != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildAvatarImage(context, site),
    );
  }

  Widget _buildAvatarImage(BuildContext context, Site site) {
    final companyBloc = BlocProvider.of<CompanyBloc>(context);

    if (site.imagePath != null && site.imagePath.isNotEmpty) {
      return AvatarImage(
        imagePath: site.imagePath,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        placeHolderImagePath: YodelImages.sitePlaceHolder,
        size: size,
      );
    } else if (companyBloc != null &&
        companyBloc.company.logoPath != null &&
        companyBloc.company.logoPath.isNotEmpty) {
      return AvatarImage(
        imagePath: companyBloc.company.logoPath,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        placeHolderImagePath: YodelImages.sitePlaceHolder,
        size: size,
      );
    } else {
      return AvatarImage(
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        placeHolderImagePath: YodelImages.sitePlaceHolder,
        size: size,
      );
    }
  }
}
