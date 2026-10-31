import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/cong_viec_controller.dart';
import '../../models/cong_viec.dart';
import '../../services/supabase_service.dart';

class ChiTietCongViecScreen extends StatefulWidget {
  final CongViec congViec;
  final bool laChuDuAn;

  const ChiTietCongViecScreen({
    Key? key,
    required this.congViec,
    required this.laChuDuAn,
  }) : super(key: key);

  @override
  State<ChiTietCongViecScreen> createState() => _ChiTietCongViecScreenState();
}

class _ChiTietCongViecScreenState extends State<ChiTietCongViecScreen> {
  final congViecController = Get.find<CongViecController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              widget.congViec.tieuDe,
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
                    if (widget.congViec.tenNguoiNhan != null) ...[
                      _ItemThongTin(
                        icon: Icons.person,
                        label: 'Người nhận',
                        value: widget.congViec.tenNguoiNhan!,
                      ),
                      const Divider(),
                    ],
                    if (widget.congViec.ngayHetHan != null) ...[
                      _ItemThongTin(
                        icon: Icons.calendar_today,
                        label: 'Deadline',
                        value: widget.congViec.ngayHetHan.toString().split(' ')[0],
                      ),
                      const Divider(),
                    ],
                    _ItemThongTin(
                      icon: Icons.access_time,
                      label: 'Tạo lúc',
                      value: widget.congViec.ngayTao.toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mô tả
            if (widget.congViec.moTa != null) ...[
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
                  child: Text(widget.congViec.moTa!),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // File đính kèm
            const Text(
              'File đính kèm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _hienThiDialogUploadFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Tải lên file'),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _taiDanhSachFile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Chưa có file nào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final file = snapshot.data![index];
                    return _xayDungThueFile(file, context);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Chia nhỏ công việc
            if (widget.laChuDuAn) ...[
              const Text(
                'Chia nhỏ công việc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _hienThiDialogChiaNhoCV,
                icon: const Icon(Icons.splitscreen),
                label: const Text('Tạo công việc con'),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _taiDanhSachCVCon(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Chưa chia nhỏ công việc này',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final cvCon = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.subdirectory_arrow_right),
                          title: Text(cvCon['tieu_de'] ?? 'Chưa có tiêu đề'),
                          subtitle: Text(cvCon['trang_thai'] ?? ''),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
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

  Future<List<Map<String, dynamic>>> _taiDanhSachFile() async {
    try {
      final response = await SupabaseService.client
          .from('file_cong_viec')
          .select()
          .eq('cong_viec_id', widget.congViec.id)
          .order('ngay_tao', ascending: false);

      return (response as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      print('Lỗi tải file: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _taiDanhSachCVCon() async {
    try {
      final response = await SupabaseService.client
          .from('cong_viec_con')
          .select()
          .eq('cong_viec_cha_id', widget.congViec.id);

      return (response as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      print('Lỗi tải công việc con: $e');
      return [];
    }
  }

  Widget _xayDungThueFile(
      Map<String, dynamic> file,
      BuildContext context,
      ) {
    final tenFile = file['ten_file'] as String? ?? 'File';
    final loaiFile = file['loai_file'] as String? ?? 'khac';
    final kichThuoc = file['kich_thuoc'] as int? ?? 0;
    final fileId = file['id'] as String;
    final duongDan = file['duong_dan_file'] as String?;

    IconData _layIconFile() {
      switch (loaiFile) {
        case 'docx':
        case 'doc':
          return Icons.description;
        case 'xlsx':
        case 'xls':
          return Icons.table_chart;
        default:
          return Icons.file_present;
      }
    }

    void _xoaFile() async {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Xóa file'),
          content: Text('Bạn chắc chắn muốn xóa "$tenFile"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await congViecController.xoaFileCongViec(
                  fileId: fileId,
                  duongDanFile: duongDan ?? '',
                );
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: Icon(_layIconFile(), color: Colors.blue),
        title: Text(tenFile),
        subtitle: Text(
          '${(kichThuoc / 1024).toStringAsFixed(2)} KB',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.download, size: 18),
                  SizedBox(width: 8),
                  Text('Tải về'),
                ],
              ),
              onTap: () async {
                if (duongDan != null) {
                  Get.snackbar('','');
                }
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
              onTap: () {
                _xoaFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _hienThiDialogUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx', 'xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final duongDan = file.path!;
        final tenFile = file.name;

        print('Tệp được chọn: $tenFile ($duongDan)');

        Get.dialog(
          AlertDialog(
            title: const Text('Xác nhận upload'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tên file: $tenFile'),
                const SizedBox(height: 8),
                Text(
                  'Kích thước: ${(file.size / 1024).toStringAsFixed(2)} KB',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await congViecController.uploadFileCongViec(
                    congViecId: widget.congViec.id,
                    duongDanFile: duongDan,
                    tenFile: tenFile,
                  );
                  setState(() {});
                },
                child: const Text('Upload'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Lỗi chọn file: $e');
      Get.snackbar('Lỗi', 'Không thể chọn file: ${e.toString()}');
    }
  }

  void _hienThiDialogChiaNhoCV() {
    final tieuDeController = TextEditingController();
    final moTaController = TextEditingController();
    DateTime? ngayHetHan;

    Get.dialog(
      AlertDialog(
        title: const Text('Tạo công việc con'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tieuDeController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề công việc con',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: moTaController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
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
              ],
            ),
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
                final thanhCong = await congViecController.taoCongViecCon(
                  congViecChaId: widget.congViec.id,
                  tieuDe: tieuDeController.text.trim(),
                  moTa: moTaController.text.trim().isEmpty
                      ? null
                      : moTaController.text.trim(),
                  ngayHetHan: ngayHetHan,
                );

                if (thanhCong) {
                  Get.back();
                  setState(() {});
                }
              } else {
                Get.snackbar('Lỗi', 'Vui lòng nhập tiêu đề');
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
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