import 'package:get/get.dart';
import 'dart:math';
import '../models/du_an.dart';
import '../services/supabase_service.dart';
import 'xac_thuc_controller.dart';

class DuAnController extends GetxController {
  final RxList<DuAn> danhSachDuAnChuSoHuu = <DuAn>[].obs;
  final RxList<DuAn> danhSachDuAnThamGia = <DuAn>[].obs;
  final RxList<DuAn> danhSachDuAnLuuTru = <DuAn>[].obs; // ← THÊM
  final RxBool dangTaiDuLieu = false.obs;

  final xacThucController = Get.find<XacThucController>();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 500), () {
      taiDanhSachDuAn();
    });
  }

  String taoMaMoi() {
    const kyTu = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => kyTu[random.nextInt(kyTu.length)]).join();
  }

  Future<void> taiDanhSachDuAn() async {
    try {
      dangTaiDuLieu.value = true;
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;

      if (nguoiDungId == null) return;

      // === TẢI DỰ ÁN LÀM CHỦ (chưa lưu trữ) ===
      try {
        final responseChu = await SupabaseService.duAnTable
            .select()
            .eq('chu_du_an_id', nguoiDungId)
            .eq('da_luu_tru', false); // ← Chỉ lấy chưa lưu trữ

        danhSachDuAnChuSoHuu.value = (responseChu as List)
            .map((json) => DuAn.tuJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('❌ Lỗi tải dự án làm chủ: $e');
        danhSachDuAnChuSoHuu.value = [];
      }

      // === TẢI DỰ ÁN THAM GIA (chưa lưu trữ) ===
      try {
        final responseTV = await SupabaseService.thanhVienDuAnTable
            .select('du_an_id')
            .eq('nguoi_dung_id', nguoiDungId);

        danhSachDuAnThamGia.value = [];

        if (responseTV != null && (responseTV as List).isNotEmpty) {
          for (var item in responseTV) {
            try {
              final responseDuAn = await SupabaseService.duAnTable
                  .select()
                  .eq('id', item['du_an_id'])
                  .eq('da_luu_tru', false) // ← Chỉ lấy chưa lưu trữ
                  .single();

              danhSachDuAnThamGia.add(
                DuAn.tuJson(responseDuAn as Map<String, dynamic>),
              );
            } catch (e) {
              print('Lỗi tải dự án: $e');
            }
          }
        }
      } catch (e) {
        print('❌ Lỗi tải dự án tham gia: $e');
        danhSachDuAnThamGia.value = [];
      }

      // === TẢI DỰ ÁN ĐÃ LƯU TRỮ ===
      try {
        final responseLuuTru = await SupabaseService.duAnTable
            .select()
            .eq('chu_du_an_id', nguoiDungId)
            .eq('da_luu_tru', true); // ← Chỉ lấy đã lưu trữ

        danhSachDuAnLuuTru.value = (responseLuuTru as List)
            .map((json) => DuAn.tuJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('❌ Lỗi tải dự án lưu trữ: $e');
        danhSachDuAnLuuTru.value = [];
      }
    } catch (e) {
      print('❌ Lỗi chung: $e');
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  // === LƯU TRỮ DỰ ÁN ===
  Future<bool> luuTruDuAn(String duAnId) async {
    try {
      await SupabaseService.duAnTable
          .update({'da_luu_tru': true})
          .eq('id', duAnId);

      await taiDanhSachDuAn();
      Get.snackbar('Thành công', 'Đã lưu trữ dự án');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể lưu trữ: ${e.toString()}');
      return false;
    }
  }

  // === KHÔI PHỤC DỰ ÁN TỪ LƯU TRỮ ===
  Future<bool> khoiPhucDuAn(String duAnId) async {
    try {
      await SupabaseService.duAnTable
          .update({'da_luu_tru': false})
          .eq('id', duAnId);

      await taiDanhSachDuAn();
      Get.snackbar('Thành công', 'Đã khôi phục dự án');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể khôi phục: ${e.toString()}');
      return false;
    }
  }

  // === XÓA DỰ ÁN VĨNH VIỄN ===
  Future<bool> xoaDuAn(String duAnId) async {
    try {
      // Xóa cascade sẽ xóa luôn công việc và thành viên
      await SupabaseService.duAnTable
          .delete()
          .eq('id', duAnId);

      await taiDanhSachDuAn();
      Get.snackbar('Thành công', 'Đã xóa dự án');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa: ${e.toString()}');
      return false;
    }
  }

  // === RỜI KHỎI DỰ ÁN (với tư cách thành viên) ===
  Future<bool> roiKhoiDuAn(String duAnId) async {
    try {
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;
      if (nguoiDungId == null) return false;

      await SupabaseService.thanhVienDuAnTable
          .delete()
          .eq('du_an_id', duAnId)
          .eq('nguoi_dung_id', nguoiDungId);

      await taiDanhSachDuAn();
      Get.snackbar('Thành công', 'Đã rời khỏi dự án');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể rời dự án: ${e.toString()}');
      return false;
    }
  }

  // === CÁC GETTER THỐNG KÊ ===
  int get tongDuAn => danhSachDuAnChuSoHuu.length + danhSachDuAnThamGia.length;

  int get duAnHoanThanh =>
      danhSachDuAnChuSoHuu.where((da) => da.daHoanThanh).length +
          danhSachDuAnThamGia.where((da) => da.daHoanThanh).length;

  int get duAnChuaHoanThanh => tongDuAn - duAnHoanThanh;

  // Các method cũ giữ nguyên...
  Future<bool> taoDuAn(String ten, String? moTa, DateTime? ngayHetHan) async {
    try {
      dangTaiDuLieu.value = true;
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;
      if (nguoiDungId == null) return false;

      final maMoi = taoMaMoi();
      await SupabaseService.duAnTable.insert({
        'ten': ten,
        'mo_ta': moTa,
        'chu_du_an_id': nguoiDungId,
        'ma_moi': maMoi,
        'ngay_tao': DateTime.now().toIso8601String(),
        'ngay_het_han': ngayHetHan?.toIso8601String(),
        'da_hoan_thanh': false,
        'that_bai': false,
        'da_luu_tru': false,
      });

      await Future.delayed(const Duration(seconds: 1));
      await taiDanhSachDuAn();
      Get.snackbar('Thành công', 'Đã tạo dự án: $ten\nMã mời: $maMoi');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tạo dự án: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  Future<bool> thamGiaDuAnBangMa(String maMoi) async {
    try {
      dangTaiDuLieu.value = true;
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;
      if (nguoiDungId == null) return false;

      final response = await SupabaseService.duAnTable
          .select()
          .eq('ma_moi', maMoi.toUpperCase())
          .maybeSingle();

      if (response == null) {
        Get.snackbar('Lỗi', 'Mã mời không tồn tại hoặc sai');
        return false;
      }

      final duAnId = response['id'];
      final daCoMat = await SupabaseService.thanhVienDuAnTable
          .select()
          .eq('du_an_id', duAnId)
          .eq('nguoi_dung_id', nguoiDungId)
          .maybeSingle();

      if (daCoMat != null) {
        Get.snackbar('Thông báo', 'Bạn đã tham gia dự án này rồi');
        return false;
      }

      if (response['chu_du_an_id'] == nguoiDungId) {
        Get.snackbar('Thông báo', 'Bạn là chủ dự án này rồi');
        return false;
      }

      await SupabaseService.thanhVienDuAnTable.insert({
        'du_an_id': duAnId,
        'nguoi_dung_id': nguoiDungId,
        'ngay_tham_gia': DateTime.now().toIso8601String(),
      });

      await Future.delayed(const Duration(seconds: 1));
      await taiDanhSachDuAn();
      Get.snackbar('Thành công', 'Đã tham gia dự án: ${response['ten']}');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', '${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  Future<void> capNhatTrangThaiDuAn(String duAnId) async {
    try {
      final response = await SupabaseService.congViecTable
          .select()
          .eq('du_an_id', duAnId);

      if ((response as List).isEmpty) return;

      final tongCongViec = response.length;
      final congViecHoanThanh =
          response.where((cv) => cv['trang_thai'] == 'hoanThanh').length;

      await SupabaseService.duAnTable
          .update({'da_hoan_thanh': congViecHoanThanh == tongCongViec})
          .eq('id', duAnId);

      await taiDanhSachDuAn();
    } catch (e) {
      print('Lỗi cập nhật trạng thái dự án: $e');
    }
  }
}