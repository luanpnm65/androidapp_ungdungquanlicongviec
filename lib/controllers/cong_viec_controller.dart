import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cong_viec.dart';
import '../services/supabase_service.dart';
import 'du_an_controller.dart';
import 'xac_thuc_controller.dart';
import 'dart:io';

class CongViecController extends GetxController {
  final RxList<CongViec> danhSachCongViec = <CongViec>[].obs;
  final RxBool dangTaiDuLieu = false.obs;
  final RxString duAnIdHienTai = ''.obs;

  final xacThucController = Get.find<XacThucController>();
  SupabaseClient get client => SupabaseService.client;

  Future<void> taiDanhSachCongViec(String duAnId) async {
    try {
      dangTaiDuLieu.value = true;
      duAnIdHienTai.value = duAnId;

      final response = await SupabaseService.congViecTable
          .select()
          .eq('du_an_id', duAnId)
          .order('ngay_tao', ascending: false);

      List<CongViec> danhSach = [];

      for (var json in (response as List)) {
        var congViec = CongViec.tuJson(json as Map<String, dynamic>);

        // Nếu có người nhận, lấy tên họ
        if (congViec.nguoiNhanId != null) {
          try {
            final hoSo = await SupabaseService.client
                .from('ho_so_nguoi_dung')
                .select('ten')
                .eq('id', congViec.nguoiNhanId!)
                .single();

            congViec = CongViec(
              id: congViec.id,
              duAnId: congViec.duAnId,
              tieuDe: congViec.tieuDe,
              moTa: congViec.moTa,
              ngayTao: congViec.ngayTao,
              ngayHetHan: congViec.ngayHetHan,
              nguoiNhanId: congViec.nguoiNhanId,
              tenNguoiNhan: hoSo['ten'] ?? 'Chưa cập nhật tên',
              trangThai: congViec.trangThai,
              danhSachFile: congViec.danhSachFile,
            );
          } catch (e) {
            print('Lỗi lấy tên người nhận: $e');
          }
        }

        danhSach.add(congViec);
      }

      danhSachCongViec.value = danhSach;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách công việc: ${e.toString()}');
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  Future<bool> taoCongViec({
    required String duAnId,
    required String tieuDe,
    String? moTa,
    DateTime? ngayHetHan,
  }) async {
    try {
      dangTaiDuLieu.value = true;

      final congViecMoi = {
        'du_an_id': duAnId,
        'tieu_de': tieuDe,
        'mo_ta': moTa,
        'ngay_tao': DateTime.now().toIso8601String(),
        'ngay_het_han': ngayHetHan?.toIso8601String(),
        'trang_thai': TrangThaiCongViec.chuaNhan.name,
      };

      await SupabaseService.congViecTable.insert(congViecMoi);
      await taiDanhSachCongViec(duAnId);

      Get.snackbar('Thành công', 'Đã tạo công việc mới');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tạo công việc: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  Future<bool> nhanCongViec(String congViecId) async {
    try {
      final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;
      if (nguoiDungId == null) return false;

      await SupabaseService.congViecTable
          .update({
        'nguoi_nhan_id': nguoiDungId,
        'trang_thai': TrangThaiCongViec.daNhan.name,
      })
          .eq('id', congViecId);

      await taiDanhSachCongViec(duAnIdHienTai.value);
      Get.snackbar('Thành công', 'Đã nhận công việc');
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể nhận công việc: ${e.toString()}');
      return false;
    }
  }

  Future<bool> capNhatTrangThai(String congViecId, TrangThaiCongViec trangThai) async {
    try {
      await SupabaseService.congViecTable
          .update({'trang_thai': trangThai.name})
          .eq('id', congViecId);

      await taiDanhSachCongViec(duAnIdHienTai.value);

      final duAnController = Get.find<DuAnController>();
      await duAnController.capNhatTrangThaiDuAn(duAnIdHienTai.value);

      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái: ${e.toString()}');
      return false;
    }
  }

  List<CongViec> get congViecChuaNhan =>
      danhSachCongViec.where((cv) => cv.trangThai == TrangThaiCongViec.chuaNhan).toList();

  List<CongViec> get congViecCuaToi {
    final nguoiDungId = xacThucController.nguoiDungHienTai.value?.id;
    return danhSachCongViec.where((cv) => cv.nguoiNhanId == nguoiDungId).toList();
  }
  Future<bool> taoCongViecCon({
    required String congViecChaId,
    required String tieuDe,
    String? moTa,
    DateTime? ngayHetHan,
  }) async {
    try {
      dangTaiDuLieu.value = true;

      final congViecConMoi = {
        'cong_viec_cha_id': congViecChaId,
        'tieu_de': tieuDe,
        'mo_ta': moTa,
        'ngay_het_han': ngayHetHan?.toIso8601String(),
        'trang_thai': 'chuaNhan',
        'ngay_tao': DateTime.now().toIso8601String(),
      };

      print('Tạo công việc con: $congViecConMoi');

      await SupabaseService.client
          .from('cong_viec_con')
          .insert(congViecConMoi);

      print('Công việc con tạo thành công');
      Get.snackbar('Thành công', 'Đã tạo công việc con');
      return true;
    } catch (e) {
      print('Lỗi tạo công việc con: $e');
      Get.snackbar('Lỗi', 'Không thể tạo công việc con: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }
  Future<bool> uploadFileCongViec({
    required String congViecId,
    required String duongDanFile,
    required String tenFile,
  }) async {
    try {
      dangTaiDuLieu.value = true;

      // Lấy file từ đường dẫn
      final file = File(duongDanFile);
      final byte = await file.readAsBytes();

      // Tạo đường dẫn lưu trữ trong Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'cong_viec/$congViecId/${timestamp}_$tenFile';

      print('Đang upload file: $filePath');

      // Upload file lên Supabase Storage
      await SupabaseService.client.storage
          .from('tai_lieu_cong_viec')
          .uploadBinary(filePath, byte);

      // Lấy URL public của file
      final publicUrl = SupabaseService.client.storage
          .from('tai_lieu_cong_viec')
          .getPublicUrl(filePath);

      print('Upload thành công: $publicUrl');

      // Lưu thông tin file vào database
      await SupabaseService.client.from('file_cong_viec').insert({
        'cong_viec_id': congViecId,
        'ten_file': tenFile,
        'duong_dan_file': publicUrl,
        'loai_file': _layLoaiFile(tenFile),
        'kich_thuoc': byte.length,
        'ngay_tao': DateTime.now().toIso8601String(),
      });

      Get.snackbar('Thành công', 'Đã upload file: $tenFile');
      await taiDanhSachCongViec(duAnIdHienTai.value);
      return true;
    } catch (e) {
      print('Lỗi upload file: $e');
      Get.snackbar('Lỗi', 'Không thể upload file: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }

  String _layLoaiFile(String tenFile) {
    if (tenFile.toLowerCase().endsWith('.pdf')) return 'pdf';
    if (tenFile.toLowerCase().endsWith('.docx')) return 'docx';
    if (tenFile.toLowerCase().endsWith('.doc')) return 'doc';
    if (tenFile.toLowerCase().endsWith('.xlsx')) return 'xlsx';
    if (tenFile.toLowerCase().endsWith('.xls')) return 'xls';
    return 'khac';
  }

  Future<bool> xoaFileCongViec({
    required String fileId,
    required String duongDanFile,
  }) async {
    try {
      dangTaiDuLieu.value = true;

      // Xóa file từ Storage
      await SupabaseService.client.storage
          .from('tai_lieu_cong_viec')
          .remove([duongDanFile]);

      // Xóa bản ghi từ database
      await SupabaseService.client
          .from('file_cong_viec')
          .delete()
          .eq('id', fileId);

      Get.snackbar('Thành công', 'Đã xóa file');
      return true;
    } catch (e) {
      print('Lỗi xóa file: $e');
      Get.snackbar('Lỗi', 'Không thể xóa file: ${e.toString()}');
      return false;
    } finally {
      dangTaiDuLieu.value = false;
    }
  }
}