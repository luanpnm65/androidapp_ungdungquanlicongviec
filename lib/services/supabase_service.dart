import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> khoiTao() async {
    await Supabase.initialize(
      url: 'https://sezajxwndzxjssaqunjq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNlemFqeHduZHp4anNzYXF1bmpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyNDc2NzYsImV4cCI6MjA5NTgyMzY3Nn0.ZTWcqHgzc9cp-zqNtAcj-ca1lS-owm95ZB4WzzBiiN4',
    );
  }

  // Auth methods
  static User? get nguoiDungHienTai => client.auth.currentUser;

  static Future<AuthResponse> dangNhap(String email, String matKhau) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: matKhau,
    );
  }

  static Future<AuthResponse> dangKy(String email, String matKhau) async {
    return await client.auth.signUp(
      email: email,
      password: matKhau,
    );
  }

  static Future<void> dangXuat() async {
    await client.auth.signOut();
  }

  // Database methods
  static SupabaseQueryBuilder get duAnTable => client.from('du_an');
  static SupabaseQueryBuilder get congViecTable => client.from('cong_viec');
  static SupabaseQueryBuilder get thanhVienDuAnTable => client.from('thanh_vien_du_an');
}