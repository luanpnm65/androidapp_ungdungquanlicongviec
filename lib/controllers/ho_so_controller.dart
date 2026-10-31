import 'package:get/get.dart';
import '../models/nguoi_dung.dart';
import '../services/supabase_service.dart';
import 'xac_thuc_controller.dart';

class HoSoController extends GetxController {
  final xacThucController = Get.find<XacThucController>();
  final RxBool dangTaiDuLieu = false.obs;
  final Rx<NguoiDung?> hoSoNguoiDung = Rx<NguoiDung?>(null);

  @override
  void onInit() {
    super.onInit();
    taiHoSo();
  }

  Future<void> taiHoSo() async {
    try {
      dangTaiDuLieu.value = true;
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;

      if (nguoiDungId == null) return;

      final response = await SupabaseService.client
          .from('ho_so_nguoi_dung')
          .select()
          .eq('id', nguoiDungId)
          .maybeSingle();

      if (response != null) {
        hoSoNguoiDung.value = NguoiDung.tuJson(response as Map<String, dynamic>);
      } else {
        // Tạo hồ sơ mới nếu chưa có
        final hoSoMoi = {
          'id': nguoiDungId,
          'email': xacThucController.nguoiDungHienTai.value!.email,
          'ngay_tao': DateTime.now().toIso8601String(),
        };
        await SupabaseService.client
            .from('ho_so_nguoi_dung')
            .insert(hoSoMoi);

        hoSoNguoiDung.value = NguoiDung.tuJson(hoSoMoi);
      }
    } catch (e) {
      print('Lỗi tải hồ sơ: $e');
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  Future<bool> capNhatHoSo({
    required String ten,
    String? sdt,
    String? viTri,
    String? moTa,
    String? anhDaiDien,
  }) async {
    try {
      dangTaiDuLieu.value = true;
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;

      if (nguoiDungId == null) return false;

      final duLieuCapNhat = {
        'ten': ten,
        'sdt': sdt,
        'vi_tri': viTri,
        'mo_ta': moTa,
        if (anhDaiDien != null) 'anh_dai_dien': anhDaiDien,
      };

      await SupabaseService.client
          .from('ho_so_nguoi_dung')
          .update(duLieuCapNhat)
          .eq('id', nguoiDungId);

      await taiHoSo();
      Get.snackbar('Thành công', 'Đã cập nhật hồ sơ');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật hồ sơ: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  // Thêm phương thức cập nhật avatar
  Future<bool> capNhatAvatar(String linkAvatar) async {
    try {
      dangTaiDuLieu.value = true;
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;

      if (nguoiDungId == null) return false;

      await SupabaseService.client
          .from('ho_so_nguoi_dung')
          .update({'anh_dai_dien': linkAvatar})
          .eq('id', nguoiDungId);

      await taiHoSo();
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật avatar: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }
}