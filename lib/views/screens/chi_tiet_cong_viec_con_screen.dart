import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cong_viec_con_controller.dart';
import '../../models/cong_viec_con.dart';

class ChiTietCongViecConScreen extends StatelessWidget {
  final CongViecCon congViecCon;
  final bool laChuDuAn;

  const ChiTietCongViecConScreen({
    Key? key,
    required this.congViecCon,
    required this.laChuDuAn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cvConController = Get.find<CongViecConController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc con'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              congViecCon.tieuDe,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin cơ bản
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ItemThongTin(
                      icon: Icons.info,
                      label: 'Trạng thái',
                      value: _layTenTrangThai(),
                    ),
                    const Divider(),
                    if (congViecCon.tenNguoiNhan != null) ...[
                      _ItemThongTin(
                        icon: Icons.person,
                        label: 'Người nhận',
                        value: congViecCon.tenNguoiNhan!,
                      ),
                      const Divider(),
                    ],
                    if (congViecCon.ngayHetHan != null) ...[
                      _ItemThongTin(
                        icon: Icons.calendar_today,
                        label: 'Deadline',
                        value: congViecCon.ngayHetHan.toString().split(' ')[0],
                      ),
                      const Divider(),
                    ],
                    _ItemThongTin(
                      icon: Icons.access_time,
                      label: 'Tạo lúc',
                      value: congViecCon.ngayTao.toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mô tả
            if (congViecCon.moTa != null) ...[
              const Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(congViecCon.moTa!),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Nút hành động
            if (congViecCon.trangThai == TrangThaiCongViecCon.chuaNhan)
              ElevatedButton.icon(
                onPressed: () async {
                  await cvConController.nhanCongViecCon(congViecCon.id);
                  Get.back();
                },
                icon: const Icon(Icons.check),
                label: const Text('Nhận công việc con'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                ),
              )
            else if (congViecCon.trangThai != TrangThaiCongViecCon.hoanThanh)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await cvConController.capNhatTrangThaiCongViecCon(
                          congViecCon.id,
                          TrangThaiCongViecCon.dangThucHien,
                        );
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Đang làm'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await cvConController.capNhatTrangThaiCongViecCon(
                          congViecCon.id,
                          TrangThaiCongViecCon.hoanThanh,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Hoàn thành'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _layTenTrangThai() {
    switch (congViecCon.trangThai) {
      case TrangThaiCongViecCon.chuaNhan:
        return 'Chưa nhận';
      case TrangThaiCongViecCon.daNhan:
        return 'Đã nhận';
      case TrangThaiCongViecCon.dangThucHien:
        return 'Đang làm';
      case TrangThaiCongViecCon.hoanThanh:
        return 'Hoàn thành';
      case TrangThaiCongViecCon.quaHan:
        return 'Quá hạn';
    }
  }
}

class _ItemThongTin extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ItemThongTin({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}