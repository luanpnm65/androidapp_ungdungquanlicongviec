import 'package:get/get.dart';
import '../models/nguoi_dung.dart';
import '../services/supabase_service.dart';

class ThanhVienController extends GetxController {
  final RxList<NguoiDung> danhSachThanhVien = <NguoiDung>[].obs;
  final RxBool dangTaiDuLieu = false.obs;

  Future<void> taiDanhSachThanhVien(String duAnId) async {
    try {
      dangTaiDuLieu.value = true;

      final responseTV = await SupabaseService.thanhVienDuAnTable
          .select('nguoi_dung_id')
          .eq('du_an_id', duAnId);

      List<NguoiDung> thanhVien = [];
      if (responseTV != null && (responseTV as List).isNotEmpty) {
        for (var item in responseTV) {
          final nguoiDungId = item['nguoi_dung_id'];
          try {
            final responseUser = await SupabaseService.client
                .from('ho_so_nguoi_dung')
                .select()
                .eq('id', nguoiDungId)
                .single();

            thanhVien.add(NguoiDung.tuJson(responseUser));
          } catch (e) {
            // Nếu chưa có hồ sơ (hiếm), thêm một bản ghi với email rỗng
            thanhVien.add(NguoiDung(
              id: nguoiDungId,
              email: 'Chưa có hồ sơ',
              ngayTao: DateTime.now(),
            ));
          }
        }
      }
      danhSachThanhVien.value = thanhVien;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách thành viên: ${e.toString()}');
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  // Hàm xóa thành viên (chỉ dành cho chủ dự án)
  Future<bool> xoaThanhVien(String duAnId, String nguoiDungId) async {
    try {
      await SupabaseService.thanhVienDuAnTable
          .delete()
          .eq('du_an_id', duAnId)
          .eq('nguoi_dung_id', nguoiDungId);

      await taiDanhSachThanhVien(duAnId);
      Get.snackbar('Thành công', 'Đã xóa thành viên');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa thành viên: ${e.toString()}');
      return false;
    }
  }
}