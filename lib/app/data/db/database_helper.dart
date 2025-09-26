import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'pesanan_helper.dart';

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
      version: 3,
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
    final data = PesananHelper.createPesananData(
      nama: nama,
      qty: qty,
      total: total,
      note: note,
      ciriPembeli: ciriPembeli,
      status: status,
    );
    return await db.insert('pesanan', data);
  }

  Future<List<Map<String, dynamic>>> getPesanan() async {
    final db = await database;
    return await PesananHelper.getPesananList(db);
  }

  Future<int> deletePesanan(int noId) async {
    final db = await database;
    return await db.delete('pesanan', where: 'no_id = ?', whereArgs: [noId]);
  }

  Future<int> deleteAllPesanan() async {
    final db = await database;
    return await db.delete('pesanan');
  }

  Future<int> SelesaiMasak(int noId, bool isDone) async {
    final db = await database;
    return await PesananHelper.updatePesananStatus(db, noId, isDone ? 'selesai_masak' : '');
  }

  Future<int> SelesaiBayar(int noId, bool isDone) async {
    final db = await database;
    return await PesananHelper.updatePesananStatus(db, noId, isDone ? 'selesai_bayar' : 'false');
  }

  Future<int> SelesaiBayarSemua() async {
    final db = await database;
    return await db.update(
      'pesanan',
      {'status': 'selesai_bayar'},
      where: 'status != ?',
      whereArgs: ['selesai_bayar'],
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

  Future<int> updateTimestamp(int noId, int newTimestamp) async {
    final db = await database;
    return await PesananHelper.updatePesananTimestamp(db, noId, newTimestamp);
  }
}
