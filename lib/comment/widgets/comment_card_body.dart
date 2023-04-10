import 'package:flutter/material.dart';

import 'package:html_unescape/html_unescape.dart';

class CommentCardBody extends StatelessWidget {
  String body;

  CommentCardBody({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Text(HtmlUnescape().convert(body));
  }
}
