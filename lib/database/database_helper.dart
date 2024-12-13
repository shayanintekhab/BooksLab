import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/favorite_book_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorite_books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorite_books (
        id INTEGER PRIMARY KEY,
        title TEXT,
        author TEXT,
        subjects TEXT,
        translators TEXT,
        bookshelves TEXT,
        languages TEXT,
        copyright TEXT,
        mediaType TEXT,
        downloadCount TEXT,
        imageUrl TEXT
      )
    ''');
  }

  Future<void> insertFavorite(FavoriteBook book) async {
    final db = await instance.database;
    try {
      await db.insert(
        'favorite_books',
        book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Inserted book: ${book.toMap()}");
    } catch (e) {
      print("Error inserting book: $e");
      rethrow;
    }
  }

  Future<bool> checkFavoriteExists(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'favorite_books',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<void> deleteFavorite(int id) async {
    final db = await instance.database;
    await db.delete('favorite_books', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FavoriteBook>> getFavorites() async {
    final db = await instance.database;
    final maps = await db.query('favorite_books');
    return maps.map((map) => FavoriteBook.fromMap(map)).toList();
  }
}
