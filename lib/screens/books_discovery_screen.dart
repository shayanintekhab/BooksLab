import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_details_screen.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen>
    with AutomaticKeepAliveClientMixin {
  final Map<int, List> pagesCache = {}; // Cache pages with fetched books
  List originalBooks = [];
  List displayedBooks = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBooks(currentPage);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          hasMore &&
          !isLoading) {
        fetchBooks(currentPage + 1);
      }
    });
  }

  @override
  bool get wantKeepAlive => true; // Enable state persistence

  Future<void> fetchBooks(int page) async {
    if (isLoading || pagesCache.containsKey(page) || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final url = 'https://gutendex.com/books/?page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newBooks = data['results'];

      setState(() {
        pagesCache[page] = newBooks;
        originalBooks.addAll(newBooks);
        currentPage = page;
        if (data['next'] == null) {
          hasMore = false;
        }
        filterBooks(searchController.text); // Maintain search results
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void navigateToDetailScreen(book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(book: book),
      ),
    );
  }

  void filterBooks(String query) {
    if (query.isEmpty) {
      setState(() {
        displayedBooks = List.from(originalBooks);
      });
    } else {
      setState(() {
        displayedBooks = originalBooks
            .where((book) {
              final title = book['title']?.toLowerCase() ?? '';
              final author = book['authors'].isNotEmpty
                  ? book['authors'][0]['name'].toLowerCase()
                  : '';
              return title.contains(query.toLowerCase()) ||
                  author.contains(query.toLowerCase());
            })
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build to ensure mixin works
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Books'),
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
                hintText: 'Search books...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterBooks,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: displayedBooks.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayedBooks.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final book = displayedBooks[index];
                return GestureDetector(
                  onTap: () => navigateToDetailScreen(book),
                  child: Card(
                    color: Color.fromARGB(255, 219, 245, 242).withOpacity(1),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.teal, width: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 100,
                              height: 150,
                              child: book['formats']['image/jpeg'] != null
                                  ? Image.network(
                                      book['formats']['image/jpeg'],
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
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Title: ${book['title'] ?? 'Untitled'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Author: ${book['authors'].isNotEmpty ? book['authors'][0]['name'] : 'Unknown'}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
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

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
