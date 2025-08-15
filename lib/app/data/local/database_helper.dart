import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pesanan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // versi DB dinaikkan
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE pesanan (
      nama TEXT,
      qty INTEGER,
      total INTEGER,
      note TEXT,
      ciri_pembeli TEXT,
      created_at TEXT,
      no_id INTEGER,
      timestamp INTEGER,
      status TEXT
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE pesanan ADD COLUMN order_id TEXT');
      await db.execute('ALTER TABLE pesanan ADD COLUMN no_id INTEGER');
      await db.execute('ALTER TABLE pesanan ADD COLUMN timestamp INTEGER');
      await db.execute('ALTER TABLE pesanan ADD COLUMN status TEXT');
    }
  }

  Future<int> insertPesanan(
    String nama,
    int qty,
    int total,
    String note,
    String ciriPembeli, {
    String status = "true",
  }) async {
    final db = await database;

    final now = DateTime.now();
    final noId = int.parse(
      '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}',
    );
    final timestamp = now.millisecondsSinceEpoch;

    return await db.insert('pesanan', {
      'no_id': noId,
      'nama': nama,
      'qty': qty,
      'total': total,
      'note': note,
      'ciri_pembeli': ciriPembeli,
      'created_at': now.toIso8601String(),
      'timestamp': timestamp,
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> getPesanan() async {
    final db = await database;
    // penting: ambil rowid sebagai id
    return await db.rawQuery('SELECT rowid AS id, * FROM pesanan');
  }

  // === FUNGSI DELETE BERDASARKAN no_id ===
  Future<int> deletePesanan(int noId) async {
    final db = await database;
    return await db.delete('pesanan', where: 'no_id = ?', whereArgs: [noId]);
  }

  // Tambahkan method update status pesanan
  Future<int> SelesaiMasak(int noId, bool isDone) async {
    final db = await database;
    return await db.update(
      'pesanan',
      {'status': isDone ? 'selesai_masak' : ''}, // 1 = true, 0 = false
      where: 'no_id = ?',
      whereArgs: [noId],
    );
  }

  Future<int> SelesaiBayar(int noId, bool isDone) async {
    final db = await database;
    return await db.update(
      'pesanan',
      {'status': isDone ? 'selesai_bayar' : 'false'}, // 1 = true, 0 = false
      where: 'no_id = ?',
      whereArgs: [noId],
    );
  }

  Future<int> updatePesanan(
    int id, {
    String? nama,
    int? qty,
    String? note,
    int? total,
  }) async {
    final db = await database;
    final data = <String, Object?>{};
    if (nama != null) data['nama'] = nama;
    if (qty != null) data['qty'] = qty;
    if (note != null) data['note'] = note;
    if (total != null) data['total'] = total;

    if (data.isEmpty) return 0;

    return await db.update(
      'pesanan',
      data,
      where: 'rowid = ?',
      whereArgs: [id],
    );
  }
}
