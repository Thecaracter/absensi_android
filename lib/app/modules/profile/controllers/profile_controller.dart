import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_presensi/app/data/models/user_model.dart';
import 'package:sistem_presensi/app/modules/profile/views/edit_profile_modal.dart';
import '../../../utils/api_constant.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var user = Rxn<UserProfile>();

  // 🔥 TAMBAH TIMESTAMP UNTUK FORCE REFRESH UI
  var lastUpdateTimestamp = 0.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

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
          // 🔥 CLEAR STATE DULU UNTUK MEMASTIKAN REFRESH
          final oldPhotoUrl = user.value?.fotoUrl;
          user.value = null;
          await Future.delayed(const Duration(milliseconds: 50));

          // 🔥 UPDATE USER DATA DENGAN FORCE REFRESH
          user.value = UserProfile.fromJson(jsonData['data']);
          lastUpdateTimestamp.value = DateTime.now().millisecondsSinceEpoch;
          _populateFormFields();

          print('✅ [FETCH PROFILE] Success!');
          print('🔄 [FETCH PROFILE] Old foto_url: $oldPhotoUrl');
          print('🔄 [FETCH PROFILE] New foto_url: ${user.value?.fotoUrl}');
          print('🔄 [FETCH PROFILE] Timestamp: ${lastUpdateTimestamp.value}');
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

  /// Update profile lengkap (data + foto) - untuk form manual
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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstant.updateProfile),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['_method'] = 'PUT';
      request.fields['name'] = nameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['no_hp'] = phoneController.text.trim();
      request.fields['alamat'] = addressController.text.trim();

      if (selectedImage.value != null) {
        print('📷 [UPDATE PROFILE] Adding photo: ${selectedImage.value!.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            selectedImage.value!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [UPDATE PROFILE] Status Code: ${response.statusCode}');
      print('📥 [UPDATE PROFILE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          // 🔥 FORCE REFRESH STATE
          await _updateUserData(jsonData['data']);

          Get.back();
          _showSuccess('Profil berhasil diperbarui');
          print('✅ [UPDATE PROFILE] Success!');
        } else {
          print('❌ [UPDATE PROFILE] API Error: ${jsonData['message']}');
          _showError(jsonData['message'] ?? 'Gagal memperbarui profil');
        }
      } else if (response.statusCode == 401) {
        await _handleTokenExpired();
      } else if (response.statusCode == 422) {
        _handleValidationErrors(response);
      } else {
        _handleServerError(response);
      }
    } catch (e) {
      print('💥 [UPDATE PROFILE] Exception: ${e.toString()}');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isUpdating(false);
    }
  }

  /// Update hanya data profil (tanpa foto)
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
      print('🔄 [UPDATE DATA ONLY] URL: ${ApiConstant.updateProfileData}');

      final response = await http.patch(
        Uri.parse(ApiConstant.updateProfileData),
        headers: ApiConstant.headersWithAuth(token),
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
          await _updateUserData(jsonData['data']);
          Get.back();
          _showSuccess('Data profil berhasil diperbarui');
          print('✅ [UPDATE DATA ONLY] Success!');
        } else {
          _showError(jsonData['message'] ?? 'Gagal memperbarui profil');
        }
      } else if (response.statusCode == 401) {
        await _handleTokenExpired();
      } else if (response.statusCode == 422) {
        _handleValidationErrors(response);
      } else {
        _handleServerError(response);
      }
    } catch (e) {
      print('💥 [UPDATE DATA ONLY] Exception: ${e.toString()}');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isUpdating(false);
    }
  }

  /// Update hanya foto profil
  Future<void> updateProfilePhotoOnly() async {
    if (selectedImage.value == null) {
      _showError('Pilih foto terlebih dahulu');
      return;
    }

    try {
      isUpdating(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      print('🔄 [UPDATE PHOTO ONLY] Starting update...');
      print('🔄 [UPDATE PHOTO ONLY] URL: ${ApiConstant.updateProfilePhoto}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstant.updateProfilePhoto),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          selectedImage.value!.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [UPDATE PHOTO ONLY] Status Code: ${response.statusCode}');
      print('📥 [UPDATE PHOTO ONLY] Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          await _updateUserData(jsonData['data']);
          Get.back();
          _showSuccess('Foto profil berhasil diperbarui');
          print('✅ [UPDATE PHOTO ONLY] Success!');
        } else {
          _showError(jsonData['message'] ?? 'Gagal memperbarui foto');
        }
      } else if (response.statusCode == 401) {
        await _handleTokenExpired();
      } else if (response.statusCode == 422) {
        _handleValidationErrors(response);
      } else {
        _handleServerError(response);
      }
    } catch (e) {
      print('💥 [UPDATE PHOTO ONLY] Exception: ${e.toString()}');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isUpdating(false);
    }
  }

  // 🔥 AUTO SAVE FOTO SETELAH PILIH - METHOD UTAMA
  Future<void> pickImageFromGalleryWithValidation() async {
    try {
      print('📷 [PICK IMAGE] Opening gallery with validation...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'], // Sesuai backend
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Validasi ukuran file (max 2MB sesuai backend)
        if (fileSize > 2 * 1024 * 1024) {
          _showError('Ukuran file terlalu besar. Maksimal 2MB');
          return;
        }

        selectedImage.value = file;
        print('📷 [PICK IMAGE] Selected: ${result.files.single.path}');
        print(
            '📷 [PICK IMAGE] File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

        // 🔥 AUTO SAVE FOTO LANGSUNG!
        await _autoSaveProfilePhoto();
      } else {
        print('📷 [PICK IMAGE] Cancelled');
      }
    } catch (e) {
      print('💥 [PICK IMAGE] Exception: ${e.toString()}');
      _showError('Gagal memilih gambar: ${e.toString()}');
    }
  }

  // 🤔 PILIH DENGAN KONFIRMASI DULU
  Future<void> pickImageWithConfirmation() async {
    try {
      print('📷 [PICK WITH CONFIRMATION] Opening gallery...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        if (fileSize > 2 * 1024 * 1024) {
          _showError('Ukuran file terlalu besar. Maksimal 2MB');
          return;
        }

        selectedImage.value = file;

        // Tanya konfirmasi dulu
        Get.dialog(
          AlertDialog(
            title: const Text('Konfirmasi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Langsung simpan foto profil ini?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  selectedImage.value = null; // Reset jika batal
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  _autoSaveProfilePhoto(); // Save langsung
                },
                child: const Text('Ya, Simpan'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('💥 [PICK WITH CONFIRMATION] Exception: ${e.toString()}');
      _showError('Gagal memilih gambar: ${e.toString()}');
    }
  }

  // 📷 PILIH MANUAL (TIDAK AUTO SAVE)
  Future<void> pickImageManual() async {
    try {
      print('📷 [PICK MANUAL] Opening gallery...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        if (fileSize > 2 * 1024 * 1024) {
          _showError('Ukuran file terlalu besar. Maksimal 2MB');
          return;
        }

        selectedImage.value = file;
        print('📷 [PICK MANUAL] Selected: ${result.files.single.path}');
        _showSuccess('Foto dipilih! Klik Simpan untuk upload');
      }
    } catch (e) {
      print('💥 [PICK MANUAL] Exception: ${e.toString()}');
      _showError('Gagal memilih gambar: ${e.toString()}');
    }
  }

  // 🔥 METHOD AUTO SAVE FOTO (PRIVATE)
  Future<void> _autoSaveProfilePhoto() async {
    try {
      if (selectedImage.value == null) {
        _showError('Tidak ada foto yang dipilih');
        return;
      }

      // Show enhanced loading dialog
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mengupload foto...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mohon tunggu sebentar',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.3),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Get.back(); // Close loading
        Get.offAllNamed('/login');
        return;
      }

      print('🔄 [AUTO SAVE PHOTO] Using dedicated photo endpoint...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstant.updateProfilePhoto),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          selectedImage.value!.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Get.back(); // Close loading

      print('📥 [AUTO SAVE PHOTO] Status Code: ${response.statusCode}');
      print('📥 [AUTO SAVE PHOTO] Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          // 🔥 FORCE REFRESH STATE DENGAN DELAY UNTUK MEMASTIKAN GAMBAR BARU DI SERVER
          await _updateUserData(jsonData['data']);

          // 🔥 DELAY SEBENTAR UNTUK MEMASTIKAN GAMBAR SUDAH DI SERVER
          await Future.delayed(const Duration(milliseconds: 500));

          // 🔥 REFRESH DATA DARI API UNTUK MEMASTIKAN KONSISTENSI
          await fetchUserProfile();

          _showSuccess('Foto profil berhasil diperbarui!');
          print('✅ [AUTO SAVE PHOTO] Success! New URL: ${user.value?.fotoUrl}');
        } else {
          _showError(jsonData['message'] ?? 'Gagal memperbarui foto');
        }
      } else if (response.statusCode == 401) {
        await _handleTokenExpired();
      } else if (response.statusCode == 422) {
        _handleValidationErrors(response);
      } else {
        _handleServerError(response);
      }
    } catch (e) {
      Get.back(); // Close loading
      print('💥 [AUTO SAVE PHOTO] Exception: ${e.toString()}');
      _showError('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // 🔥 METHOD BARU: UPDATE USER DATA DENGAN FORCE REFRESH
  Future<void> _updateUserData(Map<String, dynamic> userData) async {
    print('🔄 [UPDATE USER DATA] Old foto_url: ${user.value?.fotoUrl}');

    // 🔥 CLEAR STATE DULU
    user.value = null;
    await Future.delayed(const Duration(milliseconds: 100));

    // Update user data
    user.value = UserProfile.fromJson(userData);

    // Force refresh timestamp
    lastUpdateTimestamp.value = DateTime.now().millisecondsSinceEpoch;

    // Reset selected image
    selectedImage.value = null;

    // 🔥 MULTIPLE FORCE REFRESH
    user.refresh();
    update(); // Force GetBuilder update

    print('🔄 [UPDATE USER DATA] New foto_url: ${user.value?.fotoUrl}');
    print('🔄 [UPDATE USER DATA] Timestamp: ${lastUpdateTimestamp.value}');

    // 🔥 VERIFY UPDATE BERHASIL
    await Future.delayed(const Duration(milliseconds: 200));
    print('🔍 [VERIFY] Current user foto_url: ${user.value?.fotoUrl}');

    // Populate form fields with new data
    _populateFormFields();
  }

  // 🎯 SHOW IMAGE PICKER OPTIONS
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Foto Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 🔥 AUTO SAVE LANGSUNG
            _buildImagePickerOption(
              icon: Icons.photo_library,
              label: 'Pilih & Simpan Langsung',
              description: 'JPG, PNG (Max 2MB) - Auto Upload',
              onTap: () {
                Get.back();
                pickImageFromGalleryWithValidation();
              },
            ),

            // 🤔 DENGAN KONFIRMASI DULU
            _buildImagePickerOption(
              icon: Icons.photo_library_outlined,
              label: 'Pilih dengan Preview',
              description: 'Preview foto sebelum upload',
              onTap: () {
                Get.back();
                pickImageWithConfirmation();
              },
            ),

            // 📷 PILIH MANUAL
            _buildImagePickerOption(
              icon: Icons.add_photo_alternate_outlined,
              label: 'Pilih Manual',
              description: 'Pilih foto, save manual di form edit',
              onTap: () {
                Get.back();
                pickImageManual();
              },
            ),

            // 🗑️ HAPUS FOTO YANG DIPILIH
            if (selectedImage.value != null) ...[
              const SizedBox(height: 10),
              _buildImagePickerOption(
                icon: Icons.delete,
                label: 'Hapus Foto yang Dipilih',
                description: 'Reset pilihan foto',
                onTap: () {
                  Get.back();
                  selectedImage.value = null;
                  _showSuccess('Foto dihapus dari pilihan');
                },
                isDelete: true,
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    String? description,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDelete ? Colors.red[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDelete ? Colors.red[200]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDelete ? Colors.red[600] : Colors.grey[700],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isDelete ? Colors.red[600] : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDelete ? Colors.red[400] : Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 HELPER METHODS
  void _handleValidationErrors(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      final errors = jsonData['errors'] as Map<String, dynamic>?;

      if (errors != null) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          _showError(firstError.first.toString());
        } else {
          _showError(jsonData['message'] ?? 'Data tidak valid');
        }
      } else {
        _showError(jsonData['message'] ?? 'Data tidak valid');
      }
    } catch (e) {
      _showError('Data tidak valid');
    }
  }

  void _handleServerError(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      _showError(jsonData['message'] ?? 'Terjadi kesalahan server');
    } catch (e) {
      _showError('Terjadi kesalahan server');
    }
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

  // 🔥 DEBUG METHOD UNTUK TRACKING STATE
  void debugCurrentState() {
    print('🔍 [DEBUG STATE] Current user: ${user.value?.name}');
    print('🔍 [DEBUG STATE] Current foto_url: ${user.value?.fotoUrl}');
    print(
        '🔍 [DEBUG STATE] Last update timestamp: ${lastUpdateTimestamp.value}');
    print('🔍 [DEBUG STATE] Selected image: ${selectedImage.value?.path}');
    print('🔍 [DEBUG STATE] Is loading: ${isLoading.value}');
    print('🔍 [DEBUG STATE] Is updating: ${isUpdating.value}');
  }

  // 🔥 FORCE CLEAR CACHE METHOD
  void forceClearImageCache() {
    print('🧹 [CLEAR CACHE] Clearing image cache...');
    lastUpdateTimestamp.value = DateTime.now().millisecondsSinceEpoch;
    user.refresh();
    update();
    _showSuccess('Cache gambar telah dibersihkan');
  }
}

// Update ProfileController method untuk show modal
extension ProfileControllerExtension on ProfileController {
  void goToEditProfile() {
    _populateFormFields();
    Get.bottomSheet(
      const EditProfileModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }
}
