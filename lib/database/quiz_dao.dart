import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class QuizDAO {
  /// Guarda progreso cuando un nivel se aprueba
  Future<void> saveProgress(int levelIndex) async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      'quiz_progress',
      {'levelIndex': levelIndex, 'completed': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene cuántos niveles están desbloqueados
  Future<int> getUnlockedLevels() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('quiz_progress');
    return result.length;
  }

  /// 🔥 NUEVO: Registrar cada intento de quiz (aprobado o no)
  Future<void> registerAttempt() async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      'quiz_attempts',
      {'timestamp': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// 🔥 NUEVO: Obtener cuántos intentos lleva el usuario
  Future<int> getAttempts() async {
    final db = await AppDatabase.instance.database;

    final result = await db.query('quiz_attempts');
    return result.length;
  }
}


