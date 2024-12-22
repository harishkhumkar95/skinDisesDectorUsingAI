import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healwiz/themes/theme.dart';
import 'package:http/http.dart' as http;

import '../../models/article.dart';

// Future<List<Article>> fetchArticles() async {
//   final response = await http.get(Uri.parse(dotenv.env['f5df632e839e4a10b3a2e7ba38d4de08']!));
//
//   if (response.statusCode == 200) {
//     final List<dynamic> jsonData = json.decode(response.body)['articles'];
//     return jsonData.map((article) => Article.fromJson(article)).toList();
//   } else {
//     throw Exception('Failed to load articles');
//   }
// }
Future<List<Article>> fetchArticles() async {
  // Hardcoded BASE_URL and API_KEY
  final String? baseUrl = 'https://newsapi.org/v2/top-headlines?country=us&category=health';
  final String? apiKey = 'f5df632e839e4a10b3a2e7ba38d4de08';

  // Debug: Print the values
  print('BASE_URL: $baseUrl');
  print('API_KEY: $apiKey');

  // Ensure both baseUrl and apiKey are non-null
  if (baseUrl == null || apiKey == null) {
    throw Exception('BASE_URL or API_KEY is null');
  }

  // Construct the full API URL
  final Uri uri = Uri.parse('$baseUrl&apiKey=$apiKey');

  // Debug: Print the constructed URL
  print('Constructed URL: $uri');

  // Make the HTTP GET request
  final response = await http.get(uri);

  // Handle the response
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);

    // Validate 'articles' key
    if (jsonData['articles'] == null || jsonData['articles'] is! List) {
      throw Exception('Invalid or missing "articles" key in API response');
    }

    final List<dynamic> articlesData = jsonData['articles'];
    return articlesData.map((article) => Article.fromJson(article)).toList();
  } else {
    // Handle errors
    throw Exception('Failed to load articles: ${response.statusCode} - ${response.reasonPhrase}');
  }
}


class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  _ArticleListScreenState createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  late Future<List<Article>> futureArticles;

  @override
  void initState() {
    super.initState();
    futureArticles = fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Trending Health News',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w600,
          ).copyWith(fontSize: 27),
        ),
      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No articles found.'));
          }

          final articles = snapshot.data!;

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                color: AppColor.container,
                child: ListTile(
                  leading: article.imageUrl.isNotEmpty
                      ? Image.network(article.imageUrl,
                          width: 100, fit: BoxFit.cover)
                      : null,
                  title: Text(article.title),
                  subtitle: Text(article.description),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article.imageUrl.isNotEmpty
                ? Image.network(article.imageUrl)
                : Container(),
            SizedBox(height: 8),
            Text(article.description, style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Open the article URL in a web view or browser
              },
              child: Text('Read more'),
            ),
          ],
        ),
      ),
    );
  }
}
