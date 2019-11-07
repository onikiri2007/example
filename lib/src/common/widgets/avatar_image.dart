import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/theme/themes.dart';

class AvatarImage extends StatelessWidget {
  final String imagePath;
  final String placeHolderImagePath;
  final double size;
  final int imageWidth;
  final int imageHeight;

  const AvatarImage({
    Key key,
    this.imagePath,
    this.placeHolderImagePath,
    this.size = 50,
    this.imageWidth,
    this.imageHeight,
  })  : assert(placeHolderImagePath != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return ClipOval(
        child: Container(
          width: size,
          height: size,
          color: YodelTheme.darkGreyBlue,
          child: CachedNetworkImage(
              fit: BoxFit.cover,
              width: size,
              height: size,
              imageUrl: ImageHelper.toImageUrl(imagePath,
                  width: imageWidth ?? 100, height: this.imageHeight ?? 100),
              errorWidget: (context, _, error) => SvgPicture.asset(
                    placeHolderImagePath,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
              placeholder: (context, _) {
                return SvgPicture.asset(
                  placeHolderImagePath,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                );
              }),
        ),
      );
    } else {
      return SvgPicture.asset(
        placeHolderImagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
  }
}
