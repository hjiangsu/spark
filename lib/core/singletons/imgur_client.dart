import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:imgur/imgur.dart';

class ImgurClient {
  ImgurClient._();

  final imgur = Imgur(
    clientId: dotenv.env['IMGUR_CLIENT_ID']!,
  );

  static final instance = ImgurClient._().imgur;
}
