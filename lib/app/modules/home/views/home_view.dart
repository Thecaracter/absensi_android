import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sistem_presensi/app/controller/theme_controller.dart';
import 'package:sistem_presensi/app/utils/color_constant.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    Get.put(HomeController());
    return Scaffold(
      backgroundColor: themeController.isDark
          ? AppColors.background
          : AppColors.backgroundLightMode,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingView();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorView();
          }

          return RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            color: AppColors.primary,
            backgroundColor: themeController.isDark
                ? AppColors.surface
                : AppColors.surfaceLightMode,
            child: CustomScrollView(
              slivers: [
                _buildHeaderSliver(themeController),
                _buildQuickActionsSection(themeController),
                _buildTodayAttendanceSection(themeController),
                _buildEnhancedStatisticsSection(themeController),
                _buildRecentAttendanceSection(themeController),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Memuat dashboard...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.loadDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSliver(ThemeController themeController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: themeController.isDark
              ? AppColors.primaryGradient
              : AppColors.primaryGradientLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryShadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: controller.showProfileBottomSheet,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: controller.userPhotoUrl != null
                      ? NetworkImage(controller.userPhotoUrl!)
                      : null,
                  child: controller.userPhotoUrl == null
                      ? Text(
                          controller.userName.isNotEmpty
                              ? controller.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.greetingMessage,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${controller.userIdKaryawan}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                controller.showProfileBottomSheet();
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeController themeController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksi Cepat',
              style: TextStyle(
                color: themeController.isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.login,
                    title: 'Check In',
                    subtitle: 'Masuk kerja',
                    color: Colors.green,
                    enabled: controller.canCheckIn,
                    onTap: () => controller.performQuickAction('check_in'),
                    themeController: themeController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.logout,
                    title: 'Check Out',
                    subtitle: 'Pulang kerja',
                    color: Colors.blue,
                    enabled: controller.canCheckOut,
                    onTap: () => controller.performQuickAction('check_out'),
                    themeController: themeController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.event_note,
                    title: 'Ajukan Izin',
                    subtitle: 'Buat izin baru',
                    color: Colors.orange,
                    enabled: controller.canRequestLeave,
                    onTap: () => controller.performQuickAction('leave_request'),
                    themeController: themeController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.history,
                    title: 'Riwayat',
                    subtitle: 'Lihat absensi',
                    color: Colors.purple,
                    enabled: true,
                    onTap: () =>
                        controller.performQuickAction('attendance_history'),
                    themeController: themeController,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
    required ThemeController themeController,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeController.isDark
              ? AppColors.surface
              : AppColors.surfaceLightMode,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? color.withOpacity(0.3)
                : (themeController.isDark
                    ? AppColors.border
                    : AppColors.borderLight),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: enabled
                    ? color.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: enabled ? color : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: enabled
                    ? (themeController.isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight)
                    : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled
                    ? (themeController.isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight)
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayAttendanceSection(ThemeController themeController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeController.isDark
              ? AppColors.surface
              : AppColors.surfaceLightMode,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeController.isDark
                ? AppColors.border
                : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  controller.attendanceStatusIcon,
                  color: controller.attendanceStatusColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Absensi Hari Ini',
                  style: TextStyle(
                    color: themeController.isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: controller.attendanceStatusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.attendanceStatusText,
                    style: TextStyle(
                      color: controller.attendanceStatusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.shiftInfo,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeCard(
                    title: 'Masuk',
                    time: controller.todayCheckInTime,
                    icon: Icons.login,
                    color: Colors.green,
                    themeController: themeController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeCard(
                    title: 'Keluar',
                    time: controller.todayCheckOutTime,
                    icon: Icons.logout,
                    color: Colors.blue,
                    themeController: themeController,
                  ),
                ),
              ],
            ),
            if (controller.lateMinutesText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.lateMinutesText,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
    required ThemeController themeController,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: themeController.isDark
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatisticsSection(ThemeController themeController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Bulan Ini',
              style: TextStyle(
                color: themeController.isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeController.isDark
                    ? AppColors.surface
                    : AppColors.surfaceLightMode,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeController.isDark
                      ? AppColors.border
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pie_chart_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tingkat Kehadiran',
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: controller.totalWorkDays > 0
                                ? controller.totalPresent /
                                    controller.totalWorkDays
                                : 0.0,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getAttendanceRateColor(
                                  controller.attendanceRate),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.attendanceRate,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _getAttendanceRateColor(
                                    controller.attendanceRate),
                              ),
                            ),
                            Text(
                              'Kehadiran',
                              style: TextStyle(
                                fontSize: 12,
                                color: themeController.isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(
                        'Hadir',
                        '${controller.totalPresent}',
                        Colors.green,
                        themeController,
                      ),
                      _buildLegendItem(
                        'Terlambat',
                        '${controller.totalLate}',
                        Colors.orange,
                        themeController,
                      ),
                      _buildLegendItem(
                        'Total Hari',
                        '${controller.totalWorkDays}',
                        Colors.blue,
                        themeController,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedStatCard(
                    title: 'Sisa Cuti',
                    value: '${controller.remainingLeaveQuota}',
                    totalValue: '${controller.totalLeaveQuota}',
                    icon: Icons.event_note,
                    color: Colors.purple,
                    progress: controller.totalLeaveQuota > 0
                        ? controller.remainingLeaveQuota /
                            controller.totalLeaveQuota
                        : 0.0,
                    themeController: themeController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEnhancedStatCard(
                    title: 'Izin Pending',
                    value: '${controller.pendingLeaveRequests}',
                    totalValue: '',
                    icon: Icons.pending_actions,
                    color: Colors.amber,
                    progress: null,
                    themeController: themeController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeController.isDark
                    ? AppColors.surface
                    : AppColors.surfaceLightMode,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeController.isDark
                      ? AppColors.border
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kehadiran 7 Hari Terakhir',
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: controller.recentAttendances.map((attendance) {
                        return _buildAttendanceBar(
                          day: controller.getDayAbbreviation(attendance.hari),
                          status: attendance.statusAbsen,
                          themeController: themeController,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    String value,
    Color color,
    ThemeController themeController,
  ) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeController.isDark
                ? AppColors.textPrimary
                : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: themeController.isDark
                ? AppColors.textSecondary
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard({
    required String title,
    required String value,
    required String totalValue,
    required IconData icon,
    required Color color,
    required double? progress,
    required ThemeController themeController,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDark
            ? AppColors.surface
            : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                totalValue.isNotEmpty ? '$value/$totalValue' : value,
                style: TextStyle(
                  color: themeController.isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (progress != null) ...[
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: TextStyle(
              color: themeController.isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBar({
    required String day,
    required String? status,
    required ThemeController themeController,
  }) {
    final Color barColor = controller.getStatusColor(status);
    final double height = status == null ? 20 : 80;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: barColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: barColor,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: themeController.isDark
                ? AppColors.textSecondary
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Color _getAttendanceRateColor(String rate) {
    final percentage = double.tryParse(rate.replaceAll('%', '')) ?? 0;
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.orange;
    return Colors.red;
  }

  Widget _buildRecentAttendanceSection(ThemeController themeController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat 7 Hari Terakhir',
              style: TextStyle(
                color: themeController.isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeController.isDark
                    ? AppColors.surface
                    : AppColors.surfaceLightMode,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeController.isDark
                      ? AppColors.border
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: controller.recentAttendances.map((attendance) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: controller
                                .getStatusColor(attendance.statusAbsen)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            controller.getStatusIcon(attendance.statusAbsen),
                            color: controller
                                .getStatusColor(attendance.statusAbsen),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attendance.tanggal,
                                style: TextStyle(
                                  color: themeController.isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                controller
                                    .getStatusText(attendance.statusAbsen),
                                style: TextStyle(
                                  color: controller
                                      .getStatusColor(attendance.statusAbsen),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (attendance.jamMasuk != null) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                controller.formatTime(attendance.jamMasuk),
                                style: TextStyle(
                                  color: themeController.isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (attendance.jamKeluar != null)
                                Text(
                                  controller.formatTime(attendance.jamKeluar),
                                  style: TextStyle(
                                    color: themeController.isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
