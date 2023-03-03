import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({super.key, this.originURL});

  final String? originURL;

  Future<void> _launchURL(url) async {
    Uri _url = Uri.parse(url);

    if (!await launchUrl(_url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (originURL != null && originURL!.startsWith('https://www.reddit.com')) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: InkWell(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6), // Image border
          child: Stack(
            alignment: Alignment.bottomRight,
            fit: StackFit.passthrough,
            children: [
              Container(
                color: Colors.grey.shade900,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.link,
                        color: Colors.white60,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        originURL!,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyText2!.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () => _launchURL(originURL),
      ),
    );
  }
}
