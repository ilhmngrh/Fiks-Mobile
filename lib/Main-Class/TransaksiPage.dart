import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Tambahkan ini untuk format tanggal
import 'package:mobile/HomePage.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/DataBarang.dart';
import 'package:mobile/models/DataTransaksi.dart';
import 'package:mobile/models/Keranjang.dart'; // Sesuaikan dengan path proyek Anda
import 'package:http/http.dart' as http;
import 'package:mobile/view/Home.dart';
import 'package:mobile/view/Transaction.dart';
import 'dart:convert';
import 'package:provider/provider.dart'; // Import provider
import 'package:mobile/view/Transaction.dart';
import 'package:mobile/Main-Class/Struk.dart';
import 'package:mobile/models/login_response/user.dart';

class TransaksiPage extends StatefulWidget {
  final List<Barang> keranjang;
  final double totalHarga;
  final int qty;
  final int jumlahBarang;
  final Map<Barang, int> barangQtyMap;
  final Map<Barang, double> hargaSetelahDiskonBarang;
  final User currentUser; // Assuming User is the type of your currentUser
  final int id;

  const TransaksiPage({
    Key? key,
    required this.keranjang,
    required this.totalHarga,
    required this.qty,
    required this.jumlahBarang,
    required this.barangQtyMap, // Tambahkan barangQtyMap di sini
    required this.currentUser,
    required this.hargaSetelahDiskonBarang,
    required this.id,
  }) : super(key: key);

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCustomerController = TextEditingController();
  final _bayarController = TextEditingController();
  User currentUser = User();

