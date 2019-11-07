import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class ShiftCard extends StatelessWidget {
  const ShiftCard({
    Key key,
    this.padding = const EdgeInsets.all(16),
    this.shift,
    this.onTap,
    this.highlightColor,
    this.splashColor,
    this.color,
  }) : super(key: key);

  final ManageShift shift;
  final EdgeInsets padding;
  final VoidCallback onTap;
  final Color highlightColor;
  final Color splashColor;
  final Color color;

  Widget build(BuildContext context) {
    if (shift == null) {
      return Container();
    }

    final DateFormat timeformat = DateFormat("h:mm a");

    Color sidebarColor;

    if (shift.isFilled) {
      sidebarColor = YodelTheme.tealish;
    } else {
      sidebarColor = YodelTheme.iris;
    }

    final responses = shift.responses;

    if (responses.reviewItemsCount > 0) {
      sidebarColor = YodelTheme.amber;
    }

    if (!shift.isActive) {
      sidebarColor = YodelTheme.lightGreyBlue;
    }

    final headCountText = Intl.plural(
      shift.headCountRemaining,
      zero: "employee",
      one: "employee",
      other: "employees",
    );

    return ListTile(
      contentPadding: padding,
      leading: Container(
        width: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              timeformat.format(shift.startOn).toLowerCase(),
              style: YodelTheme.metaRegular,
            ),
            Text(
              timeformat.format(shift.finishOn).toLowerCase(),
              style: YodelTheme.metaDefault,
            ),
          ],
        ),
      ),
      title: Container(
        width: double.infinity,
        height: 135,
        decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: YodelTheme.shadow.withOpacity(0.32),
                offset: Offset(0, 1),
              )
            ]),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            splashColor: splashColor ?? Theme.of(context).splashColor,
            highlightColor: highlightColor ?? Theme.of(context).highlightColor,
            onTap: onTap,
            enableFeedback: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: sidebarColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SiteAvatarImage(
                                  site: shift.site,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  shift.site.name,
                                  maxLines: 1,
                                  style: YodelTheme.metaDefault,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              shift.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: YodelTheme.bodyStrong.copyWith(
                                color: !shift.isActive
                                    ? YodelTheme.lightGreyBlue
                                    : YodelTheme.darkGreyBlue,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                                shift.isFilled
                                    ? "All positions filled"
                                    : "${shift.headCountRemaining} $headCountText required",
                                style: shift.isFilled
                                    ? YodelTheme.metaRegular.copyWith(
                                        color: !shift.isActive
                                            ? YodelTheme.lightGreyBlue
                                            : YodelTheme.tealish)
                                    : YodelTheme.metaDefault.copyWith(
                                        color: !shift.isActive
                                            ? YodelTheme.lightGreyBlue
                                            : YodelTheme.darkGreyBlue,
                                      )),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        color: YodelTheme.separatorColor,
                      ),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        child: shift.isFilled
                            ? Text(
                                shift.filledBy,
                                style: YodelTheme.metaRegular.copyWith(
                                  color: !shift.isActive
                                      ? YodelTheme.lightGreyBlue
                                      : YodelTheme.darkGreyBlue,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            : Row(
                                children: <Widget>[
                                  Text(
                                    "${responses.reviewItemsCount} to review",
                                    style:
                                        YodelTheme.metaRegularActive.copyWith(
                                      color: !shift.isActive
                                          ? YodelTheme.lightGreyBlue
                                          : responses.reviewItemsCount > 0
                                              ? YodelTheme.amber
                                              : YodelTheme.iris,
                                    ),
                                  ),
                                ],
                              ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
