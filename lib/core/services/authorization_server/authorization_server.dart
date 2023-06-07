// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/core/auth/bloc/auth_bloc.dart';

Future<void> initializeAuthorizationServer(BuildContext context) async {
  HttpServer server = await HttpServer.bind("0.0.0.0", 8080, shared: true);

  server.listen((request) async {
    final Dio dio = Dio();

    // Set authorization header and content type headers
    dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    dio.options.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('${dotenv.env['REDDIT_CLIENT_ID']}:'))}';

    Uri uri = request.uri;

    // Run authorization checks
    if (uri.path == "/") {
      try {
        final Map<String, dynamic> queryParameters = uri.queryParameters;

        final response = await dio.post(
          'https://www.reddit.com/api/v1/access_token',
          data: {
            "grant_type": "authorization_code",
            "code": queryParameters['code'],
            "redirect_uri": dotenv.env['REDDIT_CLIENT_CALLBACK_URL'],
          },
        );

        if (response.statusCode == 200) {
          final data = response.data;
          await updateLocalAuthInformation(context, data);
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (e, s) {
        print('An error occurred when authenticating with Reddit: $e');
      }
    }

    // Run refresh checks
    if (uri.path == "/refresh") {
      Map<String, dynamic> body = await parsePOSTRequestBody(request);

      if (body.containsKey("refresh_token")) {
        try {
          final response = await dio.post(
            'https://www.reddit.com/api/v1/access_token',
            data: {
              "grant_type": "refresh_token",
              "refresh_token": body["refresh_token"],
            },
          );

          if (response.statusCode == 200) {
            final data = response.data;
            Map<String, dynamic> authInformation = await updateLocalAuthInformation(context, data);
            request.response.write(jsonEncode(authInformation));
          } else {
            print('Request failed with status: ${response.statusCode}');
          }
        } catch (e, s) {
          print('An error occurred when refreshing authorization information: $e');
        }
      }
    }

    request.response.close();
  });
}

Future<Map<String, dynamic>> parsePOSTRequestBody(HttpRequest request) async {
  final body = await utf8.decoder.bind(request).join();

  // Parse the body based on the content type
  final contentType = request.headers.contentType;

  Map<String, dynamic> data = {};

  if (contentType?.mimeType == 'application/json') {
    // Handle JSON body
    data = jsonDecode(body);
  } else if (contentType?.mimeType == 'application/x-www-form-urlencoded') {
    // Handle form data body
    data = Uri.splitQueryString(body);
  } else {
    // Unsupported content type
    print('Unsupported content type: ${contentType?.mimeType}');
  }

  return data;
}

Map<String, dynamic> formatAuthorizationResponse(Map<String, dynamic> data) {
  Map<String, dynamic> formattedResponse = {
    "access_token": data["access_token"],
    "token_type": data["token_type"],
    "expires_in": data["expires_in"],
    "scope": data["scope"],
    "refresh_token": data["refresh_token"],
    "expires_at_ms": DateTime.now().add(Duration(seconds: data["expires_in"])).millisecondsSinceEpoch,
  };

  return formattedResponse;
}

Future<Map<String, dynamic>> updateLocalAuthInformation(BuildContext context, Map<String, dynamic> data) async {
  Map<String, dynamic> authInformation = formatAuthorizationResponse(data);

  // Store the authorization on device
  final prefs = await SharedPreferences.getInstance();
  String encodedAuthorizationMap = json.encode(authInformation);
  await prefs.setString('userAuthorization', encodedAuthorizationMap);

  // Perform refresh of app
  context.read<AuthBloc>().add(AuthChecked());
  return authInformation;
}
