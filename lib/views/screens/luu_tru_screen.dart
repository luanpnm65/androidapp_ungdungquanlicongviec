import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/du_an_controller.dart';
import '../../models/du_an.dart';
import '../screens/chi_tiet_du_an_screen.dart';

class LuuTruScreen extends StatelessWidget {
  const LuuTruScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duAnController = Get.find<DuAnController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho lưu trữ'),
      ),
      body: Obx(() {
        if (duAnController.dangTaiDuLieu.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (duAnController.danhSachDuAnLuuTru.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.archive_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'Kho lưu trữ trống',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Các dự án đã hoàn thành sẽ\nxuất hiện ở đây',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => duAnController.taiDanhSachDuAn(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: duAnController.danhSachDuAnLuuTru.length,
            itemBuilder: (context, index) {
              final duAn = duAnController.danhSachDuAnLuuTru[index];
              return _xayDungTheDuAnLuuTru(context, duAn, duAnController);
            },
          ),
        );
      }),
    );
  }

  Widget _xayDungTheDuAnLuuTru(
      BuildContext context,
      DuAn duAn,
      DuAnController duAnController,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.archive, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    duAn.ten,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: duAn.daHoanThanh
                        ? Colors.green[100]
                        : duAn.thatBai
                        ? Colors.red[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    duAn.daHoanThanh
                        ? '✓ Hoàn thành'
                        : duAn.thatBai
                        ? '✗ Thất bại'
                        : '⏳ Đang làm',
                    style: TextStyle(
                      fontSize: 11,
                      color: duAn.daHoanThanh
                          ? Colors.green[700]
                          : duAn.thatBai
                          ? Colors.red[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (duAn.moTa != null) ...[
              const SizedBox(height: 8),
              Text(
                duAn.moTa!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Tạo: ${duAn.ngayTao.toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (duAn.ngayHetHan != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.event, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Hạn: ${duAn.ngayHetHan.toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => ChiTietDuAnScreen(
                        duAn: duAn,
                        laChuDuAn: true,
                      ));
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Xem'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _hienThiDialogKhoiPhuc(context, duAn, duAnController);
                    },
                    icon: const Icon(Icons.unarchive, size: 16),
                    label: const Text('Khôi phục'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _hienThiDialogXoa(context, duAn, duAnController);
                    },
                    icon: const Icon(Icons.delete_forever, size: 16, color: Colors.red),
                    label: const Text(
                      'Xóa',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _hienThiDialogKhoiPhuc(
      BuildContext context,
      DuAn duAn,
      DuAnController controller,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục dự án'),
        content: Text('Bạn muốn khôi phục "${duAn.ten}" về danh sách dự án?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await controller.khoiPhucDuAn(duAn.id);
            },
            icon: const Icon(Icons.unarchive),
            label: const Text('Khôi phục'),
          ),
        ],
      ),
    );
  }

  void _hienThiDialogXoa(
      BuildContext context,
      DuAn duAn,
      DuAnController controller,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dự án vĩnh viễn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn chắc chắn muốn xóa "${duAn.ten}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hành động này không thể hoàn tác!\nToàn bộ công việc trong dự án sẽ bị xóa.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await controller.xoaDuAn(duAn.id);
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Xóa vĩnh viễn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}