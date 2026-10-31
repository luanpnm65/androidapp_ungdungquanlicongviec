class AIChatMessage {
  final String id;
  final String noidung;
  final bool laUserGui; // true = người dùng, false = AI
  final DateTime thoiGian;
  final List<String>? danhSachFile; // Danh sách file đính kèm

  AIChatMessage({
    required this.id,
    required this.noidung,
    required this.laUserGui,
    required this.thoiGian,
    this.danhSachFile,
  });
}

class CongViecTuAI {
  final String tieuDe;
  final String moTa;
  final String uu_tien; // cao, trung_binh, thap
  final int ngayHetHanTuNgay;
  final String ghiChu;

  CongViecTuAI({
    required this.tieuDe,
    required this.moTa,
    required this.uu_tien,
    required this.ngayHetHanTuNgay,
    required this.ghiChu,
  });

  factory CongViecTuAI.fromJson(Map<String, dynamic> json) {
    int ngayHetHan = json['ngay_het_han_tu_ngay'] ?? 7;

    if (ngayHetHan < 1) {
      ngayHetHan = 1;
    } else if (ngayHetHan > 365) {
      ngayHetHan = 365;
    }

    return CongViecTuAI(
      tieuDe: json['tieu_de'] ?? 'Không có tiêu đề',
      moTa: json['mo_ta'] ?? '',
      uu_tien: _validateUuTien(json['uu_tien'] ?? 'trung_binh'),
      ngayHetHanTuNgay: ngayHetHan,
      ghiChu: json['ghi_chu'] ?? '',
    );
  }

  static String _validateUuTien(String uu_tien) {
    const validValues = ['cao', 'trung_binh', 'thap'];
    if (validValues.contains(uu_tien)) {
      return uu_tien;
    }
    return 'trung_binh';
  }

  DateTime get ngayHetHan => DateTime.now().add(Duration(days: ngayHetHanTuNgay));
}