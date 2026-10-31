import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cong_viec_controller.dart';
import '../../models/cong_viec.dart';
import '../../models/du_an.dart';
import '../widgets/the_cong_viec.dart';
import 'calendar_cong_viec_screen.dart';

class DanhSachCongViecScreen extends StatefulWidget {
  final DuAn duAn;
  final bool laChuDuAn;

  const DanhSachCongViecScreen({
    Key? key,
    required this.duAn,
    required this.laChuDuAn,
  }) : super(key: key);

  @override
  State<DanhSachCongViecScreen> createState() => _DanhSachCongViecScreenState();
}

class _DanhSachCongViecScreenState extends State<DanhSachCongViecScreen>
    with SingleTickerProviderStateMixin {
  final congViecController = Get.find<CongViecController>();
  late TabController _tabController;

  final TextEditingController _timKiemController = TextEditingController();
  TrangThaiCongViec? _locTrangThai;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // ← THAY TỪ 3 THÀNH 4
    congViecController.taiDanhSachCongViec(widget.duAn.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timKiemController.dispose();
    super.dispose();
  }

  List<CongViec> _locVaTimKiem(List<CongViec> danhSach) {
    var ketQua = danhSach;

    // Lọc theo trang thái
    if (_locTrangThai != null) {
      ketQua = ketQua.where((cv) => cv.trangThai == _locTrangThai).toList();
    }

    // Tìm kiếm theo tiêu đề
    if (_timKiemController.text.isNotEmpty) {
      ketQua = ketQua
          .where((cv) =>
      cv.tieuDe.toLowerCase().contains(_timKiemController.text.toLowerCase()) ||
          (cv.moTa?.toLowerCase().contains(_timKiemController.text.toLowerCase()) ?? false))
          .toList();
    }

    return ketQua;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        actions: [
          if (widget.laChuDuAn)  // ← THÊM NÚT + NẾU LÀ CHỦ DỰ ÁN
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _hienThiDialogTaoCongViec,
              tooltip: 'Thêm công việc',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả', icon: Icon(Icons.list)),
            Tab(text: 'Lịch', icon: Icon(Icons.calendar_today)), // ← THÊMTAB NÀY
            Tab(text: 'Chưa nhận', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Của tôi', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: Obx(() {
        if (congViecController.dangTaiDuLieu.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [
            // Tab 0: Tất cả với search
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButton<TrangThaiCongViec?>(
                    value: _locTrangThai,
                    isExpanded: true,
                    hint: const Text('Lọc trạng thái'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ...TrangThaiCongViec.values.map((trangThai) {
                        String tenTrangThai;
                        switch (trangThai) {
                          case TrangThaiCongViec.chuaNhan:
                            tenTrangThai = 'Chưa nhận';
                            break;
                          case TrangThaiCongViec.daNhan:
                            tenTrangThai = 'Đã nhận';
                            break;
                          case TrangThaiCongViec.dangThucHien:
                            tenTrangThai = 'Đang làm';
                            break;
                          case TrangThaiCongViec.hoanThanh:
                            tenTrangThai = 'Hoàn thành';
                            break;
                          case TrangThaiCongViec.quaHan:
                            tenTrangThai = 'Quá hạn';
                            break;
                        }
                        return DropdownMenuItem(
                          value: trangThai,
                          child: Text(tenTrangThai),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _locTrangThai = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _xayDungDanhSach(
                    _locVaTimKiem(congViecController.danhSachCongViec),
                  ),
                ),
              ],
            ),

            // Tab 1: Calendar (Tất cả)
            CalendarCongViecScreen(
              duAnId: widget.duAn.id,
              chiXemCuaToi: false,
            ),

            // Tab 2: Chưa nhận
            _xayDungDanhSach(_locVaTimKiem(congViecController.congViecChuaNhan)),

            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Danh sách', icon: Icon(Icons.list)),
                      Tab(text: 'Lịch', icon: Icon(Icons.calendar_today)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Danh sách
                        _xayDungDanhSach(congViecController.congViecCuaToi),
                        // Lịch
                        CalendarCongViecScreen(
                          duAnId: widget.duAn.id,
                          chiXemCuaToi: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _xayDungDanhSach(List<CongViec> danhSach) {
    if (danhSach.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có công việc nào',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => congViecController.taiDanhSachCongViec(widget.duAn.id),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: danhSach.length,
        itemBuilder: (context, index) {
          return TheCongViec(
            congViec: danhSach[index],
            laChuDuAn: widget.laChuDuAn,
          );
        },
      ),
    );
  }
  void _hienThiDialogTaoCongViec() {
    final tieuDeController = TextEditingController();
    final moTaController = TextEditingController();
    DateTime? ngayHetHan;

    Get.dialog(
      AlertDialog(
        title: const Text('Tạo công việc mới'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tieuDeController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
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
                        ? 'Chọn deadline (tùy chọn)'
                        : 'Deadline: ${ngayHetHan.toString().split(' ')[0]}',
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
                      setState(() {
                        ngayHetHan = ngay;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tieuDeController.text.trim().isNotEmpty) {
                Get.back();
                await congViecController.taoCongViec(
                  duAnId: widget.duAn.id,
                  tieuDe: tieuDeController.text.trim(),
                  moTa: moTaController.text.trim().isEmpty
                      ? null
                      : moTaController.text.trim(),
                  ngayHetHan: ngayHetHan,
                );
              } else {
                Get.snackbar('Lỗi', 'Vui lòng nhập tiêu đề');
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}