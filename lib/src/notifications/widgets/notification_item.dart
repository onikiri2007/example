import 'package:flutter/material.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/theme/themes.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    Key key,
    @required this.notification,
    this.onTap,
    this.trailingBuilder,
    this.activeColor,
    this.backgroundColor,
  })  : assert(notification != null),
        super(key: key);

  final YodelNotification notification;
  final Function(YodelNotification notification) onTap;
  final WidgetPartBuilder<YodelNotification> trailingBuilder;
  final Color activeColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ListTileItem<YodelNotification>(
      backgroundColor: backgroundColor,
      activeColor: activeColor,
      isMultiSelect: false,
      isSelected: false,
      contentPadding: const EdgeInsets.all(16),
      onChange: (source, _) {
        if (onTap != null) onTap(source);
      },
      source: notification,
      trailingBuilder: trailingBuilder,
      titleBuilder: (context, notification) {
        List<Widget> widgets = [];
        Widget avatar;
        if (notification.fromUserId != null && notification.fromUserId > 0) {
          avatar = SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: <Widget>[
                AvatarImage(
                  imagePath: notification.fromProfilePhotoPath,
                  placeHolderImagePath: YodelImages.profilePlaceHolder,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: AvatarImage(
                      imagePath: notification.site?.imagePath,
                      size: 20,
                      placeHolderImagePath: YodelImages.sitePlaceHolder),
                ),
              ],
            ),
          );
        } else {
          avatar = AvatarImage(
            imagePath: notification.site?.imagePath,
            placeHolderImagePath: YodelImages.sitePlaceHolder,
          );
        }

        widgets.addAll(
          [
            avatar,
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Html(
                useRichText: true,
                data:
                    "${notification.message} <span>${notification.ago} ago</span>",
                defaultTextStyle: YodelTheme.bodyHyperText.copyWith(
                  color: YodelTheme.darkGreyBlue,
                ),
                customTextStyle: (node, style) {
                  if (node is dom.Element) {
                    switch (node.localName) {
                      case "b":
                        return YodelTheme.bodyStrong;
                      case "span":
                        return YodelTheme.bodyHyperText.copyWith(
                          color: YodelTheme.lightGreyBlue,
                        );
                    }
                  }

                  return style;
                },
                linkStyle:
                    YodelTheme.bodyHyperText.copyWith(color: YodelTheme.iris),
                onLinkTap: (url) {
                  // open url in a webview
                },
              ),
            ),
          ],
        );

        return Column(
          children: <Widget>[
            Html(
              data: notification.title,
              defaultTextStyle: YodelTheme.metaRegular.copyWith(
                color: YodelTheme.darkGreyBlue,
              ),
              linkStyle:
                  YodelTheme.metaRegular.copyWith(color: YodelTheme.iris),
              onLinkTap: (url) {
                // open url in a webview
              },
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widgets,
            ),
          ],
        );
      },
    );
  }
}
