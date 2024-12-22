class Article {
  final String title;
  final String description;
  final String url;
  final String imageUrl;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title', // Default value for null or missing title
      description: json['description'] ?? 'No Description', // Default value for null or missing description
      url: json['url'] ?? '', // Default empty string for null or missing URL
      imageUrl: json['image'] ?? '', // Default empty string for null or missing image URL
    );
  }
}

