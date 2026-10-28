import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,     // ← ¡SUBIMOS LA VERSIÓN!
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Nueva tabla de progreso (solo 1 fila)
    await db.execute('''
      CREATE TABLE quiz_progress (
        id INTEGER PRIMARY KEY,
        levelIndex INTEGER NOT NULL
      );
    ''');

    // Inicializamos progreso en nivel 0
    await db.insert('quiz_progress', {'id': 1, 'levelIndex': 0});

    // Tabla de intentos
    await db.execute('''
      CREATE TABLE quiz_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL
      );
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Eliminamos tabla vieja
      await db.execute('DROP TABLE IF EXISTS quiz_progress');

      // Creamos versión corregida
      await db.execute('''
        CREATE TABLE quiz_progress (
          id INTEGER PRIMARY KEY,
          levelIndex INTEGER NOT NULL
        );
      ''');

      // Insertar progreso inicial
      await db.insert('quiz_progress', {'id': 1, 'levelIndex': 0});
    }
  }
}

