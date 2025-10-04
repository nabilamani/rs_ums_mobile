import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

final dio = Dio();

class ArticleDetailPage extends StatefulWidget {
  final String slug;
  const ArticleDetailPage({super.key, required this.slug});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Map<String, dynamic>? article;
  bool isLoading = true;

  Future<void> fetchArticleDetail() async {
    try {
      final response = await dio.get(
        "http://192.168.167.141:8000/api/v1/articles/${widget.slug}",
      );

      if (response.statusCode == 200) {
        setState(() {
          article = response.data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Format tanggal ke "8 September 2025"
  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat("d MMMM y", "id_ID").format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchArticleDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Artikel")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : article == null
              ? const Center(child: Text("Artikel tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article!['thumbnail'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "http://192.168.167.141:8000/storage/${article!['thumbnail']}",
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        article!['title'] ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Dipublikasikan: ${formatDate(article!['published_at'])}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      // Render konten HTML dengan paragraf rapat
                      Html(
                        data: article!['content'] ?? "",
                        style: {
                          "p": Style(
                            fontSize: FontSize(16),
                            textAlign: TextAlign.justify,
                            margin: Margins.zero, // buang jarak bawaan <p>
                          ),
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
