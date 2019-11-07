import 'package:flutter/material.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/theme/themes.dart';

class NoAccountScreen extends StatelessWidget {
  final Widget child;

  NoAccountScreen({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: OverflowBox(
          maxWidth: 90.0,
          child: NavbarButton(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Back",
                style: YodelTheme.bodyDefault.copyWith(
                  color: YodelTheme.tealish,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        title: Text("No Account"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            child: Text(
              "My workplace is using Yodel but I don't have account.",
              style: YodelTheme.bodyStrong.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: 13.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0, left: 16, right: 16),
            child: Text(
              "Contact your store manager or admin to help you set up your account.",
              style: YodelTheme.bodyDefault,
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          SectionHeader(
            padding: const EdgeInsets.only(top: 8),
          ),
          SizedBox(
            height: 30.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "My workplace doesn't have yodel.",
              style: YodelTheme.bodyStrong.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: 11.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "Unfortuntely, at this stage, Yodel is only available in participating stores. But don’t worry!",
              style: YodelTheme.bodyDefault,
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "Ask your store manager or admin to contact us and we can help them to get setup in no time.",
              style: YodelTheme.bodyDefault,
            ),
          ),
        ],
      ),
    ));
  }
}
