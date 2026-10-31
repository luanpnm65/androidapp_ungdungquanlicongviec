import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/du_an_controller.dart';
import '../../controllers/xac_thuc_controller.dart';
import '../../controllers/ho_so_controller.dart';
import '../widgets/the_du_an.dart';
import 'dang_nhap_screen.dart';
import 'ho_so_screen.dart';
import 'luu_tru_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final duAnController = Get.put(DuAnController());
  final xacThucController = Get.find<XacThucController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print('🔄 Làm tươi dữ liệu...');
              await duAnController.taiDanhSachDuAn();
            },
          ),
        ],
      ),
      drawer: _xayDungDrawer(),
      body: Obx(() {
        print('📊 Cập nhật dashboard - Dự án: ${duAnController.danhSachDuAnChuSoHuu.length} + ${duAnController.danhSachDuAnThamGia.length}');

        if (duAnController.dangTaiDuLieu.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => duAnController.taiDanhSachDuAn(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _xayDungThongKe(),
                  const SizedBox(height: 24),
                  _xayDungDanhSachDuAnChuSoHuu(),
                  const SizedBox(height: 24),
                  _xayDungDanhSachDuAnThamGia(),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _hienThiDialogTaoDuAn,
        icon: const Icon(Icons.add),
        label: const Text('Tạo dự án'),
      ),
    );
  }

  Widget _xayDungDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ... DrawerHeader giữ nguyên

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Hồ sơ cá nhân'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HoSoScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Tham gia dự án'),
            onTap: () {
              Get.back();
              _hienThiDialogThamGiaDuAn();
            },
          ),

          // ← THÊM MỤC KHO LƯU TRỮ
          ListTile(
            leading: const Icon(Icons.archive_outlined, color: Colors.orange),
            title: const Text('Kho lưu trữ'),
            trailing: Obx(() {
              final soLuong = duAnController.danhSachDuAnLuuTru.length;
              if (soLuong == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  soLuong.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              );
            }),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LuuTruScreen()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await xacThucController.dangXuat();
              Get.offAll(() => const DangNhapScreen());
            },
          ),
        ],
      ),
    );
  }


  Widget _xayDungThongKe() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _xayDungMucThongKe(
                  'Tổng dự án',
                  duAnController.tongDuAn.toString(),
                  Icons.folder,
                  Colors.blue,
                ),
                _xayDungMucThongKe(
                  'Hoàn thành',
                  duAnController.duAnHoanThanh.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _xayDungMucThongKe(
                  'Đang làm',
                  duAnController.duAnChuaHoanThanh.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _xayDungMucThongKe(String tieuDe, String giaTri, IconData icon, Color mau) {
    return Column(
      children: [
        Icon(icon, color: mau, size: 32),
        const SizedBox(height: 8),
        Text(
          giaTri,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: mau,
          ),
        ),
        Text(
          tieuDe,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _xayDungDanhSachDuAnChuSoHuu() {
    return Obx(() {
      if (duAnController.danhSachDuAnChuSoHuu.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dự án của tôi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: duAnController.danhSachDuAnChuSoHuu.length,
            itemBuilder: (context, index) {
              return TheDuAn(
                duAn: duAnController.danhSachDuAnChuSoHuu[index],
                laChuDuAn: true,
              );
            },
          ),
        ],
      );
    });
  }

  Widget _xayDungDanhSachDuAnThamGia() {
    return Obx(() {
      if (duAnController.danhSachDuAnThamGia.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có dự án nào',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dự án tham gia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: duAnController.danhSachDuAnThamGia.length,
            itemBuilder: (context, index) {
              return TheDuAn(
                duAn: duAnController.danhSachDuAnThamGia[index],
                laChuDuAn: false,
              );
            },
          ),
        ],
      );
    });
  }

  void _hienThiDialogTaoDuAn() {
    final tenController = TextEditingController();
    final moTaController = TextEditingController();
    DateTime? ngayHetHan;

    Get.dialog(
      AlertDialog(
        title: const Text('Tạo dự án mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tenController,
                decoration: const InputDecoration(
                  labelText: 'Tên dự án',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: moTaController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  ngayHetHan == null
                      ? 'Chọn ngày hết hạn (tùy chọn)'
                      : 'Hết hạn: ${ngayHetHan.toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final ngay = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (ngay != null) {
                    ngayHetHan = ngay;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tenController.text.trim().isNotEmpty) {
                Get.back();
                await duAnController.taoDuAn(
                  tenController.text.trim(),
                  moTaController.text.trim().isEmpty ? null : moTaController.text.trim(),
                  ngayHetHan,
                );
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _hienThiDialogThamGiaDuAn() {
    final maController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Tham gia dự án'),
        content: TextField(
          controller: maController,
          decoration: const InputDecoration(
            labelText: 'Nhập mã mời',
            border: OutlineInputBorder(),
            hintText: 'VD: ABC12345',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (maController.text.trim().isNotEmpty) {
                Get.back();
                await duAnController.thamGiaDuAnBangMa(maController.text.trim());
              }
            },
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }
}