import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

mixin PostBuildActionMixin {
  void onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  void showErrorOnPostBuild(
    BuildContext context,
    String error, {
    VoidCallback callback,
  }) {
    onWidgetDidBuild(() {
      var snackbar = SnackBar(
        content: Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            error,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(
          seconds: 3,
        ),
      );
      final controller = Scaffold.of(context).showSnackBar(snackbar);

      controller.closed.then((_) {
        if (callback != null) {
          callback();
        }
      });
    });
  }

  void showSuccessOnPostBuild(
    BuildContext context,
    String message, {
    VoidCallback callback,
  }) {
    onWidgetDidBuild(() async {
      var snackbar = SnackBar(
        content: Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: YodelTheme.tealish,
        duration: Duration(seconds: 1),
      );
      final controller = Scaffold.of(context).showSnackBar(snackbar);

      controller.closed.then((_) {
        if (callback != null) {
          callback();
        }
      });
    });
  }

  Future<bool> showConfirmDialog(BuildContext context,
      {String title = "Are you sure you want to remove?"}) {
    return showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title, style: YodelTheme.bodyActive),
        actions: <Widget>[
          PlatformDialogAction(
            child: Text(
              "No",
              style: YodelTheme.bodyInactive,
            ),
            onPressed: () {
              Navigator.of(context).pop<bool>(false);
            },
          ),
          PlatformDialogAction(
            child: Text(
              "Yes",
              style: YodelTheme.bodyActive
                  .copyWith(color: YodelTheme.bodyStrong.color),
            ),
            onPressed: () {
              Navigator.of(context).pop<bool>(true);
            },
          ),
        ],
      ),
    );
  }
}

mixin OpenUrlMixin {
  Future openMapForSite(Site site) async {
    final url = UrlHelper.getMapUrl(
        address: site.address, lat: site.latitude, long: site.longitude);
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future openTel(String number) async {
    final url = UrlHelper.getPhoneUrl(number);
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future openMail(String email) async {
    final url = UrlHelper.getEmailUrl(email);
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future openSms(String number) async {
    final url = UrlHelper.getSmsUrl(number);
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future openWeb(String webUrl) async {
    final url = UrlHelper.getWebUrl(webUrl);
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
