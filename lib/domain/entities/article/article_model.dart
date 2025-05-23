class ArticleModel {
  final String? articleId;
  final String? articleName;
  final String? articleUrl;
  final String? articleDescription;
  final String? articleContent;

  ArticleModel({
    this.articleId,
    this.articleName,
    this.articleUrl,
    this.articleDescription,
    this.articleContent,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      articleId: json['articleId'] as String?,
      articleName: json['articleName'] as String?,
      articleUrl: json['articleUrl'] as String?,
      articleDescription: json['articleDescription'] as String?,
      articleContent: json['articleContent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'articleName': articleName,
      'articleUrl': articleUrl,
      'articleDescription': articleDescription,
      'articleContent': articleContent,
    };
  }
}
