import 'dart:io';

import 'package:yodel/src/config.dart';

class ImageHelper {
  static String toImageUrl(String relativePath,
          {int width,
          int height,
          int quality = 90,
          String format = "png",
          String mode = "stretch"}) =>
      relativePath != null
          ? "${Config.baseUrl}/$relativePath?autorotate=true&format=$format&quality=$quality&mode=$mode${_getWidth(width)}${_getHeight(height)}"
          : null;

  static String _getWidth(int width) => width != null ? "&w=$width" : "";

  static _getHeight(int height) => height != null ? "&h=$height" : "";
}

class UrlHelper {
  static String getMapUrl({String address, double lat, double long}) {
    if (lat != null && long != null) {
      if (Platform.isIOS) {
        return "http://maps.apple.com/?q=${Uri.encodeComponent(address)}&ll=$lat,$long&z=10";
      } else {
        return "https://www.google.com/maps/search/?api=1&query=$lat,$long&query=${Uri.encodeComponent(address)}";
      }
    }

    if (address != null) {
      if (Platform.isIOS) {
        return "http://maps.apple.com/?address=${Uri.encodeComponent(address)}";
      } else {
        return "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
      }
    }

    return null;
  }

  static getPhoneUrl(String phone) {
    if (phone != null) {
      return "tel:${Uri.encodeComponent(phone)}";
    }
    return "";
  }

  static getEmailUrl(String email) {
    if (email != null) {
      return "mailto//:$email";
    }
  }

  static getSmsUrl(String phone) {
    if (phone != null) {
      if (Platform.isIOS) {
        return "sms:${Uri.encodeComponent(phone)}";
      } else {
        return "smsto:${Uri.encodeComponent(phone)}";
      }
    }
    return "";
  }

  static getWebUrl(String url) {
    if (url != null) {
      return url;
    }
    return "";
  }
}
