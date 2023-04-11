import 'package:flutter/material.dart';

import 'package:html_unescape/html_unescape.dart';

class CommentCardBody extends StatelessWidget {
  String body;

  CommentCardBody({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: Text(HtmlUnescape().convert(body)),
    );
  }
}
