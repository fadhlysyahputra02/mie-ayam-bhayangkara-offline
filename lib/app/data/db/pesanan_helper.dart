import 'package:sqflite/sqflite.dart';

class PesananHelper {
  static Map<String, dynamic> createPesananData({
    required String nama,
    required int qty,
    required int total,
    required String note,
    required String ciriPembeli,
    required String kategori, // tambahkan ini
    String status = "true",
  }) {
    final now = DateTime.now();
    final noId = int.parse(
      '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}',
    );
    final timestamp = now.millisecondsSinceEpoch;

    return {
      'no_id': noId,
      'nama': nama,
      'qty': qty,
      'total': total,
      'note': note,
      'ciri_pembeli': ciriPembeli,
      'kategori': kategori, // simpan di DB
      'created_at': now.toIso8601String(),
      'timestamp': timestamp,
      'status': status,
    };
  }

  static Future<List<Map<String, dynamic>>> getPesananList(Database db) async {
    return await db.rawQuery('SELECT rowid AS id, * FROM pesanan');
  }

  static Future<int> updatePesananStatus(
    Database db,
    int noId,
    String status,
  ) async {
    return await db.update(
      'pesanan',
      {'status': status},
      where: 'no_id = ?',
      whereArgs: [noId],
    );
  }

  static Future<int> updatePesananTimestamp(
    Database db,
    int noId,
    int newTimestamp,
  ) async {
    final createdAtString = DateTime.fromMillisecondsSinceEpoch(
      newTimestamp,
    ).toIso8601String();
    return await db.update(
      'pesanan',
      {'timestamp': newTimestamp, 'created_at': createdAtString},
      where: 'no_id = ?',
      whereArgs: [noId],
    );
  }
}
