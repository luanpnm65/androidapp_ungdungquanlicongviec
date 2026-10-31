import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/cong_viec_controller.dart';
import '../../models/ai_chat.dart';  // ← IMPORT ĐÚNG MODEL
import '../../services/ai_service.dart';

class AIChiaViecScreen extends StatefulWidget {
  final String duAnId;

  const AIChiaViecScreen({
    Key? key,
    required this.duAnId,
  }) : super(key: key);

  @override
  State<AIChiaViecScreen> createState() => _AIChiaViecScreenState();
}

class _AIChiaViecScreenState extends State<AIChiaViecScreen> {
  final congViecController = Get.find<CongViecController>();
  bool _dangPhanTich = false;
  List<CongViecTuAI>? _danhSachCongViecAI;
  String? _tenFileChon;
  Set<int> _congViecDuocChon = {};

  Future<void> _chonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        _tenFileChon = file.name;
        await _phanTichTaiLieu(file.path!, file.name);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn file: ${e.toString()}');
    }
  }

  Future<void> _phanTichTaiLieu(String duongDan, String tenFile) async {
    try {
      setState(() => _dangPhanTich = true);

      // ← SỬA: Dùng chatVoiAI thay vì phanTichTaiLieu
      final response = await AIService.chatVoiAI(
        yeuCau: 'Phân tích file này và chia thành các công việc chi tiết. Trả về danh sách JSON với các trường: tieu_de, mo_ta, uu_tien (cao/trung_binh/thap), ngay_het_han_tu_ngay, ghi_chu',
        duongDanFile: [duongDan],
        tenFile: [tenFile],
      );

      // Parse kết quả
      final ketQua = AIService.parseCongViecTuResponse(response);

      setState(() {
        _danhSachCongViecAI = ketQua;
        _congViecDuocChon.clear();
      });

      Get.snackbar('Thành công', 'AI đã phân tích tài liệu');
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi phân tích: ${e.toString()}');
    } finally {
      setState(() => _dangPhanTich = false);
    }
  }

  Future<void> _taoToanBoCongViec() async {
    if (_danhSachCongViecAI == null || _congViecDuocChon.isEmpty) {
      Get.snackbar('Thông báo', 'Vui lòng chọn ít nhất một công việc');
      return;
    }

    try {
      setState(() => _dangPhanTich = true);

      int thanhCong = 0;
      for (int index in _congViecDuocChon) {
        final cv = _danhSachCongViecAI![index];

        final result = await congViecController.taoCongViec(
          duAnId: widget.duAnId,
          tieuDe: cv.tieuDe,
          moTa: '${cv.moTa}\n\nGhi chú: ${cv.ghiChu}\nMức ưu tiên: ${cv.uu_tien}',
          ngayHetHan: cv.ngayHetHan,
        );

        if (result) thanhCong++;
      }

      Get.snackbar(
        'Thành công',
        'Đã tạo $thanhCong công việc',
      );

      setState(() {
        _danhSachCongViecAI = null;
        _congViecDuocChon.clear();
        _tenFileChon = null;
      });
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi tạo công việc: ${e.toString()}');
    } finally {
      setState(() => _dangPhanTich = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Trợ lý chia việc'),
      ),
      body: _danhSachCongViecAI == null
          ? _xayDungManhinhUploadFile()
          : _xayDungManhinhChonCongViec(),
    );
  }

  Widget _xayDungManhinhUploadFile() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 80,
              color: Colors.blue[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Trợ lý chia việc',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tải lên file Word, AI sẽ phân tích và tạo danh sách công việc tự động',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            if (_tenFileChon != null)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'File: $_tenFileChon',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_dangPhanTich)
                          const Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Đang phân tích...'),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ElevatedButton.icon(
              onPressed: _dangPhanTich ? null : _chonFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Chọn file'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungManhinhChonCongViec() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insert_drive_file, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tenFileChon!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI đã tìm thấy ${_danhSachCongViecAI!.length} công việc',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _danhSachCongViecAI = null;
                        _congViecDuocChon.clear();
                        _tenFileChon = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Chọn file khác'),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _danhSachCongViecAI!.length,
            itemBuilder: (context, index) {
              final cv = _danhSachCongViecAI![index];
              final duocChon = _congViecDuocChon.contains(index);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: CheckboxListTile(
                  value: duocChon,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _congViecDuocChon.add(index);
                      } else {
                        _congViecDuocChon.remove(index);
                      }
                    });
                  },
                  title: Text(
                    cv.tieuDe,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(cv.moTa),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(_layTenUuTien(cv.uu_tien)),
                            backgroundColor: _layMauUuTien(cv.uu_tien),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              'Hết hạn: ${cv.ngayHetHan.toString().split(' ')[0]}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Đã chọn ${_congViecDuocChon.length}/${_danhSachCongViecAI!.length} công việc',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _dangPhanTich ? null : _taoToanBoCongViec,
                icon: const Icon(Icons.check_circle),
                label: const Text('Tạo các công việc được chọn'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _layTenUuTien(String uu_tien) {
    switch (uu_tien) {
      case 'cao':
        return '🔴 Cao';
      case 'trung_binh':
        return '🟡 Trung bình';
      case 'thap':
        return '🟢 Thấp';
      default:
        return uu_tien;
    }
  }

  Color _layMauUuTien(String uu_tien) {
    switch (uu_tien) {
      case 'cao':
        return Colors.red[100]!;
      case 'trung_binh':
        return Colors.orange[100]!;
      case 'thap':
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}