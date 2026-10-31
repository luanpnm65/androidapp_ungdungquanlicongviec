import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ho_so_controller.dart';
import '../../controllers/xac_thuc_controller.dart';

class HoSoScreen extends StatefulWidget {
  const HoSoScreen({Key? key}) : super(key: key);

  @override
  State<HoSoScreen> createState() => _HoSoScreenState();
}

class _HoSoScreenState extends State<HoSoScreen> {
  late HoSoController hoSoController;
  late XacThucController xacThucController;

  late TextEditingController _tenController;
  late TextEditingController _sdtController;
  late TextEditingController _viTriController;
  late TextEditingController _moTaController;
  bool _dangSua = false;

  @override
  void initState() {
    super.initState();

    hoSoController = Get.find<HoSoController>();
    xacThucController = Get.find<XacThucController>();

    _tenController = TextEditingController();
    _sdtController = TextEditingController();
    _viTriController = TextEditingController();
    _moTaController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capNhatCacTruongThongTin();
    });
  }

  @override
  void dispose() {
    _tenController.dispose();
    _sdtController.dispose();
    _viTriController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  void _capNhatCacTruongThongTin() {
    if (hoSoController.hoSoNguoiDung.value != null) {
      _tenController.text = hoSoController.hoSoNguoiDung.value!.ten ?? '';
      _sdtController.text = hoSoController.hoSoNguoiDung.value!.sdt ?? '';
      _viTriController.text = hoSoController.hoSoNguoiDung.value!.viTri ?? '';
      _moTaController.text = hoSoController.hoSoNguoiDung.value!.moTa ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          if (!_dangSua)
            TextButton.icon(
              onPressed: () => setState(() => _dangSua = true),
              icon: const Icon(Icons.edit),
              label: const Text('Chỉnh sửa'),
            )
          else
            TextButton.icon(
              onPressed: () => setState(() => _dangSua = false),
              icon: const Icon(Icons.close),
              label: const Text('Hủy'),
            ),
        ],
      ),
      body: Obx(() {
        if (hoSoController.hoSoNguoiDung.value != null) {
          if (_tenController.text.isEmpty && hoSoController.hoSoNguoiDung.value!.ten != null) {
            _capNhatCacTruongThongTin();
          }
        }

        if (hoSoController.dangTaiDuLieu.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
          length: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const SizedBox(height: 32),

                // Tab bar

                const SizedBox(height: 16),

                // Tab 1: Thông tin
                _xayDungTabThongTin(),

                const SizedBox(height: 32),

                // Tab 2: Cài đặt
                _xayDungTabCaiDat(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _xayDungTabThongTin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email (read-only)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  xacThucController.nguoiDungHienTai.value?.email ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tên
        TextField(
          controller: _tenController,
          enabled: _dangSua,
          decoration: InputDecoration(
            labelText: 'Tên',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person),
            filled: !_dangSua,
            fillColor: !_dangSua ? Colors.grey[100] : null,
          ),
        ),
        const SizedBox(height: 16),

        // Số điện thoại
        TextField(
          controller: _sdtController,
          enabled: _dangSua,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Số điện thoại',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone),
            filled: !_dangSua,
            fillColor: !_dangSua ? Colors.grey[100] : null,
          ),
        ),
        const SizedBox(height: 16),

        // Vị trí công việc
        TextField(
          controller: _viTriController,
          enabled: _dangSua,
          decoration: InputDecoration(
            labelText: 'Vị trí công việc',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.work),
            filled: !_dangSua,
            fillColor: !_dangSua ? Colors.grey[100] : null,
          ),
        ),
        const SizedBox(height: 16),

        // Mô tả bản thân
        TextField(
          controller: _moTaController,
          enabled: _dangSua,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Mô tả bản thân',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.description),
            filled: !_dangSua,
            fillColor: !_dangSua ? Colors.grey[100] : null,
          ),
        ),
        const SizedBox(height: 24),

        if (_dangSua)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _capNhatCacTruongThongTin();
                    setState(() => _dangSua = false);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final thanhCong = await hoSoController.capNhatHoSo(
                      ten: _tenController.text.trim(),
                      sdt: _sdtController.text.trim().isEmpty
                          ? null
                          : _sdtController.text.trim(),
                      viTri: _viTriController.text.trim().isEmpty
                          ? null
                          : _viTriController.text.trim(),
                      moTa: _moTaController.text.trim().isEmpty
                          ? null
                          : _moTaController.text.trim(),
                    );

                    if (thanhCong && mounted) {
                      setState(() => _dangSua = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _xayDungTabCaiDat() {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Đổi mật khẩu'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _hienThiDialogDoiMatKhau();
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Xóa tài khoản',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _hienThiDialogXoaTaiKhoan();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Thông tin tài khoản
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin tài khoản',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Email:'),
                    Text(
                      xacThucController.nguoiDungHienTai.value?.email ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thành viên từ:'),
                    Text(
                      hoSoController.hoSoNguoiDung.value?.ngayTao
                          .toString()
                          .split(' ')[0] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _hienThiDialogDoiMatKhau() {
    final matKhauCuController = TextEditingController();
    final matKhauMoiController = TextEditingController();
    final xacNhanMatKhauController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: matKhauCuController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu cũ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu cũ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: matKhauMoiController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu mới phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: xacNhanMatKhauController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value != matKhauMoiController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
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
          Obx(() => ElevatedButton(
            onPressed: xacThucController.dangTaiDuLieu.value
                ? null
                : () async {
              if (formKey.currentState!.validate()) {
                final thanhCong = await xacThucController.doiMatKhau(
                  matKhauCuController.text,
                  matKhauMoiController.text,
                );

                if (thanhCong) {
                  Get.back();
                }
              }
            },
            child: xacThucController.dangTaiDuLieu.value
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Đổi mật khẩu'),
          )),
        ],
      ),
    );
  }

  void _hienThiDialogXoaTaiKhoan() {
    Get.dialog(
      AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text(
          'Bạn chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác và tất cả dữ liệu sẽ bị xóa vĩnh viễn.',
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.snackbar('Thông báo', 'Tính năng xóa tài khoản sẽ được bổ sung');
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
  }
}