enum TrangThaiCongViecCon {
  chuaNhan,
  daNhan,
  dangThucHien,
  hoanThanh,
  quaHan,
}

class CongViecCon {
  final String id;
  final String congViecChaId;
  final String tieuDe;
  final String? moTa;
  final DateTime ngayTao;
  final DateTime? ngayHetHan;
  final String? nguoiNhanId;
  final String? tenNguoiNhan;
  final TrangThaiCongViecCon trangThai;

  CongViecCon({
    required this.id,
    required this.congViecChaId,
    required this.tieuDe,
    this.moTa,
    required this.ngayTao,
    this.ngayHetHan,
    this.nguoiNhanId,
    this.tenNguoiNhan,
    this.trangThai = TrangThaiCongViecCon.chuaNhan,
  });

  factory CongViecCon.tuJson(Map<String, dynamic> json) {
    return CongViecCon(
      id: json['id'] as String,
      congViecChaId: json['cong_viec_cha_id'] as String,
      tieuDe: json['tieu_de'] as String,
      moTa: json['mo_ta'] as String?,
      ngayTao: DateTime.parse(json['ngay_tao'] as String),
      ngayHetHan: json['ngay_het_han'] != null
          ? DateTime.parse(json['ngay_het_han'] as String)
          : null,
      nguoiNhanId: json['nguoi_nhan_id'] as String?,
      tenNguoiNhan: json['ten_nguoi_nhan'] as String?,
      trangThai: TrangThaiCongViecCon.values.firstWhere(
            (e) => e.name == json['trang_thai'],
        orElse: () => TrangThaiCongViecCon.chuaNhan,
      ),
    );
  }

  Map<String, dynamic> denJson() {
    return {
      'id': id,
      'cong_viec_cha_id': congViecChaId,
      'tieu_de': tieuDe,
      'mo_ta': moTa,
      'ngay_tao': ngayTao.toIso8601String(),
      'ngay_het_han': ngayHetHan?.toIso8601String(),
      'nguoi_nhan_id': nguoiNhanId,
      'ten_nguoi_nhan': tenNguoiNhan,
      'trang_thai': trangThai.name,
    };
  }

  bool get daQuaHan {
    if (ngayHetHan == null) return false;
    return DateTime.now().isAfter(ngayHetHan!) &&
        trangThai != TrangThaiCongViecCon.hoanThanh;
  }
}