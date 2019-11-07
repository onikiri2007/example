import 'package:flutter/material.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class ShiftResponseCard extends StatelessWidget {
  final VoidCallback leftButtonPressed;
  final VoidCallback rightButtonPressed;
  final bool isLoading;

  const ShiftResponseCard({
    @required this.shift,
    @required this.worker,
    this.leftButtonPressed,
    this.rightButtonPressed,
    this.isLoading = false,
  })  : assert(shift != null),
        assert(worker != null);

  final Worker worker;
  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final ageText = worker.age > 21 ? "21+" : "${worker.age}";
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: AvatarImage(
                imagePath: worker.imagePath,
                placeHolderImagePath: YodelImages.profilePlaceHolder,
              ),
              title: Text(worker.name, style: YodelTheme.bodyDefault),
              subtitle: worker.age != null
                  ? Text("$ageText yrs old", style: YodelTheme.metaDefault)
                  : null,
              trailing: worker.rate != null
                  ? Text("\$${worker.hourlyRate}/hr",
                      style: YodelTheme.bodyDefault.copyWith(
                        color: YodelTheme.amber,
                      ))
                  : null,
            ),
          ),
          Separator(),
          Container(
            height: 50,
            child: isLoading
                ? Center(
                    child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator()))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          onPressed: this.leftButtonPressed,
                          disabledColor: YodelTheme.lightPaleGrey,
                          child: Text("Approve",
                              style: this.leftButtonPressed != null
                                  ? YodelTheme.bodyActive
                                  : YodelTheme.bodyInactive),
                        ),
                      ),
                      Separator(
                        axis: SeparatorAxis.vertical,
                      ),
                      Expanded(
                        child: FlatButton(
                            onPressed: this.rightButtonPressed,
                            disabledColor: YodelTheme.lightPaleGrey,
                            child: Text(
                              "Profile",
                              style: this.rightButtonPressed != null
                                  ? YodelTheme.bodyActive
                                  : YodelTheme.bodyInactive,
                            )),
                      )
                    ],
                  ),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: YodelTheme.shadow.withOpacity(0.32),
            offset: Offset(0, 1),
          )
        ],
      ),
    );
  }
}
