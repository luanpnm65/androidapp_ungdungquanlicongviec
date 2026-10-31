import 'package:get/get.dart';
import '../models/nguoi_dung.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class XacThucController extends GetxController {
  final Rx<NguoiDung?> nguoiDungHienTai = Rx<NguoiDung?>(null);
  final RxBool dangTaiDuLieu = false.obs;

  @override
  void onInit() {
    super.onInit();
    kiemTraTrangThaiDangNhap();
  }

  void kiemTraTrangThaiDangNhap() {
    final user = SupabaseService.nguoiDungHienTai;
    if (user != null) {
      nguoiDungHienTai.value = NguoiDung(
        id: user.id,
        email: user.email!,
        ngayTao: DateTime.parse(user.createdAt),
      );
    }
  }

  Future<bool> dangNhap(String email, String matKhau) async {
    try {
      dangTaiDuLieu.value = true;

      final response = await SupabaseService.dangNhap(email, matKhau);

      if (response.user != null) {
        nguoiDungHienTai.value = NguoiDung(
          id: response.user!.id,
          email: response.user!.email!,
          ngayTao: DateTime.parse(response.user!.createdAt),
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Lỗi', 'Đăng nhập thất bại: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  Future<bool> dangKy(String email, String matKhau) async {
    try {
      dangTaiDuLieu.value = true;

      final response = await SupabaseService.dangKy(email, matKhau);

      if (response.user != null) {
        Get.snackbar('Thành công', 'Vui lòng kiểm tra email để xác thực tài khoản');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Lỗi', 'Đăng ký thất bại: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  Future<void> dangXuat() async {
    await SupabaseService.dangXuat();
    nguoiDungHienTai.value = null;
  }
  Future<bool> doiMatKhau(String matKhauCu, String matKhauMoi) async {
    try {
      dangTaiDuLieu.value = true;

      // Xác thực lại với mật khẩu cũ
      final email = nguoiDungHienTai.value?.email;
      if (email == null) {
        Get.snackbar('Lỗi', 'Không tìm thấy email người dùng');
        return false;
      }

      try {
        await SupabaseService.dangNhap(email, matKhauCu);
      } catch (e) {
        Get.snackbar('Lỗi', 'Mật khẩu cũ không chính xác');
        return false;
      }

      // Cập nhật mật khẩu mới
      final response = await SupabaseService.client.auth.updateUser(
        UserAttributes(password: matKhauMoi),
      );

      if (response.user != null) {
        Get.snackbar('Thành công', 'Đã đổi mật khẩu thành công');
        return true;
      } else {
        Get.snackbar('Lỗi', 'Không thể đổi mật khẩu');
        return false;
      }
    } catch (e) {
      print('Lỗi đổi mật khẩu: $e');
      Get.snackbar('Lỗi', 'Không thể đổi mật khẩu: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }
}