  String generateTransactionId() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    return 'TRX$formattedDate';
  }

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  @override
  void dispose() {
    _namaCustomerController.dispose();
    _bayarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung total harga berdasarkan jumlah barang
    double totalHarga = 0;
    widget.barangQtyMap.forEach((barang, qty) {
      totalHarga += barang.hargaSetelahDiskonBarang * qty;
    });

    String transactionId = generateTransactionId();
    String formattedDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tanggal dan ID Transaksi
              Container(
                margin: EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal: $formattedDate',
                      style: GoogleFonts.getFont(
                        'Inria Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.3,
                        color: Color(0xFF8B8E99),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID Transaksi: $transactionId',
                      style: GoogleFonts.getFont(
                        'Inria Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.3,
                        color: Color(0xFF8B8E99),
                      ),
                    ),
                  ],
                ),
              ),
              // Form untuk Nama Customer
              Container(
                margin: EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: TextFormField(
                  controller: _namaCustomerController,
                  decoration: InputDecoration(
                    labelText: 'Nama Customer',
                    labelStyle: TextStyle(
                      color: Color(0xFF8B8E99),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Customer tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              // Detail Pesanan
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DETAIL PESANAN',
                      style: GoogleFonts.getFont(
                        'Inria Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.3,
                        color: Color(0xFF8B8E99),
                      ),
                    ),
                    SizedBox(height: 10),
                    Table(
                      border: TableBorder.all(color: Color(0xFF8B8E99)),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Nama Barang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF8B8E99),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF8B8E99),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Harga',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF8B8E99),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        for (var barang in widget.keranjang.toSet())
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    barang.namaBarang,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8B8E99),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (widget.barangQtyMap[barang]! >
                                              1) {
                                            widget.barangQtyMap[barang] =
                                                widget.barangQtyMap[barang]! -
                                                    1;
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.remove),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${widget.barangQtyMap[barang]}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8B8E99),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (widget.barangQtyMap[barang]! <
                                              barang.stokBarang) {
                                            widget.barangQtyMap[barang] =
                                                widget.barangQtyMap[barang]! +
                                                    1;
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Stok ${barang.namaBarang} habis'),
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Rp. ${(barang.hargaSetelahDiskonBarang * widget.barangQtyMap[barang]!).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8B8E99),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(25, 24, 27, 12.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 2.5),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Total Harga',
                          style: GoogleFonts.getFont(
                            'Inria Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            height: 1.3,
                            color: Color(0xFF8B8E99),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Rp. ${totalHarga.toStringAsFixed(2)}',
                      style: GoogleFonts.getFont(
                        'Inria Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 1.3,
                        color: Color(0xFF8B8E99),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(25, 0, 27, 12.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 2.5),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Jumlah Bayar',
                          style: GoogleFonts.getFont(
                            'Inria Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            height: 1.3,
                            color: Color(0xFF8B8E99),
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _bayarController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Masukkan jumlah bayar',
                        hintStyle: GoogleFonts.getFont(
                          'Inria Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          height: 1.3,
                          color: Color(0xFF8B8E99),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah bayar tidak boleh kosong';
                        } else if (double.tryParse(value) == null) {
                          return 'Jumlah bayar harus berupa angka';
                        } else if (double.parse(value) < totalHarga) {
                          return 'Jumlah bayar tidak boleh kurang dari total harga';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(25, 0, 27, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 2.5),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Kembalian',
                          style: GoogleFonts.getFont(
                            'Inria Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            height: 1.3,
                            color: Color(0xFF8B8E99),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Rp. ${_bayarController.text.isNotEmpty ? (double.tryParse(_bayarController.text) ?? 0) - totalHarga : 0}',
                      style: GoogleFonts.getFont(
                        'Inria Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 1.3,
                        color: Color(0xFF8B8E99),
                      ),
                    ),
                  ],
                ),
              ),

Container(
  margin: EdgeInsets.fromLTRB(26, 0, 26, 190),
  decoration: BoxDecoration(
    border: Border.all(color: Color(0xFFFD006B)),
    borderRadius: BorderRadius.circular(5),
    color: Color(0xFFFD006B),
  ),
  child: InkWell(
    onTap: () async {
      if (_formKey.currentState!.validate()) {
        Keranjang transaksi = Keranjang(
          id: transactionId,
          idKaryawan: 'KRY123',
          totalHarga: totalHarga,
          qty: widget.keranjang.length,
          bayar: double.parse(_bayarController.text),
          kembalian: double.parse(_bayarController.text) - totalHarga,
        );

        double kembalian =
            double.parse(_bayarController.text) - totalHarga;

                      for (var barang in widget.keranjang) {
                        double kembalian =
                            double.parse(_bayarController.text) - totalHarga;

                        try {
                          final response = await http.post(
                            Uri.parse('http://127.0.0.1:8000/api/transaksi'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(<String, dynamic>{
                              // Struktur data Anda di sini
                              'id_karyawan': currentUser.id
                                  .toString(), // Assuming currentUser.id is correctly defined
                              'total_harga': totalHarga
                                  .toString(), // Assuming totalHarga is correctly defined
                              'bayar': _bayarController
                                  .text, // Assuming _bayarController is correctly defined
                              'kembalian': kembalian
                                  .toString(), // Assuming kembalian is correctly defined
                              //masukkan id_barang saja ke dalam list
                              'id_barang': barang
                                  .id, // Kirim id_barang sebagai single item
                              'qty': widget.barangQtyMap[
                                  barang], // Kirim qty sebagai single
                              'sub_total': widget.hargaSetelahDiskonBarang[
                                  barang], // Kirim sub_total sebagai single item
                            }),
                          );

                         if (response.statusCode == 200 || response.statusCode == 201) {
  // Sukses
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StrukPage(
        transactionId: transactionId,
        namaCustomer: 'Nama Customer', // Ganti dengan data nama customer Anda
        formattedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()), // Ganti dengan format tanggal yang sesuai
        totalHarga: totalHarga,
        bayar: double.parse(_bayarController.text),
        kembalian: kembalian,
        barangQtyMap: widget.barangQtyMap,
      ),
    ),
  );
} else {
  // Gagal
  final responseBody = jsonDecode(response.body);
  print('Gagal melakukan transaksi: ${responseBody['message']}');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Gagal melakukan transaksi: ${responseBody['message']}'),
    ),
  );
}
} catch (e) {
                          print('Exception caught: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Terjadi kesalahan saat melakukan transaksi')),
                          );
                        }
                      }
                    }
                    ;
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 3.5, 0, 2.5),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.getFont(
                        'Inria Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.3,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
