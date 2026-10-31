import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/ai_chat_controller.dart';
import '../../controllers/cong_viec_controller.dart';
import '../../models/ai_chat.dart';

class AIChatScreen extends StatefulWidget {
  final String duAnId;

  const AIChatScreen({
    Key? key,
    required this.duAnId,
  }) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final aiChatController = Get.put(AIChatController());
  final congViecController = Get.find<CongViecController>();
  final TextEditingController _yeuCauController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> _duongDanFileChon = [];
  List<String> _tenFileChon = [];

  @override
  void dispose() {
    _yeuCauController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _chonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          // ← SỬA: Lọc bỏ null values
          _duongDanFileChon = result.paths
              .whereType<String>()
              .toList();
          _tenFileChon = result.names
              .whereType<String>()
              .toList();
        });
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn file');
    }
  }

  Future<void> _guiYeuCau() async {
    final yeuCau = _yeuCauController.text.trim();

    if (yeuCau.isEmpty) {
      Get.snackbar('Thông báo', 'Vui lòng nhập yêu cầu');
      return;
    }

    _yeuCauController.clear();

    await aiChatController.guiYeuCau(
      yeuCau: yeuCau,
      duongDanFile: _duongDanFileChon,
      tenFile: _tenFileChon,
    );

    setState(() {
      _duongDanFileChon.clear();
      _tenFileChon.clear();
    });

    _cuonDenCuoi();
  }

  void _cuonDenCuoi() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Trợ lý chia việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Làm sạch chat'),
                  content: const Text('Bạn chắc chắn muốn xóa toàn bộ chat?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        aiChatController.lamSach();
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
      body: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child: Obx(() {
              if (aiChatController.danhSachTinNhan.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 80,
                        color: Colors.blue[200],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chào mừng bạn!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tôi sẽ giúp bạn chia việc từ tài liệu.\nVui lòng tải lên file và nêu yêu cầu của bạn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: aiChatController.danhSachTinNhan.length,
                itemBuilder: (context, index) {
                  final tinNhan = aiChatController.danhSachTinNhan[index];
                  return _xayDungTinNhan(tinNhan);
                },
              );
            }),
          ),

          if (aiChatController.coKetQuaCongViec.value)
            _xayDungKetQuaCongViec(),

          // Input area
          _xayDungKhuVaoDuLieu(),
        ],
      ),
    );
  }

  Widget _xayDungTinNhan(AIChatMessage tinNhan) {
    return Align(
      alignment: tinNhan.laUserGui ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: tinNhan.laUserGui ? Colors.blue[500] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File đính kèm nếu có
            if (tinNhan.danhSachFile != null && tinNhan.danhSachFile!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...tinNhan.danhSachFile!.map((file) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_file, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            file,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: tinNhan.laUserGui ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                ],
              ),
            // Nội dung tin nhắn
            Text(
              tinNhan.noidung,
              style: TextStyle(
                color: tinNhan.laUserGui ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
            // Thời gian
            const SizedBox(height: 6),
            Text(
              '${tinNhan.thoiGian.hour}:${tinNhan.thoiGian.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: tinNhan.laUserGui ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungKetQuaCongViec() {
    return Obx(() => Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI đã tìm thấy ${aiChatController.danhSachCongViecTuAI.length} công việc',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _hienThiKetQua(),
                icon: const Icon(Icons.preview, size: 16),
                label: const Text('Xem'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void _hienThiKetQua() {
    Get.dialog(
      AlertDialog(
        title: const Text('Công việc được AI đề xuất'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            final danhSach = aiChatController.danhSachCongViecTuAI;
            return ListView.builder(
              itemCount: danhSach.length,
              itemBuilder: (context, index) {
                final cv = danhSach[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cv.tieuDe,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(cv.moTa, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(_layTenUuTien(cv.uu_tien)),
                              backgroundColor: _layMauUuTien(cv.uu_tien),
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Chip(
                              label: Text(
                                cv.ngayHetHan.toString().split(' ')[0],
                              ),
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _taoToanBoCongViec();
            },
            icon: const Icon(Icons.add_circle),
            label: const Text('Tạo tất cả'),
          ),
        ],
      ),
    );
  }

  Future<void> _taoToanBoCongViec() async {
    try {
      int thanhCong = 0;
      for (var cv in aiChatController.danhSachCongViecTuAI) {
        final result = await congViecController.taoCongViec(
          duAnId: widget.duAnId,
          tieuDe: cv.tieuDe,
          moTa: '${cv.moTa}\n\nGhi chú: ${cv.ghiChu}\nMức ưu tiên: ${cv.uu_tien}',
          ngayHetHan: cv.ngayHetHan,
        );
        if (result) thanhCong++;
      }

      Get.snackbar('Thành công', 'Đã tạo $thanhCong công việc');
      aiChatController.lamSach();
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi tạo công việc');
    }
  }

  Widget _xayDungKhuVaoDuLieu() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File đã chọn
          if (_tenFileChon.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 8,
                children: _tenFileChon.asMap().entries.map((e) {
                  return Chip(
                    label: Text(e.value),
                    onDeleted: () {
                      setState(() {
                        _tenFileChon.removeAt(e.key);
                        _duongDanFileChon.removeAt(e.key);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

          // Input
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _chonFile,
              ),
              Expanded(
                child: TextField(
                  controller: _yeuCauController,
                  decoration: InputDecoration(
                    hintText: 'Yêu cầu của bạn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => FloatingActionButton(
                mini: true,
                onPressed: aiChatController.dangGui.value
                    ? null
                    : _guiYeuCau,
                child: aiChatController.dangGui.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send),
              )),
            ],
          ),
        ],
      ),
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