import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:html_unescape/html_unescape.dart';
import 'package:spark/core/media/extensions/extensions.dart';
import 'package:spark/core/models/media/media.dart';
import 'package:spark/widgets/image_preview/image_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentCardBody extends StatefulWidget {
  String body;
  Media? media;

  CommentCardBody({super.key, required this.body, this.media});

  @override
  State<CommentCardBody> createState() => _CommentCardBodyState();
}

class _CommentCardBodyState extends State<CommentCardBody> {
  RegExp linkRegex = RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)');

  List<String?> links = [];

  @override
  void initState() {
    Iterable<Match> matches = linkRegex.allMatches(HtmlUnescape().convert(widget.body));
    links = matches.map((match) => match.group(0)).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> content = [];

    String parsedBody = HtmlUnescape().convert(widget.body);

    if (widget.media != null) {
      print(widget.media?.url);
      parsedBody = parsedBody.replaceAll(widget.media!.url, '');

      return ImagePreview(
        url: widget.media!.url,
        width: widget.media?.width,
        height: widget.media?.height,
      );
    }

    // Look for the links which are pictures
    // for (String? link in links) {
    //   if (link!.contains('.jpeg') || link.contains('.png')) {
    //     content.add(
    //       FutureBuilder<ImageInfo>(
    //         future: MediaExtension.getImageInfo(Image.network(link)),
    //         builder: (context, snapshot) {
    //           if (snapshot.hasData) {
    //             Size size = MediaExtension.getScaledMediaSize(width: snapshot.data?.image.width, height: snapshot.data?.image.height);

    //             return ImagePreview(
    //               url: link,
    //               width: size.width,
    //               height: size.height,
    //             );
    //           }
    //           return const SizedBox(
    //             height: 200,
    //             child: Center(child: CircularProgressIndicator()),
    //           );
    //         },
    //       ),
    //     );
    //     parsedBody = parsedBody.replaceAll(link, '');
    //   }
    // }

    // Clean up the markdown body to remove the links from the pictures
    content.addAll([
      MarkdownBody(
        data: parsedBody,
        onTapLink: (text, url, title) {
          launchUrl(Uri.parse(url!));
        },
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: theme.textTheme.bodyMedium,
            blockquoteDecoration: const BoxDecoration(
              color: Colors.transparent,
              border: Border(left: BorderSide(color: Colors.grey, width: 4)),
            )),
      ),
      links.isNotEmpty ? const SizedBox(height: 8.0) : Container(),
    ]);

    content.addAll(
      links.map((link) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            alignment: Alignment.centerLeft,
            minimumSize: const Size.fromHeight(40),
          ),
          onPressed: () => launchUrl(Uri.parse(link)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  link!,
                  maxLines: 1,
                  minFontSize: 13,
                  maxFontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right_rounded)
            ],
          ),
        );
      }),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }
}
