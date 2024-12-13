import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/favorite_book_model.dart';
import 'book_details_screen.dart';

class FavoriteBooksScreen extends StatefulWidget {
  @override
  _FavoriteBooksScreenState createState() => _FavoriteBooksScreenState();
}

class _FavoriteBooksScreenState extends State<FavoriteBooksScreen> {
  List<FavoriteBook> favorites = [];
  List<FavoriteBook> filteredFavorites = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final fetchedFavorites = await DatabaseHelper.instance.getFavorites();
    setState(() {
      favorites = fetchedFavorites;
      filteredFavorites = List.from(favorites);
    });
  }

  Future<void> removeFavorite(int id) async {
    await DatabaseHelper.instance.deleteFavorite(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book removed from favorites!')),
    );
    fetchFavorites();
  }

  void searchFavorites(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFavorites = List.from(favorites);
      } else {
        filteredFavorites = favorites
            .where((book) =>
                (book.title ?? '').toLowerCase().contains(query.toLowerCase()) ||
                (book.author ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void navigateToDetailScreen(FavoriteBook book) {
    print('Navigating to details screen with book: ${book.title}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(book: {
          'id': book.id,
          'title': book.title ?? 'Untitled',
          'authors': book.author != null ? [{'name': book.author}] : [],
          'formats': {'image/jpeg': book.imageUrl},
          'subjects': book.subjects?.split(',') ?? [],
          'translators': book.translators?.split(',') ?? [],
          'bookshelves': book.bookshelves?.split(',') ?? [],
          'languages': book.languages?.split(',') ?? [],
          'copyright': book.copyright,
          'media_type': book.mediaType,
          'download_count': book.downloadCount ?? 0,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Books'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search favorite books...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: searchFavorites,
            ),
          ),
          Expanded(
            child: filteredFavorites.isEmpty
                ? const Center(child: Text('No favorite books found.'))
                : ListView.builder(
                    itemCount: filteredFavorites.length,
                    itemBuilder: (context, index) {
                      final book = filteredFavorites[index];
                      return Card(
                        color: const Color.fromARGB(255, 219, 245, 242),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.teal, width: 1),
                        ),
                        child: InkWell(
                          onTap: () => navigateToDetailScreen(book), // Tap Detection
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 150,
                                  child: book.imageUrl != null
                                      ? Image.network(
                                          book.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.broken_image,
                                                size: 60, color: Colors.grey);
                                          },
                                        )
                                      : const Icon(Icons.book,
                                          size: 60, color: Colors.teal),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Title: ${book.title}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Author: ${book.author}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => removeFavorite(
                                    int.tryParse(book.id.toString()) ??
                                        book.id,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}