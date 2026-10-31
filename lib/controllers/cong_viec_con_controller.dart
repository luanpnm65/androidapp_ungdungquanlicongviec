import 'package:get/get.dart';
import '../models/cong_viec_con.dart';
import '../services/supabase_service.dart';
import 'xac_thuc_controller.dart';

class CongViecConController extends GetxController {
  final RxList<CongViecCon> danhSachCongViecCon = <CongViecCon>[].obs;
  final RxBool dangTaiDuLieu = false.obs;
  final RxString congViecChaIdHienTai = ''.obs;

  final xacThucController = Get.find<XacThucController>();

  Future<void> taiDanhSachCongViecCon(String congViecChaId) async {
    try {
      dangTaiDuLieu.value = true;
      congViecChaIdHienTai.value = congViecChaId;

      final response = await SupabaseService.client
          .from('cong_viec_con')
          .select()
          .eq('cong_viec_cha_id', congViecChaId)
          .order('ngay_tao', ascending: false);

      List<CongViecCon> danhSach = [];

      for (var json in (response as List)) {
        var congViecCon = CongViecCon.tuJson(json as Map<String, dynamic>);

        // Nếu có người nhận, lấy tên họ
        if (congViecCon.nguoiNhanId != null) {
          try {
            final hoSo = await SupabaseService.client
                .from('ho_so_nguoi_dung')
                .select('ten')
                .eq('id', congViecCon.nguoiNhanId!)
                .single();

            congViecCon = CongViecCon(
              id: congViecCon.id,
              congViecChaId: congViecCon.congViecChaId,
              tieuDe: congViecCon.tieuDe,
              moTa: congViecCon.moTa,
              ngayTao: congViecCon.ngayTao,
              ngayHetHan: congViecCon.ngayHetHan,
              nguoiNhanId: congViecCon.nguoiNhanId,
              tenNguoiNhan: hoSo['ten'] ?? 'Chưa cập nhật tên',
              trangThai: congViecCon.trangThai,
            );
          } catch (e) {
            print('Lỗi lấy tên người nhận: $e');
          }
        }

        danhSach.add(congViecCon);
      }

      danhSachCongViecCon.value = danhSach;
    } catch (e) {
      print('Lỗi tải công việc con: $e');
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  Future<bool> nhanCongViecCon(String congViecConId) async {
    try {
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;
      if (nguoiDungId == null) return false;

      await SupabaseService.client
          .from('cong_viec_con')
          .update({
        'nguoi_nhan_id': nguoiDungId,
        'trang_thai': TrangThaiCongViecCon.daNhan.name,
      })
          .eq('id', congViecConId);

      await taiDanhSachCongViecCon(congViecChaIdHienTai.value);
      Get.snackbar('Thành công', 'Đã nhận công việc con');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể nhận công việc con: ${e.toString()}');
      return false;
    }
  }

  Future<bool> capNhatTrangThaiCongViecCon(
      String congViecConId, TrangThaiCongViecCon trangThai) async {
    try {
      await SupabaseService.client
          .from('cong_viec_con')
          .update({'trang_thai': trangThai.name})
          .eq('id', congViecConId);

      await taiDanhSachCongViecCon(congViecChaIdHienTai.value);
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái: ${e.toString()}');
      return false;
    }
  }

  Future<bool> xoaCongViecCon(String congViecConId) async {
    try {
      await SupabaseService.client
          .from('cong_viec_con')
          .delete()
          .eq('id', congViecConId);

      await taiDanhSachCongViecCon(congViecChaIdHienTai.value);
      Get.snackbar('Thành công', 'Đã xóa công việc con');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa: ${e.toString()}');
      return false;
    }
  }
}