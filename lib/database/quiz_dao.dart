import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class QuizDAO {

  // Guarda el nivel desbloqueado actual
  Future<void> saveProgress(int levelIndex) async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      'quiz_progress',
      {'id': 1, 'levelIndex': levelIndex},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Devuelve el nivel desbloqueado
  Future<int> getUnlockedLevels() async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'quiz_progress',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isEmpty) return 0;

    return result.first['levelIndex'] as int;
  }

  // Registrar un intento
  Future<void> registerAttempt() async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      'quiz_attempts',
      {'timestamp': DateTime.now().millisecondsSinceEpoch},
    );
  }

  // Obtener total de intentos
  Future<int> getAttempts() async {
    final db = await AppDatabase.instance.database;

    final result = await db.query('quiz_attempts');
    return result.length;
  }
}



