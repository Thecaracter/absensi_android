// File: lib/app/modules/profile/views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sistem_presensi/app/controller/theme_controller.dart';
import '../controllers/profile_controller.dart';
import '../../../utils/color_constant.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: themeController.isDarkMode.value
          ? AppColors.background
          : AppColors.backgroundLightMode,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          color: AppColors.primary,
          backgroundColor: themeController.isDarkMode.value
              ? AppColors.surface
              : AppColors.surfaceLightMode,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Card
                  _buildProfileCard(themeController),
                  const SizedBox(height: 20),

                  // Info Card
                  _buildInfoCard(themeController),
                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(themeController),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileCard(ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? AppColors.surface
            : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeController.isDarkMode.value
              ? AppColors.border
              : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeController.isDarkMode.value
                ? Colors.black.withOpacity(0.3)
                : AppColors.cardShadowLight,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
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
                  radius: 60,
                  backgroundColor: themeController.isDarkMode.value
                      ? AppColors.slate800
                      : AppColors.slate100,
                  backgroundImage: controller.user.value?.fotoUrl != null
                      ? NetworkImage(controller.user.value!.fotoUrl!)
                      : null,
                  child: controller.user.value?.fotoUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeController.isDarkMode.value
                          ? AppColors.surface
                          : Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            controller.user.value?.name ?? 'Loading...',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: themeController.isDarkMode.value
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ID: ${controller.user.value?.idKaryawan ?? ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.2)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Karyawan Aktif',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? AppColors.surface
            : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeController.isDarkMode.value
              ? AppColors.border
              : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeController.isDarkMode.value
                ? Colors.black.withOpacity(0.3)
                : AppColors.cardShadowLight,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Personal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeController.isDarkMode.value
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: controller.user.value?.email ?? '-',
            themeController: themeController,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'No. HP',
            value: controller.user.value?.noHp ?? '-',
            themeController: themeController,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal Masuk',
            value: controller.user.value?.tanggalMasuk != null
                ? _formatDate(controller.user.value!.tanggalMasuk!)
                : '-',
            themeController: themeController,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: controller.user.value?.alamat ?? '-',
            themeController: themeController,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeController themeController) {
    return Column(
      children: [
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
            onPressed: controller.showEditProfileModal,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            label: const Text(
              'Edit Profil',
              style: TextStyle(
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
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.confirmLogout,
            icon: const Icon(Icons.logout_outlined, color: AppColors.error),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: AppColors.error, width: 2),
              backgroundColor: AppColors.error.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeController themeController,
    bool isMultiLine = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? AppColors.slate800.withOpacity(0.5)
            : AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeController.isDarkMode.value
              ? AppColors.slate700
              : AppColors.slate200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeController.isDarkMode.value
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: themeController.isDarkMode.value
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
