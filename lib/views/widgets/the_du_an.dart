import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/du_an_controller.dart';
import '../../models/du_an.dart';
import '../screens/chi_tiet_du_an_screen.dart';

class TheDuAn extends StatelessWidget {
  final DuAn duAn;
  final bool laChuDuAn;

  const TheDuAn({
    Key? key,
    required this.duAn,
    required this.laChuDuAn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duAnController = Get.find<DuAnController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => ChiTietDuAnScreen(
            duAn: duAn,
            laChuDuAn: laChuDuAn,
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: laChuDuAn ? Colors.purple : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      duAn.ten,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // ← THÊM POPUP MENU
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) async {
                      switch (value) {
                        case 'luu_tru':
                          _hienThiDialogLuuTru(context, duAnController);
                          break;
                        case 'xoa':
                          _hienThiDialogXoa(context, duAnController);
                          break;
                        case 'roi_khoi':
                          _hienThiDialogRoiKhoi(context, duAnController);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (laChuDuAn) ...[
                        const PopupMenuItem(
                          value: 'luu_tru',
                          child: Row(
                            children: [
                              Icon(Icons.archive, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Lưu trữ'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'xoa',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa dự án', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ] else ...[
                        const PopupMenuItem(
                          value: 'roi_khoi',
                          child: Row(
                            children: [
                              Icon(Icons.exit_to_app, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Rời dự án', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (duAn.moTa != null) ...[
                const SizedBox(height: 8),
                Text(
                  duAn.moTa!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  // Badge vai trò
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: laChuDuAn ? Colors.purple[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          laChuDuAn ? Icons.star : Icons.group,
                          size: 12,
                          color: laChuDuAn ? Colors.purple : Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          laChuDuAn ? 'Chủ dự án' : 'Thành viên',
                          style: TextStyle(
                            fontSize: 11,
                            color: laChuDuAn ? Colors.purple : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Badge trạng thái
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: duAn.daHoanThanh
                          ? Colors.green[50]
                          : duAn.thatBai
                          ? Colors.red[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(6),
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
              if (duAn.ngayHetHan != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: DateTime.now().isAfter(duAn.ngayHetHan!)
                          ? Colors.red
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hạn: ${duAn.ngayHetHan.toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 12,
                        color: DateTime.now().isAfter(duAn.ngayHetHan!)
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _hienThiDialogLuuTru(
      BuildContext context,
      DuAnController controller,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lưu trữ dự án'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn muốn lưu trữ "${duAn.ten}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dự án sẽ được ẩn khỏi danh sách chính và chuyển vào Kho lưu trữ. Bạn có thể khôi phục lại sau.',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
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
              await controller.luuTruDuAn(duAn.id);
            },
            icon: const Icon(Icons.archive),
            label: const Text('Lưu trữ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  void _hienThiDialogXoa(
      BuildContext context,
      DuAnController controller,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dự án'),
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
                      'Hành động này không thể hoàn tác!\nToàn bộ công việc và thành viên sẽ bị xóa.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
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
            icon: const Icon(Icons.delete),
            label: const Text('Xóa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _hienThiDialogRoiKhoi(
      BuildContext context,
      DuAnController controller,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời khỏi dự án'),
        content: Text('Bạn muốn rời khỏi "${duAn.ten}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await controller.roiKhoiDuAn(duAn.id);
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Rời dự án'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}