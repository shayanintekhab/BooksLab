class FavoriteBook {
  final int id;
  final String title;
  final String author;
  final String subjects;
  final String translators;
  final String bookshelves;
  final String languages;
  final String copyright;
  final String mediaType;
  final String downloadCount;
  final String imageUrl;

  FavoriteBook({
    required this.id,
    required this.title,
    required this.author,
    required this.subjects,
    required this.translators,
    required this.bookshelves,
    required this.languages,
    required this.copyright,
    required this.mediaType,
    required this.downloadCount,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'subjects': subjects,
      'translators': translators,
      'bookshelves': bookshelves,
      'languages': languages,
      'copyright': copyright,
      'mediaType': mediaType,
      'downloadCount': downloadCount,
      'imageUrl': imageUrl,
    };
  }

  factory FavoriteBook.fromMap(Map<String, dynamic> map) {
    return FavoriteBook(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      subjects: map['subjects'],
      translators: map['translators'],
      bookshelves: map['bookshelves'],
      languages: map['languages'],
      copyright: map['copyright'],
      mediaType: map['mediaType'],
      downloadCount: map['downloadCount'],
      imageUrl: map['imageUrl'],
    );
  }
}
