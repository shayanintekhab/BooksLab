import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/favorite_book_model.dart';

class BookDetailScreen extends StatelessWidget {
  final Map book;

  BookDetailScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title'] ?? 'Untitled'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () async {
              final db = DatabaseHelper.instance;
              final favoriteBook = FavoriteBook(
                id: book['id'] is int ? book['id'] : int.tryParse(book['id'].toString()) ?? 0,
                title: book['title'] ?? 'Untitled',
                author: (book['authors'] is List && book['authors'].isNotEmpty && book['authors'][0] is Map)
                    ? book['authors'][0]['name'] ?? 'Unknown'
                    : 'Unknown',
                subjects: (book['subjects'] is List) ? book['subjects'].join(', ') : 'No subjects',
                translators: (book['translators'] is List) ? book['translators'].join(', ') : 'None',
                bookshelves: (book['bookshelves'] is List) ? book['bookshelves'].join(', ') : 'None',
                languages: (book['languages'] is List) ? book['languages'].join(', ') : 'Unknown',
                copyright: book['copyright'] == true ? 'Yes' : 'No',
                mediaType: book['media_type'] ?? 'Unknown',
                downloadCount: book['download_count']?.toString() ?? '0',
                imageUrl: (book['formats'] is Map && book['formats']['image/jpeg'] != null)
                    ? book['formats']['image/jpeg']
                    : '',
              );

              // Debug the book being added
              print("Attempting to insert: ${favoriteBook.toMap()}");

              if (await db.checkFavoriteExists(favoriteBook.id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Book already in favorites!')),
                );
                return;
              }

              try {
                await db.insertFavorite(favoriteBook);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Book added to favorites!')),
                );
              } catch (e) {
                print("Error adding book to favorites: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.teal[50],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: (book['formats'] is Map && book['formats']['image/jpeg'] != null)
                    ? Image.network(
                        book['formats']['image/jpeg'],
                        height: 300,
                        fit: BoxFit.contain,
                      )
                    : const Icon(Icons.book, size: 150),
              ),
              const SizedBox(height: 16),
              Text(
                book['title'] ?? 'Untitled',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 10, 10),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailRow("ID", book['id'].toString()),
                    buildDetailRow(
                      "Author",
                      (book['authors'] is List && book['authors'].isNotEmpty && book['authors'][0] is Map)
                          ? book['authors'][0]['name'] ?? 'Unknown'
                          : 'Unknown',
                    ),
                    buildDetailRow(
                      "Subjects",
                      (book['subjects'] is List) ? book['subjects'].join(', ') : 'No subjects available',
                    ),
                    buildDetailRow(
                      "Translators",
                      (book['translators'] is List)
                          ? book['translators'].join(', ')
                          : 'None',
                    ),
                    buildDetailRow(
                      "Bookshelves",
                      (book['bookshelves'] is List)
                          ? book['bookshelves'].join(', ')
                          : 'None',
                    ),
                    buildDetailRow(
                      "Languages",
                      (book['languages'] is List)
                          ? book['languages'].join(', ')
                          : 'Unknown',
                    ),
                    buildDetailRow(
                      "Copyright",
                      book['copyright'] == true ? 'Yes' : 'No',
                    ),
                    buildDetailRow(
                      "Media Type",
                      book['media_type'] ?? 'Unknown',
                    ),
                    buildDetailRow(
                      "Download Count",
                      book['download_count']?.toString() ?? '0',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
