class Pesanan {
  final int noId;
  final String nama;
  final int qty;
  final int total;
  final String note;
  final String ciriPembeli;
  final String createdAt;
  final int timestamp;
  final String status;

  Pesanan({
    required this.noId,
    required this.nama,
    required this.qty,
    required this.total,
    required this.note,
    required this.ciriPembeli,
    required this.createdAt,
    required this.timestamp,
    required this.status,
  });

  // Method to convert Map to Pesanan object
  factory Pesanan.fromMap(Map<String, dynamic> map) {
    return Pesanan(
      noId: map['no_id'],
      nama: map['nama'],
      qty: map['qty'],
      total: map['total'],
      note: map['note'],
      ciriPembeli: map['ciri_pembeli'],
      createdAt: map['created_at'],
      timestamp: map['timestamp'],
      status: map['status'],
    );
  }

  // Method to convert Pesanan object to Map
  Map<String, dynamic> toMap() {
    return {
      'no_id': noId,
      'nama': nama,
      'qty': qty,
      'total': total,
      'note': note,
      'ciri_pembeli': ciriPembeli,
      'created_at': createdAt,
      'timestamp': timestamp,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'Pesanan(noId: $noId, nama: $nama, qty: $qty, total: $total, note: $note, ciriPembeli: $ciriPembeli, createdAt: $createdAt, timestamp: $timestamp, status: $status)';
  }
}
