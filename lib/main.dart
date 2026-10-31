import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/cong_viec_con_controller.dart';
import 'services/supabase_service.dart';
import 'views/screens/dang_nhap_screen.dart';
import 'views/screens/dashboard_screen.dart';
import 'controllers/xac_thuc_controller.dart';
import 'controllers/du_an_controller.dart';
import 'controllers/cong_viec_controller.dart';
import 'controllers/ho_so_controller.dart';
import 'controllers/thanh_vien_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Supabase
  await SupabaseService.khoiTao();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quản lý Công việc Nhóm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const KiemTraDangNhap(),
    );
  }
}

class KiemTraDangNhap extends StatelessWidget {
  const KiemTraDangNhap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Khởi tạo XacThucController lần đầu
    if (!Get.isRegistered<XacThucController>()) {
      Get.put(XacThucController());
    }

    final xacThucController = Get.find<XacThucController>();

    return Obx(() {
      if (xacThucController.nguoiDungHienTai.value != null) {
        // Khởi tạo các controller khác khi đã đăng nhập
        if (!Get.isRegistered<DuAnController>()) {
          Get.put(DuAnController());
        }
        if (!Get.isRegistered<CongViecController>()) {
          Get.put(CongViecController());
        }
        if (!Get.isRegistered<HoSoController>()) {
          Get.put(HoSoController());
        }
        if (!Get.isRegistered<ThanhVienController>()) {
          Get.put(ThanhVienController());
        }
        if (!Get.isRegistered<CongViecConController>()) {
          Get.put(CongViecConController());
        }

        return const DashboardScreen();
      }
      return const DangNhapScreen();
    });
  }
}