import 'package:get/get.dart';
import 'dart:convert';
import '../models/ai_chat.dart';
import '../services/ai_service.dart';

class AIChatController extends GetxController {
  final RxList<AIChatMessage> danhSachTinNhan = <AIChatMessage>[].obs;
  final RxBool dangGui = false.obs;
  final RxBool coKetQuaCongViec = false.obs;
  final RxList<CongViecTuAI> danhSachCongViecTuAI = <CongViecTuAI>[].obs;

  /// Gửi tin nhắn và file lên AI
  Future<void> guiYeuCau({
    required String yeuCau,
    List<String> duongDanFile = const [],
    List<String> tenFile = const [],
  }) async {
    try {
      dangGui.value = true;

      // Thêm tin nhắn của người dùng
      final idUser = DateTime.now().millisecondsSinceEpoch.toString();
      danhSachTinNhan.add(
        AIChatMessage(
          id: idUser,
          noidung: yeuCau,
          laUserGui: true,
          thoiGian: DateTime.now(),
          danhSachFile: tenFile,
        ),
      );

      // Gửi đến AI
      final response = await AIService.chatVoiAI(
        yeuCau: yeuCau,
        duongDanFile: duongDanFile,
        tenFile: tenFile,
      );

      // Thêm tin nhắn của AI
      final idAI = DateTime.now().millisecondsSinceEpoch.toString();
      danhSachTinNhan.add(
        AIChatMessage(
          id: idAI,
          noidung: response,
          laUserGui: false,
          thoiGian: DateTime.now(),
        ),
      );

      // Parse công việc từ response
      _parseCongViec(response);

    } catch (e) {
      print('Lỗi gửi yêu cầu: $e');
      Get.snackbar('Lỗi', 'Không thể gửi yêu cầu: ${e.toString()}');
    } finally {
      dangGui.value = false;
    }
  }

  /// Parse và hiển thị danh sách công việc
  void _parseCongViec(String response) {
    final congViec = AIService.parseCongViecTuResponse(response);
    if (congViec.isNotEmpty) {
      danhSachCongViecTuAI.value = congViec;
      coKetQuaCongViec.value = true;
    }
  }

  /// Làm sạch chat
  void lamSach() {
    danhSachTinNhan.clear();
    danhSachCongViecTuAI.clear();
    coKetQuaCongViec.value = false;
  }
}