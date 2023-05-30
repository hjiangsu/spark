import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark/comment/comment.dart';

import 'package:spark/feed/widgets/post_heading.dart';
import 'package:spark/post/bloc/post_bloc.dart';
import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/widgets/error_message/error_message.dart';
import 'package:spark/widgets/link_preview_card/link_preview_card.dart';
import 'package:spark/widgets/media_view/media_view.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.postId});

  final String postId;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final GlobalKey scrollControllerKey = GlobalKey();

  bool showOriginalURL = false;

  Future<void> _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    bool? _showOriginalURL = prefs.getBool('showOriginalURL');

    setState(() {
      showOriginalURL = _showOriginalURL ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<PostBloc>(
        create: (context) => PostBloc(reddit: RedditClient.instance),
        child: BlocBuilder<PostBloc, PostState>(builder: (context, state) {
          switch (state.status) {
            case PostStatus.initial:
              context.read<PostBloc>().add(PostRefreshed(postId: widget.postId));
              return const Center(child: CircularProgressIndicator());
            case PostStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case PostStatus.success:
              return Scaffold(
                appBar: AppBar(),
                body: SingleChildScrollView(
                  key: scrollControllerKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PostHeading(post: state.post!),
                            MediaView(
                              post: state.post!,
                              showVideoControls: true,
                            ),
                            (state.post?.text == true)
                                ? MarkdownBody(
                                    data: HtmlUnescape().convert(state.post!.description),
                                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                                      p: theme.textTheme.bodyMedium,
                                      blockquoteDecoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border(left: BorderSide(color: Colors.grey, width: 4)),
                                      ),
                                    ),
                                  )
                                : Container(),
                            const SizedBox(height: 8.0),
                            if (state.post?.url != null && showOriginalURL) LinkPreviewCard(originURL: state.post!.url),
                          ],
                        ),
                      ),
                      CommentView(
                        submissionId: state.post!.id,
                        subreddit: state.post!.subreddit,
                      ),
                    ],
                  ),
                ),
              );
            case PostStatus.empty:
              return const ErrorMessage(message: 'An error occurred');
            case PostStatus.failure:
              return const ErrorMessage(message: 'An error occurred');
          }
        }));
  }
}
