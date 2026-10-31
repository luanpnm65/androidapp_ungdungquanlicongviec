import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cong_viec_controller.dart';
import '../../controllers/cong_viec_con_controller.dart';
import '../../models/cong_viec.dart';
import '../../models/cong_viec_con.dart';
import '../../services/supabase_service.dart';
import '../screens/chi_tiet_cong_viec_screen.dart';
import '../screens/chi_tiet_cong_viec_con_screen.dart';

class TheCongViec extends StatefulWidget {
  final CongViec congViec;
  final bool laChuDuAn;

  const TheCongViec({
    Key? key,
    required this.congViec,
    required this.laChuDuAn,
  }) : super(key: key);

  @override
  State<TheCongViec> createState() => _TheCongViecState();
}

class _TheCongViecState extends State<TheCongViec> {
  bool _moRong = false;
  List<CongViecCon> _danhSachCVCon = [];
  bool _dangTaiDuLieu = false;

  Future<void> _taiDanhSachCVCon() async {
    try {
      setState(() => _dangTaiDuLieu = true);

      final response = await SupabaseService.client
          .from('cong_viec_con')
          .select()
          .eq('cong_viec_cha_id', widget.congViec.id)
          .order('ngay_tao', ascending: false);

      List<CongViecCon> danhSach = [];

      for (var json in (response as List)) {
        var cvCon = CongViecCon.tuJson(json as Map<String, dynamic>);

        // Lấy tên người nhận nếu có
        if (cvCon.nguoiNhanId != null) {
          try {
            final hoSo = await SupabaseService.client
                .from('ho_so_nguoi_dung')
                .select('ten')
                .eq('id', cvCon.nguoiNhanId!)
                .single();

            cvCon = CongViecCon(
              id: cvCon.id,
              congViecChaId: cvCon.congViecChaId,
              tieuDe: cvCon.tieuDe,
              moTa: cvCon.moTa,
              ngayTao: cvCon.ngayTao,
              ngayHetHan: cvCon.ngayHetHan,
              nguoiNhanId: cvCon.nguoiNhanId,
              tenNguoiNhan: hoSo['ten'] ?? 'Chưa cập nhật tên',
              trangThai: cvCon.trangThai,
            );
          } catch (e) {
            print('Lỗi lấy tên: $e');
          }
        }

        danhSach.add(cvCon);
      }

      setState(() {
        _danhSachCVCon = danhSach;
      });
    } catch (e) {
      print('Lỗi tải công việc con: $e');
    } finally {
      setState(() => _dangTaiDuLieu = false);
    }
  }

  Color _layMauTrangThai() {
    switch (widget.congViec.trangThai) {
      case TrangThaiCongViec.chuaNhan:
        return Colors.grey;
      case TrangThaiCongViec.daNhan:
        return Colors.blue;
      case TrangThaiCongViec.dangThucHien:
        return Colors.orange;
      case TrangThaiCongViec.hoanThanh:
        return Colors.green;
      case TrangThaiCongViec.quaHan:
        return Colors.red;
    }
  }

