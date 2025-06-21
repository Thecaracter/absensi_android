import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sistem_presensi/app/controller/theme_controller.dart';
import '../controllers/profile_controller.dart';
import '../../../utils/color_constant.dart';

class EditProfileModal extends StatelessWidget {
  const EditProfileModal({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final themeController = Get.find<ThemeController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? AppColors.surface
            : AppColors.surfaceLightMode,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: themeController.isDarkMode.value
                  ? AppColors.slate600
                  : AppColors.slate300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(themeController),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // Photo section
                    _buildPhotoSection(controller, themeController),
                    const SizedBox(height: 24),

                    // Form fields
                    _buildFormFields(controller, themeController),
                    const SizedBox(height: 32),

                    // Action buttons
                    _buildActionButtons(controller, themeController),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeController.isDarkMode.value
                ? AppColors.border
                : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Edit Profil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkMode.value
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: themeController.isDarkMode.value
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
      ProfileController controller, ThemeController themeController) {
    return Obx(() => Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: themeController.isDarkMode.value
                        ? AppColors.slate800
                        : AppColors.slate100,
                    backgroundImage: _getProfileImage(controller),
                    child: _getProfileImage(controller) == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.showImagePickerOptions,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeController.isDarkMode.value
                              ? AppColors.surface
                              : Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ketuk untuk mengubah foto',
              style: TextStyle(
                fontSize: 12,
                color: themeController.isDarkMode.value
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ));
  }

  ImageProvider? _getProfileImage(ProfileController controller) {
    if (controller.selectedImage.value != null) {
      return FileImage(controller.selectedImage.value!);
    } else if (controller.user.value?.fotoUrl != null) {
      return NetworkImage(controller.user.value!.fotoUrl!);
    }
    return null;
  }

  Widget _buildFormFields(
      ProfileController controller, ThemeController themeController) {
    return Column(
      children: [
        _buildTextField(
          controller: controller.nameController,
          label: 'Nama Lengkap',
          icon: Icons.person_outline,
          validator: controller.validateName,
          themeController: themeController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: controller.emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
          themeController: themeController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: controller.phoneController,
          label: 'No. HP',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: controller.validatePhone,
          themeController: themeController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: controller.addressController,
          label: 'Alamat',
          icon: Icons.location_on_outlined,
          maxLines: 3,
          themeController: themeController,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeController themeController,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? AppColors.slate800.withOpacity(0.5)
            : AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeController.isDarkMode.value
              ? AppColors.slate700
              : AppColors.slate200,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: TextStyle(
          color: themeController.isDarkMode.value
              ? AppColors.textPrimary
              : AppColors.textPrimaryLight,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: themeController.isDarkMode.value
                ? AppColors.textSecondary
                : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: themeController.isDarkMode.value
                  ? AppColors.slate700
                  : AppColors.slate200,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      ProfileController controller, ThemeController themeController) {
    return Obx(() => Column(
          children: [
            // Save button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: themeController.isDarkMode.value
                        ? AppColors.primaryShadow
                        : AppColors.buttonShadowLight,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: controller.isUpdating.value
                    ? null
                    : controller.updateProfile,
                icon: controller.isUpdating.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save_outlined, color: Colors.white),
                label: Text(
                  controller.isUpdating.value
                      ? 'Menyimpan...'
                      : 'Simpan Perubahan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    controller.isUpdating.value ? null : () => Get.back(),
                icon: Icon(
                  Icons.close_outlined,
                  color: themeController.isDarkMode.value
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
                label: Text(
                  'Batal',
                  style: TextStyle(
                    color: themeController.isDarkMode.value
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                    color: themeController.isDarkMode.value
                        ? AppColors.border
                        : AppColors.borderLight,
                    width: 1,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ));
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

  void _populateFormFields() {
    if (user.value != null) {
      nameController.text = user.value!.name;
      emailController.text = user.value!.email;
      phoneController.text = user.value!.noHp ?? '';
      addressController.text = user.value!.alamat ?? '';
    }
  }
}
