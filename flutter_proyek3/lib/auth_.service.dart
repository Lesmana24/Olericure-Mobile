import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'api_config.dart';

// ==========================================
// 1. FUNGSI LOGIKA REGISTER
// ==========================================
Future<void> prosesRegister(BuildContext context, String nama, String password) async {
  try {
    final response = await http.post(
      ApiConfig.getUri('/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
      },
      body: jsonEncode({
        'nama': nama,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    // 201 Created = Sukses masuk database
    if (response.statusCode == 201 && data['success'] == true) {
      // Tangkep Tokennya
      String token = data['token'];

      // Simpen Token ke Secure Storage
      const storage = FlutterSecureStorage();
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'isLoggedIn', value: 'true'); // Penanda udah login

      // Guard: pastikan widget masih ada sebelum pakai context
      if (!context.mounted) return;

      // Munculin notif sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
      );

      // Pindah ke HomePage dan buang halaman Register dari tumpukan (biar ga bisa di-back)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      if (!context.mounted) return;
      // Kalau gagal (misal nama udah ada)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${data['message'] ?? 'Nama sudah dipakai'}'), backgroundColor: Colors.red),
      );
    }
  } on TimeoutException catch (e) {
    debugPrint('Timeout Register: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal terhubung ke server. Pastikan internet stabil atau coba gunakan jaringan seluler.'),
        backgroundColor: Colors.red,
      ),
    );
  } on SocketException catch (e) {
    debugPrint('SocketException Register: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal terhubung ke server. Pastikan internet stabil atau coba gunakan jaringan seluler.'),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    debugPrint('Error Register: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
    );
  }
}

// ==========================================
// 2. FUNGSI LOGIKA LOGIN
// ==========================================
Future<void> prosesLogin(BuildContext context, String nama, String password) async {
  try {
    final response = await http.post(
      ApiConfig.getUri('/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
      },
      body: jsonEncode({
        'nama': nama,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    // 200 OK = Ketemu dan cocok
    if (response.statusCode == 200 && data['success'] == true) {
      String token = data['token'];

      const storage = FlutterSecureStorage();
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'isLoggedIn', value: 'true');

      // Guard: pastikan widget masih ada sebelum pakai context
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      if (!context.mounted) return;
      // Kalau gagal (salah password / nama ga ada)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${data['message']}'), backgroundColor: Colors.red),
      );
    }
  } on TimeoutException catch (e) {
    debugPrint('Timeout Login: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal terhubung ke server. Pastikan internet stabil atau coba gunakan jaringan seluler.'),
        backgroundColor: Colors.red,
      ),
    );
  } on SocketException catch (e) {
    debugPrint('SocketException Login: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal terhubung ke server. Pastikan internet stabil atau coba gunakan jaringan seluler.'),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    debugPrint('Error Login: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
    );
  }
}