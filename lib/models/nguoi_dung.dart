class NguoiDung {
  final String id;
  final String email;
  final String? ten;
  final String? anhDaiDien;
  final String? sdt;
  final String? viTri;
  final String? moTa;
  final DateTime ngayTao;

  NguoiDung({
    required this.id,
    required this.email,
    this.ten,
    this.anhDaiDien,
    this.sdt,
    this.viTri,
    this.moTa,
    required this.ngayTao,
  });

  factory NguoiDung.tuJson(Map<String, dynamic> json) {
    return NguoiDung(
      id: json['id'] as String,
      email: json['email'] as String,
      ten: json['ten'] as String?,
      anhDaiDien: json['anh_dai_dien'] as String?,
      sdt: json['sdt'] as String?,
      viTri: json['vi_tri'] as String?,
      moTa: json['mo_ta'] as String?,
      ngayTao: DateTime.parse(json['ngay_tao'] as String),
    );
  }

  Map<String, dynamic> denJson() {
    return {
      'id': id,
      'email': email,
      'ten': ten,
      'anh_dai_dien': anhDaiDien,
      'sdt': sdt,
      'vi_tri': viTri,
      'mo_ta': moTa,
      'ngay_tao': ngayTao.toIso8601String(),
    };
  }
}