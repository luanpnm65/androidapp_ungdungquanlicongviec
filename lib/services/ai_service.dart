import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'dart:convert';
import '../models/ai_chat.dart';
import 'package:archive/archive.dart';
import 'dart:math' show min;

class AIService {
  static final String _apiKey = 'AQ.Ab8RN6JtI4g91Tz5CkK-fEtKeCdFXq_Pwsk1XzIE8zW4axytIQ';

  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-flash-latest',
    apiKey: _apiKey,
  );

  /// Chat với AI và nhận kết quả phân tích
  static Future<String> chatVoiAI({
    required String yeuCau,
    required List<String> duongDanFile,
    required List<String> tenFile,
  }) async {
    try {
      print('Đang chat với AI...');

      final content = <Part>[];

      final promptMoiRong = '''
$yeuCau

QUAN TRỌNG: Trả về kết quả CHÍNH XÁC theo định dạng JSON dưới đây:
[
  {
    "tieu_de": "Tên công việc (bắt buộc)",
    "mo_ta": "Mô tả chi tiết công việc (bắt buộc)",
    "uu_tien": "cao hoặc trung_binh hoặc thap (bắt buộc)",
    "ngay_het_han_tu_ngay": số ngày từ hôm nay, từ 1 đến 365 (bắt buộc),
    "ghi_chu": "Ghi chú thêm"
  }
]

LƯU Ý:
- ngay_het_han_tu_ngay phải là số nguyên từ 1 đến 365
- uu_tien chỉ có 3 giá trị: cao, trung_binh, thap
- Không trả về text khác, chỉ trả về JSON thuần

Chỉ trả về JSON, KHÔNG có text bổ sung hay markdown.
''';

      content.add(TextPart(promptMoiRong));

      // Xử lý từng file
      for (int i = 0; i < duongDanFile.length; i++) {
        try {
          final file = File(duongDanFile[i]);
          final tenFileLocal = tenFile[i].toLowerCase();

          if (tenFileLocal.endsWith('.docx') || tenFileLocal.endsWith('.doc')) {
            // Chuyển đổi Word sang text
            final textContent = await _docxSangText(duongDanFile[i]);
            content.add(TextPart('Nội dung file Word: ${tenFile[i]}\n$textContent'));
            print('Đã chuyển đổi file Word: ${tenFile[i]}');
          }
          else if (tenFileLocal.endsWith('.txt')) {
            // Text file
            final textContent = await file.readAsString();
            content.add(TextPart('Nội dung file text: ${tenFile[i]}\n$textContent'));
            print('Đã thêm file text: ${tenFile[i]}');
          }
          else {
            try {
              final textContent = await file.readAsString();
              content.add(TextPart('Nội dung file: ${tenFile[i]}\n$textContent'));
              print('Đã thêm file: ${tenFile[i]}');
            } catch (e) {
              print('Không thể đọc file ${tenFile[i]}: $e');
            }
          }
        } catch (e) {
          print('Lỗi xử lý file ${tenFile[i]}: $e');
        }
      }

      // Gửi yêu cầu
      final response = await _model.generateContent([Content.multi(content)]);

      final responseText = response.text ?? '';
      print('AI đã trả lời');
      print('Response: ${responseText.substring(0, min(200, responseText.length))}...');

      return responseText;
    } catch (e) {
      print('Lỗi chat AI: $e');
      throw Exception('Lỗi giao tiếp với AI: ${e.toString()}');
    }
  }

  /// Chuyển đổi file Word (.docx) sang text
  static Future<String> _docxSangText(String duongDan) async {
    try {
      final file = File(duongDan);

      if (!await file.exists()) {
        throw Exception('File không tồn tại');
      }

      final bytes = await file.readAsBytes();

      // DOCX là file ZIP, extract và đọc document.xml
      final archive = ZipDecoder().decodeBytes(bytes);

      String textContent = '';

      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          textContent = String.fromCharCodes(file.content as List<int>);
          break;
        }
      }

      // Loại bỏ XML tags đơn giản
      textContent = textContent
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (textContent.isEmpty) {
        return 'File Word trống hoặc không thể đọc được';
      }

      return textContent;
    } catch (e) {
      print('Lỗi chuyển đổi Word: $e');
      return 'Không thể đọc file Word: ${e.toString()}';
    }
  }

  /// Chuyển bytes sang Base64
  static String _bytesSangBase64(List<int> bytes) {
    return base64Encode(bytes);
  }

  static List<CongViecTuAI> parseCongViecTuResponse(String response) {
    try {
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(response);

      if (jsonMatch == null) {
        print('Không tìm thấy JSON trong response');
        return [];
      }

      final jsonString = jsonMatch.group(0)!;
      final jsonData = jsonDecode(jsonString) as List;

      return jsonData
          .map((item) {
        try {
          return CongViecTuAI.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('Lỗi parse công việc: $e');
          return null;
        }
      })
          .whereType<CongViecTuAI>()
          .toList();
    } catch (e) {
      print('Lỗi parse JSON: $e');
      return [];
    }
  }
}