class DuAn {
  final String id;
  final String ten;
  final String? moTa;
  final String chuDuAnId;
  final String maMoi;
  final DateTime ngayTao;
  final DateTime? ngayHetHan;
  final bool daHoanThanh;
  final bool thatBai;
  final bool daLuuTru;

  DuAn({
    required this.id,
    required this.ten,
    this.moTa,
    required this.chuDuAnId,
    required this.maMoi,
    required this.ngayTao,
    this.ngayHetHan,
    this.daHoanThanh = false,
    this.thatBai = false,
    this.daLuuTru = false,
  });

  factory DuAn.tuJson(Map<String, dynamic> json) {
    return DuAn(
      id: json['id'] as String,
      ten: json['ten'] as String,
      moTa: json['mo_ta'] as String?,
      chuDuAnId: json['chu_du_an_id'] as String,
      maMoi: json['ma_moi'] as String,
      ngayTao: DateTime.parse(json['ngay_tao'] as String),
      ngayHetHan: json['ngay_het_han'] != null
          ? DateTime.parse(json['ngay_het_han'] as String)
          : null,
      daHoanThanh: json['da_hoan_thanh'] as bool? ?? false,
      thatBai: json['that_bai'] as bool? ?? false,
      daLuuTru: json['da_luu_tru'] as bool? ?? false,
    );
  }

  Map<String, dynamic> denJson() {
    return {
      'id': id,
      'ten': ten,
      'mo_ta': moTa,
      'chu_du_an_id': chuDuAnId,
      'ma_moi': maMoi,
      'ngay_tao': ngayTao.toIso8601String(),
      'ngay_het_han': ngayHetHan?.toIso8601String(),
      'da_hoan_thanh': daHoanThanh,
      'that_bai': thatBai,
      'da_luu_tru': daLuuTru,
    };
  }
}