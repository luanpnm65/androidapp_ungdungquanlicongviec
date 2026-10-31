import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/cong_viec_controller.dart';
import '../../models/du_an.dart';
import '../../services/supabase_service.dart';
import 'ai_chat_screen.dart';
import 'ai_chia_viec_screen.dart';
import 'danh_sach_cong_viec_screen.dart';
import 'danh_sach_thanh_vien_screen.dart';

class ChiTietDuAnScreen extends StatefulWidget {
  final DuAn duAn;
  final bool laChuDuAn;

  const ChiTietDuAnScreen({
    Key? key,
    required this.duAn,
    required this.laChuDuAn,
  }) : super(key: key);

  @override
  State<ChiTietDuAnScreen> createState() => _ChiTietDuAnScreenState();
}

class _ChiTietDuAnScreenState extends State<ChiTietDuAnScreen> {
  final congViecController = Get.put(CongViecController());

  @override
  void initState() {
    super.initState();
    congViecController.taiDanhSachCongViec(widget.duAn.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.duAn.ten),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _xayDungThongTinDuAn(),
            const Divider(),
            _xayDungNutHanhDong(),
            const Divider(),
            if (widget.laChuDuAn) _xayDungThongKeChoDuAn(),
          ],
        ),
      ),
    );
  }

  Widget _xayDungThongTinDuAn() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Thông tin dự án',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (widget.duAn.moTa != null) ...[
              const Text(
                'Mô tả:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(widget.duAn.moTa!),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                const Text(
                  'Vai trò: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(widget.laChuDuAn ? 'Chủ dự án' : 'Thành viên'),
                  backgroundColor: widget.laChuDuAn ? Colors.purple[100] : Colors.blue[100],
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (widget.laChuDuAn) ...[
              const Text(
                'Mã mời:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SelectableText(
                    widget.duAn.maMoi,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.duAn.maMoi));
                      Get.snackbar('Thành công', 'Đã sao chép mã mời');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (widget.duAn.ngayHetHan != null) ...[
              const Text(
                'Hạn chót:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.duAn.ngayHetHan.toString().split(' ')[0],
                style: TextStyle(
                  color: DateTime.now().isAfter(widget.duAn.ngayHetHan!)
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _xayDungNutHanhDong() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => DanhSachCongViecScreen(
                duAn: widget.duAn,
                laChuDuAn: widget.laChuDuAn,
              ));
            },
            icon: const Icon(Icons.list),
            label: const Text('Xem danh sách công việc'),
          ),

          if (widget.laChuDuAn) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => AIChatScreen(duAnId: widget.duAn.id));
              },
              icon: const Icon(Icons.smart_toy),
              label: const Text('AI Trợ lý chia việc'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Get.to(() => DanhSachThanhVienScreen(
                  duAn: widget.duAn,
                  laChuDuAn: widget.laChuDuAn,
                ));
              },
              icon: const Icon(Icons.people),
              label: const Text('Xem thành viên'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ],
      ),
    );
  }
  void _hienThiDialogCapNhatTrangThaiDuAn() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cập nhật trạng thái dự án'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Hoàn thành'),
              onTap: () async {
                Get.back();
                await SupabaseService.duAnTable
                    .update({'da_hoan_thanh': true})
                    .eq('id', widget.duAn.id);
                Get.snackbar('Thành công', 'Đã đánh dấu dự án hoàn thành');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Thất bại'),
              onTap: () async {
                Get.back();
                await SupabaseService.duAnTable
                    .update({'that_bai': true})
                    .eq('id', widget.duAn.id);
                Get.snackbar('Thành công', 'Đã đánh dấu dự án thất bại');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Đang làm'),
              onTap: () async {
                Get.back();
                await SupabaseService.duAnTable
                    .update({
                  'da_hoan_thanh': false,
                  'that_bai': false,
                })
                    .eq('id', widget.duAn.id);
                Get.snackbar('Thành công', 'Đã cập nhật trạng thái');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _xayDungThongKeChoDuAn() {
    return Obx(() {
      final tongCongViec = congViecController.danhSachCongViec.length;
      final congViecHoanThanh = congViecController.danhSachCongViec
          .where((cv) => cv.trangThai.name == 'hoanThanh')
          .length;

      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Thống kê công việc',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _xayDungMucThongKe('Tổng', tongCongViec, Colors.blue),
                  _xayDungMucThongKe('Hoàn thành', congViecHoanThanh, Colors.green),
                  _xayDungMucThongKe(
                    'Còn lại',
                    tongCongViec - congViecHoanThanh,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _xayDungMucThongKe(String tieuDe, int giaTri, Color mau) {
    return Column(
      children: [
        Text(
          giaTri.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: mau,
          ),
        ),
        Text(
          tieuDe,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _hienThiDialogTaoCongViec() {
    final tieuDeController = TextEditingController();
    final moTaController = TextEditingController();
    DateTime? ngayHetHan;

    Get.dialog(
      AlertDialog(
        title: const Text('Tạo công việc mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tieuDeController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: moTaController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => ListTile(
                  title: Text(
                    ngayHetHan == null
                        ? 'Chọn deadline (tùy chọn)'
                        : 'Deadline: ${ngayHetHan.toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final ngay = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (ngay != null) {
                      setState(() {
                        ngayHetHan = ngay;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tieuDeController.text.trim().isNotEmpty) {
                Get.back();
                await congViecController.taoCongViec(
                  duAnId: widget.duAn.id,
                  tieuDe: tieuDeController.text.trim(),
                  moTa: moTaController.text.trim().isEmpty
                      ? null
                      : moTaController.text.trim(),
                  ngayHetHan: ngayHetHan,
                );
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}