  String _layTenTrangThai() {
    switch (widget.congViec.trangThai) {
      case TrangThaiCongViec.chuaNhan:
        return 'Chưa nhận';
      case TrangThaiCongViec.daNhan:
        return 'Đã nhận';
      case TrangThaiCongViec.dangThucHien:
        return 'Đang làm';
      case TrangThaiCongViec.hoanThanh:
        return 'Hoàn thành';
      case TrangThaiCongViec.quaHan:
        return 'Quá hạn';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CongViecController>();
    final cvConController = Get.isRegistered<CongViecConController>()
        ? Get.find<CongViecConController>()
        : Get.put(CongViecConController());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.task_alt,
              color: _layMauTrangThai(),
            ),
            title: Text(
              widget.congViec.tieuDe,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(
                        _layTenTrangThai(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: _layMauTrangThai(),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (widget.congViec.tenNguoiNhan != null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          widget.congViec.tenNguoiNhan!,
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.purple[100],
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
                if (widget.congViec.ngayHetHan != null)
                  Text(
                    'Deadline: ${widget.congViec.ngayHetHan.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.congViec.daQuaHan ? Colors.red : Colors.grey,
                      fontWeight:
                      widget.congViec.daQuaHan ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            trailing: Icon(_moRong ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              if (!_moRong) {
                _taiDanhSachCVCon();
              }
              setState(() => _moRong = !_moRong);
            },
          ),
          // Nội dung mở rộng
          if (_moRong)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(),
                  // Nút hành động công việc chính
                  if (widget.congViec.trangThai == TrangThaiCongViec.chuaNhan)
                    ElevatedButton.icon(
                      onPressed: () => controller.nhanCongViec(widget.congViec.id),
                      icon: const Icon(Icons.check),
                      label: const Text('Nhận công việc'),
                    )
                  else if (widget.congViec.trangThai != TrangThaiCongViec.hoanThanh)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => controller.capNhatTrangThai(
                              widget.congViec.id,
                              TrangThaiCongViec.dangThucHien,
                            ),
                            child: const Text('Đang làm'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.capNhatTrangThai(
                              widget.congViec.id,
                              TrangThaiCongViec.hoanThanh,
                            ),
                            child: const Text('Hoàn thành'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  // Nút xem chi tiết
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => ChiTietCongViecScreen(
                        congViec: widget.congViec,
                        laChuDuAn: widget.laChuDuAn,
                      ));
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Xem chi tiết'),
                  ),
                  const SizedBox(height: 16),
                  // Công việc con
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Công việc con:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (widget.laChuDuAn)
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () {
                            // Gọi dialog tạo CV con từ chi tiết dự án
                            Get.to(() => ChiTietCongViecScreen(
                              congViec: widget.congViec,
                              laChuDuAn: widget.laChuDuAn,
                            ));
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_dangTaiDuLieu)
                    const Center(child: CircularProgressIndicator())
                  else if (_danhSachCVCon.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Chưa có công việc con',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _danhSachCVCon.length,
                      itemBuilder: (context, index) {
                        final cvCon = _danhSachCVCon[index];
                        return _xayDungTheCongViecCon(cvCon, cvConController);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _xayDungTheCongViecCon(
      CongViecCon cvCon, CongViecConController cvConController) {
    Color _layMauTrangThaiCon() {
      switch (cvCon.trangThai) {
        case TrangThaiCongViecCon.chuaNhan:
          return Colors.grey;
        case TrangThaiCongViecCon.daNhan:
          return Colors.blue;
        case TrangThaiCongViecCon.dangThucHien:
          return Colors.orange;
        case TrangThaiCongViecCon.hoanThanh:
          return Colors.green;
        case TrangThaiCongViecCon.quaHan:
          return Colors.red;
      }
    }

    String _layTenTrangThaiCon() {
      switch (cvCon.trangThai) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: ListTile(
        leading: const Icon(Icons.subdirectory_arrow_right, size: 20),
        title: Text(
          cvCon.tieuDe,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(
                    _layTenTrangThaiCon(),
                    style: const TextStyle(fontSize: 9, color: Colors.white),
                  ),
                  backgroundColor: _layMauTrangThaiCon(),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 3),
                  visualDensity: VisualDensity.compact,
                ),
                if (cvCon.tenNguoiNhan != null) ...[
                  const SizedBox(width: 4),
                  Chip(
                    label: Text(
                      cvCon.tenNguoiNhan!,
                      style: const TextStyle(fontSize: 9),
                    ),
                    backgroundColor: Colors.purple[100],
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.info, size: 18),
                  SizedBox(width: 8),
                  Text('Chi tiết'),
                ],
              ),
              onTap: () {
                Get.to(() => ChiTietCongViecConScreen(
                  congViecCon: cvCon,
                  laChuDuAn: widget.laChuDuAn,
                ));
              },
            ),
            if (cvCon.trangThai == TrangThaiCongViecCon.chuaNhan)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.check, size: 18),
                    SizedBox(width: 8),
                    Text('Nhận'),
                  ],
                ),
                onTap: () async {
                  await cvConController.nhanCongViecCon(cvCon.id);
                },
              ),
            if (cvCon.trangThai != TrangThaiCongViecCon.hoanThanh)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.done, size: 18),
                    SizedBox(width: 8),
                    Text('Hoàn thành'),
                  ],
                ),
                onTap: () async {
                  await cvConController.capNhatTrangThaiCongViecCon(
                    cvCon.id,
                    TrangThaiCongViecCon.hoanThanh,
                  );
                },
              ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa công việc con'),
                    content: const Text('Bạn chắc chắn muốn xóa?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await cvConController.xoaCongViecCon(cvCon.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}