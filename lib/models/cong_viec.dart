enum TrangThaiCongViec {
  chuaNhan,
  daNhan,
  dangThucHien,
  hoanThanh,
  quaHan,
}

class CongViec {
  final String id;
  final String duAnId;
  final String tieuDe;
  final String? moTa;
  final DateTime ngayTao;
  final DateTime? ngayHetHan;
  final String? nguoiNhanId;
  final String? tenNguoiNhan;
  final TrangThaiCongViec trangThai;
  final List<String>? danhSachFile;

  CongViec({
    required this.id,
    required this.duAnId,
    required this.tieuDe,
    this.moTa,
    required this.ngayTao,
    this.ngayHetHan,
    this.nguoiNhanId,
    this.tenNguoiNhan,
    this.trangThai = TrangThaiCongViec.chuaNhan,
    this.danhSachFile,
  });

  factory CongViec.tuJson(Map<String, dynamic> json) {
    return CongViec(
      id: json['id'] as String,
      duAnId: json['du_an_id'] as String,
      tieuDe: json['tieu_de'] as String,
      moTa: json['mo_ta'] as String?,
      ngayTao: DateTime.parse(json['ngay_tao'] as String),
      ngayHetHan: json['ngay_het_han'] != null
          ? DateTime.parse(json['ngay_het_han'] as String)
          : null,
      nguoiNhanId: json['nguoi_nhan_id'] as String?,
      tenNguoiNhan: json['ten_nguoi_nhan'] as String?,
      trangThai: TrangThaiCongViec.values.firstWhere(
            (e) => e.name == json['trang_thai'],
        orElse: () => TrangThaiCongViec.chuaNhan,
      ),
      danhSachFile: json['danh_sach_file'] != null
          ? List<String>.from(json['danh_sach_file'] as List)
          : null,
    );
  }

  Map<String, dynamic> denJson() {
    return {
      'id': id,
      'du_an_id': duAnId,
      'tieu_de': tieuDe,
      'mo_ta': moTa,
      'ngay_tao': ngayTao.toIso8601String(),
      'ngay_het_han': ngayHetHan?.toIso8601String(),
      'nguoi_nhan_id': nguoiNhanId,
      'ten_nguoi_nhan': tenNguoiNhan,
      'trang_thai': trangThai.name,
      'danh_sach_file': danhSachFile,
    };
  }

  bool get daQuaHan {
    if (ngayHetHan == null) return false;
    return DateTime.now().isAfter(ngayHetHan!) &&
        trangThai != TrangThaiCongViec.hoanThanh;
  }
}