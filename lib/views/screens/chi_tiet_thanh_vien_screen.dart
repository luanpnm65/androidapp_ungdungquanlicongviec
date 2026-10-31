import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/nguoi_dung.dart';

class ChiTietThanhVienScreen extends StatelessWidget {
  final NguoiDung thanhVien;

  const ChiTietThanhVienScreen({Key? key, required this.thanhVien}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(thanhVien.ten ?? 'Chi tiết thành viên'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, size: 80, color: Colors.blue[700]),
              ),
            ),
            const SizedBox(height: 24),
            // Thông tin
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ItemThongTin(tieuDe: 'Tên', noiDung: thanhVien.ten ?? 'Chưa cập nhật'),
                    const Divider(),
                    _ItemThongTin(tieuDe: 'Email', noiDung: thanhVien.email),
                    if (thanhVien.sdt != null) ...[
                      const Divider(),
                      _ItemThongTin(tieuDe: 'Số điện thoại', noiDung: thanhVien.sdt!),
                    ],
                    if (thanhVien.viTri != null) ...[
                      const Divider(),
                      _ItemThongTin(tieuDe: 'Vị trí', noiDung: thanhVien.viTri!),
                    ],
                    const Divider(),
                    _ItemThongTin(
                      tieuDe: 'Tham gia từ',
                      noiDung: thanhVien.ngayTao.toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemThongTin extends StatelessWidget {
  final String tieuDe;
  final String noiDung;

  const _ItemThongTin({required this.tieuDe, required this.noiDung});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              tieuDe,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              noiDung,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}