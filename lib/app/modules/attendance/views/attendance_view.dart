import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sistem_presensi/app/controller/theme_controller.dart';
import 'package:sistem_presensi/app/utils/color_constant.dart';
import '../controllers/attendance_controller.dart';

class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final AttendanceController controller =
        Get.put(AttendanceController(), permanent: true);
    MaterialColor _getTimeValidationColor() {
      if (controller.canCheckInNow() || controller.canCheckOutNow()) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }

    return Obx(() => Scaffold(
          backgroundColor: themeController.isDark
              ? AppColors.background
              : AppColors.backgroundLightMode,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Absensi',
              style: TextStyle(
                color: themeController.isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [],
          ),
          body: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.forceRefreshAttendance,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card with Date and Time
                        _buildHeaderCard(themeController),
                        const SizedBox(height: 20),

                        // Real-time Location Status Card
                        _buildLocationStatusCard(themeController),
                        const SizedBox(height: 20),

                        // Enhanced Shift Info Card with Time Windows
                        _buildEnhancedShiftInfoCard(themeController),
                        const SizedBox(height: 20),

                        // Attendance Status Card
                        _buildAttendanceStatusCard(themeController),
                        const SizedBox(height: 20),

                        // Photo Preview Card
                        if (controller.selectedImage.value != null) ...[
                          _buildPhotoPreviewCard(themeController),
                          const SizedBox(height: 20),
                        ],

                        // Enhanced Action Buttons
                        _buildEnhancedActionButtons(themeController),
                      ],
                    ),
                  ),
                ),
        ));
  }

  Widget _buildHeaderCard(ThemeController themeController) {
    final now = DateTime.now();
    final dateText =
        '${_getDay(now.weekday)}, ${now.day} ${_getMonth(now.month)} ${now.year}';
    final timeText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: themeController.isDark
            ? AppColors.primaryGradient
            : AppColors.primaryGradientLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeController.isDark
                ? AppColors.buttonShadow
                : AppColors.buttonShadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            timeText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard(ThemeController themeController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDark
            ? AppColors.surface
            : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.locationStatusColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeController.isDark
                ? AppColors.cardShadow
                : AppColors.cardShadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: controller.locationStatusColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isLocationValid.value
                          ? Icons.gps_fixed
                          : controller.locationError.value.isNotEmpty
                              ? Icons.gps_off
                              : Icons.gps_not_fixed,
                      color: Colors.white,
                      size: 20,
                    ),
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Lokasi',
                      style: TextStyle(
                        color: themeController.isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          controller.locationStatusText,
                          style: TextStyle(
                            color: controller.locationStatusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ],
                ),
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: controller.isAutoTrackingActive.value
                          ? Colors.green
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isAutoTrackingActive.value
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: Colors.white,
                      size: 12,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
                controller.currentLocationText,
                style: TextStyle(
                  color: themeController.isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              )),
          const SizedBox(height: 12),
          // Enhanced action buttons
          Obx(() {
            if (controller.locationError.value.isNotEmpty) {
              return _buildLocationErrorActions();
            } else if (!controller.isAutoTrackingActive.value) {
              return _buildStartTrackingButton();
            } else {
              return _buildLocationInfoButton();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildLocationErrorActions() {
    return Column(
      children: [
        Row(
          children: [
            if (controller.locationError.value.contains('GPS tidak aktif'))
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.openLocationSettings,
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Aktifkan GPS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            if (controller.locationError.value.contains('Izin lokasi'))
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.openAppSettings,
                  icon: const Icon(Icons.security, size: 16),
                  label: const Text('Izin Lokasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.isGettingLocation.value
                ? null
                : controller.refreshLocation,
            icon: controller.isGettingLocation.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh, size: 16),
            label: Text(controller.isGettingLocation.value
                ? 'Mencoba lagi...'
                : 'Coba Lagi GPS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartTrackingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.forceStartLocationTracking,
        icon: const Icon(Icons.play_arrow, size: 16),
        label: const Text('Start GPS Tracking'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildLocationInfoButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.showOfficeLocationsDialog,
        icon: const Icon(Icons.business, size: 16),
        label: const Text('Info Lokasi Kantor'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  // Enhanced Shift Info Card with Time Windows
  Widget _buildEnhancedShiftInfoCard(ThemeController themeController) {
    final shift = controller.attendanceData.value?.shift;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDark
            ? AppColors.surface
            : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeController.isDark ? AppColors.border : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: themeController.isDark
                ? AppColors.cardShadow
                : AppColors.cardShadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Shift Kerja',
                    style: TextStyle(
                      color: themeController.isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Info button for detailed shift info
              IconButton(
                onPressed: controller.showShiftInfoDialog,
                icon: Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (shift != null) ...[
            // Basic shift info
            Row(
              children: [
                Expanded(
                  child: _buildShiftInfoRow(
                    'Nama Shift:',
                    shift.nama.isNotEmpty ? shift.nama : 'Tidak diketahui',
                    themeController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildShiftInfoRow(
                    'Jam Kerja:',
                    '${shift.jamMasuk} - ${shift.jamKeluar}',
                    themeController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildShiftInfoRow(
                    'Toleransi:',
                    '${shift.toleransiMenit} menit',
                    themeController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Time validation status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getTimeValidationColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getTimeValidationColor().withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTimeValidationIcon(),
                        color: _getTimeValidationColor(),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status Waktu Absensi',
                        style: TextStyle(
                          color: _getTimeValidationColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTimeValidationMessage(),
                    style: TextStyle(
                      color: _getTimeValidationColor().withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  if (!controller.canCheckInNow() &&
                      !controller.canCheckOutNow()) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Jam absensi yang diizinkan:\n'
                      '${controller.getCheckInTimeInfo()}\n'
                      '${controller.getCheckOutTimeInfo()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data shift tidak tersedia',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tekan tombol Sync di atas untuk memperbarui data',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for time validation UI
  Color _getTimeValidationColor() {
    if (controller.canCheckInNow() || controller.canCheckOutNow()) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  IconData _getTimeValidationIcon() {
    if (controller.canCheckInNow() || controller.canCheckOutNow()) {
      return Icons.check_circle;
    } else {
      return Icons.access_time;
    }
  }

  String _getTimeValidationMessage() {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    if (controller.canCheckInNow() && controller.canCheckOutNow()) {
      return 'Waktu sekarang ($currentTime) - Bisa check-in atau check-out';
    } else if (controller.canCheckInNow()) {
      return 'Waktu sekarang ($currentTime) - Bisa check-in';
    } else if (controller.canCheckOutNow()) {
      return 'Waktu sekarang ($currentTime) - Bisa check-out';
    } else {
      return 'Waktu sekarang ($currentTime) - Belum waktu absensi';
    }
  }

  Widget _buildShiftInfoRow(
      String label, String value, ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: themeController.isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: themeController.isDark
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatusCard(ThemeController themeController) {
    final attendance = controller.attendanceData.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDark
            ? AppColors.surface
            : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeController.isDark ? AppColors.border : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: themeController.isDark
                ? AppColors.cardShadow
                : AppColors.cardShadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Status Absensi',
                style: TextStyle(
                  color: themeController.isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (attendance != null) ...[
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(attendance.statusAbsen),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    attendance.statusAbsenText ??
                        controller.getStatusText(attendance.statusAbsen),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (attendance.menitTerlambat != null &&
                    attendance.menitTerlambat! > 0)
                  Text(
                    attendance.terlambatText ??
                        'Terlambat ${attendance.menitTerlambat} menit',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check In',
                        style: TextStyle(
                          color: themeController.isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSafeTimeText(
                            attendance.jamMasukFormatted, attendance.jamMasuk),
                        style: TextStyle(
                          color: themeController.isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        attendance.sudahCheckIn ? "✓ Selesai" : "Belum",
                        style: TextStyle(
                          color: attendance.sudahCheckIn
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check Out',
                        style: TextStyle(
                          color: themeController.isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSafeTimeText(attendance.jamKeluarFormatted,
                            attendance.jamKeluar),
                        style: TextStyle(
                          color: themeController.isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        attendance.sudahCheckOut ? "✓ Selesai" : "Belum",
                        style: TextStyle(
                          color: attendance.sudahCheckOut
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belum ada data absensi hari ini',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jika sudah absen tapi data belum muncul, tekan tombol Sync di pojok kanan atas.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoPreviewCard(ThemeController themeController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDark
            ? AppColors.surface
            : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeController.isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Foto Terpilih',
                style: TextStyle(
                  color: themeController.isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () => controller.selectedImage.value = null,
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              controller.selectedImage.value!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Action Buttons with better validation and styling
  Widget _buildEnhancedActionButtons(ThemeController themeController) {
    final attendance = controller.attendanceData.value;
    final canCheckIn = attendance == null || !attendance.sudahCheckIn;
    final canCheckOut = attendance != null && attendance.dapatCheckOut;

    return Column(
      children: [
        // Photo Button
        Container(
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton.icon(
            onPressed: controller.showImagePickerDialog,
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              controller.selectedImage.value == null
                  ? 'Ambil Foto'
                  : 'Ganti Foto',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),

        // Check In Button
        if (canCheckIn)
          Container(
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.only(bottom: 12),
            child: Obx(() => ElevatedButton.icon(
                  onPressed:
                      _getCheckInButtonEnabled() ? controller.checkIn : null,
                  icon: controller.isCheckingIn.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.login, color: Colors.white),
                            if (_needsWarningIcon(isCheckIn: true)) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.warning,
                                  color: Colors.white, size: 16),
                            ],
                          ],
                        ),
                  label: Text(
                    _getCheckInButtonText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCheckInButtonColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                )),
          ),

        // Check Out Button
        if (canCheckOut)
          Container(
            width: double.infinity,
            height: 56,
            child: Obx(() => ElevatedButton.icon(
                  onPressed:
                      _getCheckOutButtonEnabled() ? controller.checkOut : null,
                  icon: controller.isCheckingOut.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.logout, color: Colors.white),
                            if (_needsWarningIcon(isCheckIn: false)) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.warning,
                                  color: Colors.white, size: 16),
                            ],
                          ],
                        ),
                  label: Text(
                    _getCheckOutButtonText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCheckOutButtonColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                )),
          ),
      ],
    );
  }

  // Enhanced helper methods for button states
  bool _getCheckInButtonEnabled() {
    return !controller.isCheckingIn.value &&
        controller.selectedImage.value != null &&
        controller.isGpsReady;
  }

  bool _getCheckOutButtonEnabled() {
    return !controller.isCheckingOut.value &&
        controller.selectedImage.value != null &&
        controller.isGpsReady;
  }

  bool _needsWarningIcon({required bool isCheckIn}) {
    if (!controller.isGpsReady || controller.selectedImage.value == null) {
      return false;
    }

    // Show warning if location invalid OR time invalid
    final locationInvalid =
        !controller.isLocationValid.value && controller.isGpsReady;
    final timeInvalid =
        isCheckIn ? !controller.canCheckInNow() : !controller.canCheckOutNow();

    return locationInvalid || timeInvalid;
  }

  String _getCheckInButtonText() {
    if (controller.isCheckingIn.value) return 'Memproses...';
    if (!controller.isGpsReady) return 'Menunggu GPS...';
    if (controller.selectedImage.value == null) return 'Pilih Foto Dulu';
    if (!controller.canCheckInNow()) return 'Belum Waktunya';
    if (!controller.isLocationValid.value) return 'Check In (Di Luar Area)';
    return 'Check In';
  }

  String _getCheckOutButtonText() {
    if (controller.isCheckingOut.value) return 'Memproses...';
    if (!controller.isGpsReady) return 'Menunggu GPS...';
    if (controller.selectedImage.value == null) return 'Pilih Foto Dulu';
    if (!controller.canCheckOutNow()) return 'Belum Waktunya';
    if (!controller.isLocationValid.value) return 'Check Out (Di Luar Area)';
    return 'Check Out';
  }

  Color _getCheckInButtonColor() {
    if (!controller.isGpsReady || controller.selectedImage.value == null) {
      return Colors.grey;
    }
    if (!controller.canCheckInNow()) return Colors.orange;
    if (!controller.isLocationValid.value) return AppColors.warning;
    return AppColors.success;
  }

  Color _getCheckOutButtonColor() {
    if (!controller.isGpsReady || controller.selectedImage.value == null) {
      return Colors.grey;
    }
    if (!controller.canCheckOutNow()) return Colors.orange;
    if (!controller.isLocationValid.value) return AppColors.warning;
    return AppColors.error;
  }

  String _getSafeTimeText(String? formattedTime, String? rawTime) {
    if (formattedTime != null &&
        formattedTime.isNotEmpty &&
        formattedTime != 'null') {
      return formattedTime;
    }

    if (rawTime != null && rawTime.isNotEmpty && rawTime != 'null') {
      try {
        final parts = rawTime.split(':');
        if (parts.length >= 2) {
          return '${parts[0]}:${parts[1]}';
        }
        return rawTime;
      } catch (e) {
        return rawTime;
      }
    }

    return '-';
  }

  String _getDay(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }
}
