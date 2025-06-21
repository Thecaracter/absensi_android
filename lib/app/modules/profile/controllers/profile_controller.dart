import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_presensi/app/data/models/user_model.dart';
import 'package:sistem_presensi/app/modules/profile/views/edit_profile_modal.dart';
import '../../../utils/api_constant.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var user = Rxn<UserProfile>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  var selectedImage = Rxn<File>();

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      print('🔍 [FETCH PROFILE] URL: ${ApiConstant.me}');
      print('🔍 [FETCH PROFILE] Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(ApiConstant.me),
        headers: ApiConstant.headersWithAuth(token),
      );

      print('🔍 [FETCH PROFILE] Status Code: ${response.statusCode}');
      print('🔍 [FETCH PROFILE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          user.value = UserProfile.fromJson(jsonData['data']);
          _populateFormFields();
          print('✅ [FETCH PROFILE] Success!');
        } else {
          print('❌ [FETCH PROFILE] API Error: ${jsonData['message']}');
          _showError(jsonData['message'] ?? 'Gagal mengambil data profil');
        }
      } else if (response.statusCode == 401) {
        print('🚫 [FETCH PROFILE] Token expired');
        await _handleTokenExpired();
      } else {
        print('❌ [FETCH PROFILE] Server Error: ${response.statusCode}');
        _showError('Terjadi kesalahan server');
      }
    } catch (e) {
      print('💥 [FETCH PROFILE] Exception: ${e.toString()}');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// Update profile - Fixed method with proper headers
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isUpdating(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      print('🔄 [UPDATE PROFILE] Starting update...');
      print('🔄 [UPDATE PROFILE] URL: ${ApiConstant.updateProfile}');
      print('🔄 [UPDATE PROFILE] Token: ${token.substring(0, 20)}...');

      // Gunakan POST dengan _method override untuk Laravel
      var request = http.MultipartRequest(
        'POST', // ✅ GANTI JADI POST
        Uri.parse(ApiConstant.updateProfile),
      );

      // ✅ HEADERS YANG BENAR UNTUK MULTIPART
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        // ❌ JANGAN SET Content-Type untuk multipart - biar otomatis!
      });

      // ✅ TAMBAH METHOD OVERRIDE UNTUK LARAVEL
      request.fields['_method'] = 'PUT';

      // Add form fields
      request.fields['name'] = nameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['no_hp'] = phoneController.text.trim();
      request.fields['alamat'] = addressController.text.trim();

      print('🔄 [UPDATE PROFILE] Fields:');
      print('   - _method: PUT');
      print('   - name: ${nameController.text.trim()}');
      print('   - email: ${emailController.text.trim()}');
      print('   - no_hp: ${phoneController.text.trim()}');
      print('   - alamat: ${addressController.text.trim()}');

      // Add photo if selected
      if (selectedImage.value != null) {
        print('📷 [UPDATE PROFILE] Adding photo: ${selectedImage.value!.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            selectedImage.value!.path,
          ),
        );
      } else {
        print('📷 [UPDATE PROFILE] No photo selected');
      }

      print('📤 [UPDATE PROFILE] Sending request...');
      print('📤 [UPDATE PROFILE] Headers: ${request.headers}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [UPDATE PROFILE] Status Code: ${response.statusCode}');
      print('📥 [UPDATE PROFILE] Response Headers: ${response.headers}');
      print('📥 [UPDATE PROFILE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          user.value = UserProfile.fromJson(jsonData['data']);
          selectedImage.value = null;

          Get.back();
          _showSuccess('Profil berhasil diperbarui');
          print('✅ [UPDATE PROFILE] Success!');
        } else {
          print('❌ [UPDATE PROFILE] API Error: ${jsonData['message']}');
          _showError(jsonData['message'] ?? 'Gagal memperbarui profil');
        }
      } else if (response.statusCode == 401) {
        print('🚫 [UPDATE PROFILE] Token expired');
        await _handleTokenExpired();
      } else {
        print('❌ [UPDATE PROFILE] Server Error: ${response.statusCode}');
        try {
          final jsonData = json.decode(response.body);
          print('❌ [UPDATE PROFILE] Error Details: ${jsonData}');
          _showError(jsonData['message'] ?? 'Terjadi kesalahan server');
        } catch (e) {
          print('❌ [UPDATE PROFILE] Raw Error Response: ${response.body}');
          _showError('Terjadi kesalahan server');
        }
      }
    } catch (e) {
      print('💥 [UPDATE PROFILE] Exception: ${e.toString()}');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isUpdating(false);
    }
  }

  /// Update hanya data profil (tanpa foto) - menggunakan JSON
  Future<void> updateProfileDataOnly() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isUpdating(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      print('🔄 [UPDATE DATA ONLY] Starting update...');

      // Gunakan regular HTTP request untuk data saja
      final response = await http.put(
        Uri.parse(ApiConstant.updateProfile),
        headers: ApiConstant.headersWithAuth(token), // ✅ JSON headers OK
        body: json.encode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'no_hp': phoneController.text.trim(),
          'alamat': addressController.text.trim(),
        }),
      );

      print('📥 [UPDATE DATA ONLY] Status Code: ${response.statusCode}');
      print('📥 [UPDATE DATA ONLY] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          user.value = UserProfile.fromJson(jsonData['data']);
          Get.back();
          _showSuccess('Profil berhasil diperbarui');
          print('✅ [UPDATE DATA ONLY] Success!');
        } else {
          print('❌ [UPDATE DATA ONLY] API Error: ${jsonData['message']}');
          _showError(jsonData['message'] ?? 'Gagal memperbarui profil');
        }
      } else {
        final jsonData = json.decode(response.body);
        print('❌ [UPDATE DATA ONLY] Error: ${jsonData}');
        _showError(jsonData['message'] ?? 'Terjadi kesalahan server');
      }
    } catch (e) {
      print('💥 [UPDATE DATA ONLY] Exception: ${e.toString()}');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isUpdating(false);
    }
  }

  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      print('📷 [PICK IMAGE] Source: ${fromCamera ? 'Camera' : 'Gallery'}');

      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        print('📷 [PICK IMAGE] Selected: ${image.path}');
        print('📷 [PICK IMAGE] File size: ${await image.length()} bytes');
      } else {
        print('📷 [PICK IMAGE] Cancelled');
      }
    } catch (e) {
      print('💥 [PICK IMAGE] Exception: ${e.toString()}');
      _showError('Gagal memilih gambar: ${e.toString()}');
    }
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Foto Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () {
                    Get.back();
                    pickImage(fromCamera: true);
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () {
                    Get.back();
                    pickImage(fromCamera: false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        print('🚪 [LOGOUT] Calling logout API...');
        await http.post(
          Uri.parse(ApiConstant.logout),
          headers: ApiConstant.headersWithAuth(token),
        );
      }

      await prefs.clear();
      Get.offAllNamed('/login');
      print('✅ [LOGOUT] Success!');
    } catch (e) {
      print('💥 [LOGOUT] Exception: ${e.toString()}');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed('/login');
    }
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> refreshProfile() async {
    await fetchUserProfile();
  }

  void _populateFormFields() {
    if (user.value != null) {
      nameController.text = user.value!.name;
      emailController.text = user.value!.email;
      phoneController.text = user.value!.noHp ?? '';
      addressController.text = user.value!.alamat ?? '';
      print('📝 [POPULATE FIELDS] Filled form with user data');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> _handleTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Get.offAllNamed('/login');
    Get.snackbar(
      'Sesi Berakhir',
      'Silakan login kembali',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < 10) {
        return 'Nomor HP minimal 10 digit';
      }
    }
    return null;
  }

  void showEditProfileModal() {
    _populateFormFields();
    Get.bottomSheet(
      const EditProfileModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }
}
