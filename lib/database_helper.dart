import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'card_organizer.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image TEXT NOT NULL,  -- Storing image as string (URL or base64)
        folder_id INTEGER,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
      )
    ''');

    // Insert default folders
    await db.insert('folders', {'name': 'Hearts'});
    await db.insert('folders', {'name': 'Spades'});
    await db.insert('folders', {'name': 'Diamonds'});
    await db.insert('folders', {'name': 'Clubs'});
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await database;
    return await db.query('folders');
  }

  Future<List<Map<String, dynamic>>> getCardsInFolder(int folderId) async {
    final db = await database;
    return await db.query('cards', where: 'folder_id = ?', whereArgs: [folderId]);
  }

  Future<int> getCardCount(int folderId) async {
    final db = await database;
    var result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM cards WHERE folder_id = ?", [folderId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> addCard(String name, String suit, String image, int folderId) async {
    final db = await database;
    int count = await getCardCount(folderId);

    if (count >= 6) {
      throw Exception("This folder can only hold 6 cards.");
    }

    await db.insert('cards', {
      'name': name,
      'suit': suit,
      'image': image,
      'folder_id': folderId,
    });
  }

  Future<void> deleteCard(int cardId) async {
    final db = await database;
    await db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }
}
