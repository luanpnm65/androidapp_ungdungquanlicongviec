import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/cong_viec_controller.dart';
import '../../models/cong_viec.dart';

class CalendarCongViecScreen extends StatefulWidget {
  final String duAnId;
  final bool chiXemCuaToi;

  const CalendarCongViecScreen({
    Key? key,
    required this.duAnId,
    this.chiXemCuaToi = false,
  }) : super(key: key);

  @override
  State<CalendarCongViecScreen> createState() => _CalendarCongViecScreenState();
}

class _CalendarCongViecScreenState extends State<CalendarCongViecScreen> {
  final congViecController = Get.find<CongViecController>();
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<CongViec>> _eventsByDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _eventsByDay = {};
    _taiSuKienTheoNgay();
  }

  void _taiSuKienTheoNgay() {
    _eventsByDay = {};

    List<CongViec> danhSach = widget.chiXemCuaToi
        ? congViecController.congViecCuaToi
        : congViecController.danhSachCongViec;

    for (var congViec in danhSach) {
      if (congViec.ngayHetHan != null) {
        final ngayKey = DateTime(
          congViec.ngayHetHan!.year,
          congViec.ngayHetHan!.month,
          congViec.ngayHetHan!.day,
        );

        if (_eventsByDay[ngayKey] != null) {
          _eventsByDay[ngayKey]!.add(congViec);
        } else {
          _eventsByDay[ngayKey] = [congViec];
        }
      }
    }
  }

  List<CongViec> _layTuCongViecNgay(DateTime day) {
    final ngayKey = DateTime(day.year, day.month, day.day);
    return _eventsByDay[ngayKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chiXemCuaToi ? 'Công việc của tôi - Lịch' : 'Lịch công việc'),
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _layTuCongViecNgay,
            calendarStyle: CalendarStyle(
              // Style cho ngày được chọn
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              // Style cho ngày hôm nay
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              // Style cho ngày có sự kiện
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 16),

          // Danh sách công việc của ngày được chọn
          Expanded(
            child: _xayDungDanhSachCongViecNgay(),
          ),
        ],
      ),
    );
  }

  Widget _xayDungDanhSachCongViecNgay() {
    final congViecNgayNay = _layTuCongViecNgay(_selectedDay);

    if (congViecNgayNay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Ngày ${_selectedDay.day}/${_selectedDay.month} không có công việc',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: congViecNgayNay.length,
      itemBuilder: (context, index) {
        final congViec = congViecNgayNay[index];
        return _xayDungTheoCongViec(congViec);
      },
    );
  }

  Widget _xayDungTheoCongViec(CongViec congViec) {
    Color _layMauTrangThai() {
      switch (congViec.trangThai) {
        case TrangThaiCongViec.chuaNhan:
          return Colors.grey;
        case TrangThaiCongViec.daNhan:
          return Colors.blue;
        case TrangThaiCongViec.dangThucHien:
          return Colors.orange;
        case TrangThaiCongViec.hoanThanh:
          return Colors.green;
        case TrangThaiCongViec.quaHan:
          return Colors.red;
      }
    }

    String _layTenTrangThai() {
      switch (congViec.trangThai) {
        case TrangThaiCongViec.chuaNhan:
          return 'Chưa nhận';
        case TrangThaiCongViec.daNhan:
          return 'Đã nhận';
        case TrangThaiCongViec.dangThucHien:
          return 'Đang làm';
        case TrangThaiCongViec.hoanThanh:
          return 'Hoàn thành';
        case TrangThaiCongViec.quaHan:
          return 'Quá hạn';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    congViec.tieuDe,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    _layTenTrangThai(),
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: _layMauTrangThai(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (congViec.tenNguoiNhan != null)
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Người nhận: ${congViec.tenNguoiNhan}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Hạn: ${congViec.ngayHetHan.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}