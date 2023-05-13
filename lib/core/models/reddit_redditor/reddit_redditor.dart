class RedditRedditor {
  RedditRedditor({
    required this.id,
    required this.avatarImageURL,
    required this.avatarIconImageURL,
    required this.linkKarma,
    required this.totalKarma,
    required this.name,
    required this.createdAt,
  });

  String id;

  String avatarImageURL;
  String avatarIconImageURL;

  String name;
  int linkKarma;
  int totalKarma;

  int createdAt;
}
