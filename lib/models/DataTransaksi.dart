import 'package:meta/meta.dart';

class DataTransaksi {
  final String id;
  final String idKaryawan;
  final double totalHarga;
  final double qty;
  final double bayar;
  final double kembalian;

  DataTransaksi({
    required this.id,
    required this.idKaryawan,
    required this.totalHarga,
    required this.qty,
    required this.bayar,
    required this.kembalian,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_karyawan': idKaryawan,
      'total_harga': totalHarga,
      'qty': qty,
      'bayar': bayar,
      'kembalian': kembalian,
    };
  }
}
