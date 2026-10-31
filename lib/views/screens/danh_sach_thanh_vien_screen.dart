import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/thanh_vien_controller.dart';
import '../../models/du_an.dart';
import 'chi_tiet_thanh_vien_screen.dart';

class DanhSachThanhVienScreen extends StatefulWidget {
  final DuAn duAn;
  final bool laChuDuAn;

  const DanhSachThanhVienScreen({
    Key? key,
    required this.duAn,
    required this.laChuDuAn,
  }) : super(key: key);

  @override
  State<DanhSachThanhVienScreen> createState() => _DanhSachThanhVienScreenState();
}

class _DanhSachThanhVienScreenState extends State<DanhSachThanhVienScreen> {
  final thanhVienController = Get.put(ThanhVienController());

  @override
  void initState() {
    super.initState();
    thanhVienController.taiDanhSachThanhVien(widget.duAn.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thành viên'),
      ),
      body: Obx(() {
        if (thanhVienController.dangTaiDuLieu.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (thanhVienController.danhSachThanhVien.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có thành viên nào',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => thanhVienController.taiDanhSachThanhVien(widget.duAn.id),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: thanhVienController.danhSachThanhVien.length,
            itemBuilder: (context, index) {
              final thanhVien = thanhVienController.danhSachThanhVien[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.person),
                  ),
                  title: Text(
                    thanhVien.ten ?? 'Chưa cập nhật tên',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Mở màn hình chi tiết
                    Get.to(() => ChiTietThanhVienScreen(thanhVien: thanhVien));
                  },
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(thanhVien.email),
                      if (thanhVien.viTri != null)
                        Text(
                          thanhVien.viTri!,
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: widget.laChuDuAn
                      ? PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xóa thành viên'),
                              content: Text(
                                'Bạn có chắc muốn xóa ${thanhVien.ten ?? thanhVien.email}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Get.back();
                                    await thanhVienController.xoaThanhVien(
                                      widget.duAn.id,
                                      thanhVien.id,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa'),
                          ],
                        ),
                      ),
                    ],
                  )
                      : null,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}