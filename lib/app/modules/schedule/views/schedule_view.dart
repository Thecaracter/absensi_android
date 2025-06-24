import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sistem_presensi/app/controller/theme_controller.dart';
import 'package:sistem_presensi/app/data/models/schedule_model.dart';
import 'package:sistem_presensi/app/utils/color_constant.dart';

import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => Scaffold(
          backgroundColor: themeController.isDark
              ? AppColors.background
              : AppColors.backgroundLightMode,
          appBar: _buildAppBar(themeController.isDark),
          body: RefreshIndicator(
            onRefresh: controller.refreshData,
            color: AppColors.primary,
            backgroundColor: themeController.isDark
                ? AppColors.surface
                : AppColors.surfaceLightMode,
            child: Column(
              children: [
                _buildViewToggle(themeController.isDark),
                _buildPeriodNavigation(themeController.isDark),
                _buildStatistics(themeController.isDark),
                Expanded(
                  child: Obx(() => controller.isMonthlyView.value
                      ? _buildMonthlyCalendar(themeController.isDark)
                      : _buildWeeklyCalendar(themeController.isDark)),
                ),
              ],
            ),
          ),
        ));
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: Text(
        'Jadwal Kerja',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimary : Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      iconTheme: IconThemeData(
        color: isDark ? AppColors.textPrimary : Colors.white,
      ),
      actions: [
        IconButton(
          onPressed: controller.refreshData,
          icon: Obx(() =>
              controller.isLoading.value || controller.isLoadingWeekly.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? AppColors.textPrimary : Colors.white,
                      ),
                    )
                  : Icon(Icons.refresh,
                      color: isDark ? AppColors.textPrimary : Colors.white)),
        ),
      ],
    );
  }

  Widget _buildViewToggle(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceLight : AppColors.slate200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: controller.switchToMonthlyView,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.isMonthlyView.value
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Bulanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: controller.isMonthlyView.value
                            ? (isDark ? AppColors.background : Colors.white)
                            : (isDark
                                ? AppColors.textSecondary
                                : AppColors.slate600),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: controller.switchToWeeklyView,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !controller.isMonthlyView.value
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Mingguan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !controller.isMonthlyView.value
                            ? (isDark ? AppColors.background : Colors.white)
                            : (isDark
                                ? AppColors.textSecondary
                                : AppColors.slate600),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildPeriodNavigation(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => controller.isMonthlyView.value
                ? controller.goToPreviousMonth()
                : controller.goToPreviousWeek(),
            icon: Icon(
              Icons.chevron_left,
              size: 30,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.isMonthlyView.value
                  ? controller.goToCurrentMonth()
                  : controller.goToCurrentWeek(),
              child: Obx(() => Text(
                    controller.formattedCurrentPeriod,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                    ),
                  )),
            ),
          ),
          IconButton(
            onPressed: () => controller.isMonthlyView.value
                ? controller.goToNextMonth()
                : controller.goToNextWeek(),
            icon: Icon(
              Icons.chevron_right,
              size: 30,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(bool isDark) {
    return Obx(() {
      final stats = controller.quickStats;
      if (stats.isEmpty) return const SizedBox();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.cardShadow : AppColors.cardShadowLight,
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Hadir', stats['hadir']?.toString() ?? '0',
                AppColors.success, isDark),
            _buildStatItem('Terlambat', stats['terlambat']?.toString() ?? '0',
                AppColors.warning, isDark),
            _buildStatItem(
                'Tidak Hadir',
                stats['tidak_hadir']?.toString() ?? '0',
                AppColors.error,
                isDark),
            _buildStatItem('Izin', stats['izin']?.toString() ?? '0',
                AppColors.primaryLight, isDark),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyCalendar(bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.monthlyCalendar.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 64,
                color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada jadwal',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildCalendarHeader(isDark),
            Expanded(
              child: _buildCalendarGrid(isDark),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendarHeader(bool isDark) {
    const dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: dayNames
            .map((day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: controller.monthlyCalendar.length,
      itemBuilder: (context, index) {
        final day = controller.monthlyCalendar[index];
        return _buildCalendarDay(day, isDark);
      },
    );
  }

  Widget _buildCalendarDay(CalendarDay day, bool isDark) {
    return GestureDetector(
      onTap: () => _showDayDetail(day, isDark),
      child: Container(
        decoration: BoxDecoration(
          color: _getDayBackgroundColor(day, isDark),
          borderRadius: BorderRadius.circular(8),
          border: day.isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500,
                color: _getDayTextColor(day, isDark),
              ),
            ),
            if (day.hasSchedule) ...[
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: day.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar(bool isDark) {
    return Obx(() {
      if (controller.isLoadingWeekly.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.weeklyCalendar.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.view_week,
                size: 64,
                color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada jadwal minggu ini',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.weeklyCalendar.length,
        itemBuilder: (context, index) {
          final day = controller.weeklyCalendar[index];
          return _buildWeeklyDayCard(day, isDark);
        },
      );
    });
  }

  Widget _buildWeeklyDayCard(CalendarDay day, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(12),
        border:
            day.isToday ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.cardShadow : AppColors.cardShadowLight,
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.dayNameId,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: day.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: day.statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  day.statusText,
                  style: TextStyle(
                    color: day.statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (day.hasSchedule && day.shift != null) ...[
            const SizedBox(height: 12),
            _buildShiftInfo(day, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftInfo(CalendarDay day, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              'Shift: ${day.shift!.nama}',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              day.shift!.jamKerja,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        if (day.jamMasukActual != null || day.jamKeluarActual != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeInfo('Masuk', day.jamMasukActual ?? '-', isDark),
              _buildTimeInfo('Keluar', day.jamKeluarActual ?? '-', isDark),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimeInfo(String label, String time, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Color _getDayBackgroundColor(CalendarDay day, bool isDark) {
    if (day.isWeekend) {
      return isDark ? AppColors.surfaceLight : AppColors.slate200;
    }
    if (!day.hasSchedule) {
      return isDark ? AppColors.backgroundLight : AppColors.slate100;
    }
    return day.statusColor.withOpacity(0.1);
  }

  Color _getDayTextColor(CalendarDay day, bool isDark) {
    if (day.isWeekend) {
      return isDark ? AppColors.textMuted : AppColors.textMutedLight;
    }
    if (!day.hasSchedule) {
      return isDark ? AppColors.textMuted : AppColors.textMutedLight;
    }
    return isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
  }

  void _showDayDetail(CalendarDay day, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${day.dayNameId}, ${day.day}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: day.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: day.statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    day.statusText,
                    style: TextStyle(
                      color: day.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (day.hasSchedule && day.shift != null) ...[
              _buildDetailRow('Shift', day.shift!.nama, isDark),
              _buildDetailRow('Jam Kerja', day.shift!.jamKerja, isDark),
              if (day.jamMasukActual != null)
                _buildDetailRow(
                    'Jam Masuk Aktual', day.jamMasukActual!, isDark),
              if (day.jamKeluarActual != null)
                _buildDetailRow(
                    'Jam Keluar Aktual', day.jamKeluarActual!, isDark),
              if (day.menitTerlambat > 0)
                _buildDetailRow(
                    'Terlambat', '${day.menitTerlambat} menit', isDark),
              if (day.durasiKerja != null)
                _buildDetailRow('Durasi Kerja', day.durasiKerja!, isDark),
            ] else ...[
              Center(
                child: Text(
                  day.isWeekend ? 'Hari Libur' : 'Tidak Ada Jadwal',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
