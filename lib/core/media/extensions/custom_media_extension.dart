import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spark/core/enums/media_type.dart';
import 'package:spark/core/media/extensions/extensions.dart';
import 'package:spark/core/models/media/media.dart';

/// This is a class to implement a custom media extension
class CustomMediaExtension {
  final Dio dio = Dio();
  String? customMediaExtensionBaseURL;

  CustomMediaExtension() {
    customMediaExtensionBaseURL = dotenv.env['CUSTOM_MEDIA_EXTENSION_BASE_URL'];
  }

  Future<List<Media>> getMediaInformation(String url) async {
    List<Media> mediaList = [];

    Map<String, dynamic> response = await getMediaResponse(url: url);

    if (response.isEmpty) return mediaList;
    MediaType mediaType = MediaType.video;

    // Fetch information about the video
    String mediaLink = response["url"];
    int mediaHeight = response["height"];
    int mediaWidth = response["width"];

    Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

    mediaList.add(Media(url: mediaLink, width: size.width, height: size.height, mediaType: mediaType, token: response["auth"]));

    return mediaList;
  }

  Future<dynamic> getAuthToken() async {
    Dio dio = Dio();

    String url = "$customMediaExtensionBaseURL/v2/auth/temporary";

    try {
      final Response authTokenResponse = await dio.get(url);
      if (authTokenResponse.statusCode != 200) throw Exception('Network error occurred');

      dynamic responseBody = authTokenResponse.data;
      return responseBody;
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> getMediaResponse({String? gifId, String? url}) async {
    String id = gifId ?? '';

    if (url != null) {
      Uri parsedUrl = Uri.parse(url);
      List<String> pathSegments = parsedUrl.pathSegments;

      try {
        id = pathSegments[1];
      } catch (err) {
        return {};
      }
    }

    dynamic authInformation = await getAuthToken();

    String requestUrl = "$customMediaExtensionBaseURL/v2/gifs/$id";

    Map<String, String> headers = {
      'content-Type': 'application/json',
      'accept': 'application/json',
      'authorization': 'Bearer ${authInformation["token"]}',
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
    };

    try {
      final Response gifInformationResponse = await dio.get(
        requestUrl,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      if (gifInformationResponse.statusCode != 200) throw Exception('Network error occurred');

      dynamic responseBody = gifInformationResponse.data;

      Map<String, dynamic> result = {};

      String url = responseBody['gif']['urls']['sd'];
      result.putIfAbsent('url', () => url);
      result.putIfAbsent('width', () => responseBody['gif']['width']);
      result.putIfAbsent('height', () => responseBody['gif']['height']);
      result.putIfAbsent('auth', () => authInformation["token"]);

      return result;
    } catch (e) {
      print(e);
      return {};
    }
  }

  static bool isCustomURL(String url, String customMediaExtensionURL) {
    return url.contains(customMediaExtensionURL!);
  }
}
