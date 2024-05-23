import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mobile/models/login_response/user.dart';

class DatabaseHelper {
  late Database _database;

  Future<Database> get database async {
    await _initDatabase(); // Memastikan inisialisasi database sebelum digunakan
    return _database;
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'akhwat_computer2.db'),
      onCreate: (db, version) {
        // Membuat tabel user jika belum ada
        return db.execute(
          "CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, name TEXT, email TEXT, alamat TEXT, username TEXT, no_hp TEXT, agama TEXT, tanggal_lahir TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertUser(User user) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Data user berhasil disimpan ke database.');
    } catch (e) {
      print('Terjadi kesalahan saat menyimpan data user ke database: $e');
    }
  }

  Future<void> updateProfile(User user) async {
    try {
      final db = await database;
      await db.update(
        'users',
        user.toMap(),
        where: "id = ?",
        whereArgs: [user.id],
      );
      print('Data user berhasil diperbarui di database.');
    } catch (e) {
      print('Terjadi kesalahan saat memperbarui data user di database: $e');
    }
  }
}