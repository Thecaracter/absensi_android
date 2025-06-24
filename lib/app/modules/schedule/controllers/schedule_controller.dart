// lib/app/modules/schedule/controllers/schedule_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:sistem_presensi/app/data/models/schedule_model.dart';
import 'package:sistem_presensi/app/utils/api_constant.dart';

class ScheduleController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isLoadingWeekly = false.obs;
  final currentMonth = DateTime.now().month.obs;
  final currentYear = DateTime.now().year.obs;
  final selectedDate = DateTime.now().obs;

  // Data observables
  final monthlyCalendar = <CalendarDay>[].obs;
  final weeklyCalendar = <CalendarDay>[].obs;
  final monthlyStats = Rx<ScheduleStatistics?>(null);
  final weeklyStats = Rx<ScheduleStatistics?>(null);
  final periodInfo = Rx<PeriodInfo?>(null);

  // View mode
  final isMonthlyView = true.obs;

  // Error handling
  final errorMessage = ''.obs;
  final hasError = false.obs;

  // Storage
  SharedPreferences? _prefs;
  final Duration timeoutDuration = const Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  // Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadMonthlySchedule();
  }

  // Get Authorization Headers
  Map<String, String> get _authHeaders {
    final token = _prefs?.getString('auth_token') ?? '';
    return ApiConstant.headersWithAuth(token);
  }

  // Load Monthly Schedule
  Future<void> loadMonthlySchedule({int? year, int? month}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final targetYear = year ?? currentYear.value;
      final targetMonth = month ?? currentMonth.value;

      // Build URL with query parameters
      final uri = Uri.parse(ApiConstant.scheduleMonthly).replace(
        queryParameters: {
          'year': targetYear.toString(),
          'month': targetMonth.toString(),
        },
      );

      print('📅 Loading Monthly Schedule: $uri');

      final response =
          await http.get(uri, headers: _authHeaders).timeout(timeoutDuration);

      print('📅 Response Status: ${response.statusCode}');
      print('📅 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final scheduleResponse = ScheduleResponse.fromJson(jsonData);

        if (scheduleResponse.success) {
          monthlyCalendar.value = scheduleResponse.data.calendar;
          monthlyStats.value = scheduleResponse.data.statistics;
          periodInfo.value = scheduleResponse.data.period;

          // Update current month/year
          currentMonth.value = targetMonth;
          currentYear.value = targetYear;

          print('📅 Monthly Schedule Loaded: ${monthlyCalendar.length} days');
        } else {
          _setError(scheduleResponse.message);
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _setError('Gagal memuat jadwal: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Monthly Schedule Error: $e');
      _setError('Gagal memuat jadwal bulanan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load Weekly Schedule
  Future<void> loadWeeklySchedule({DateTime? startDate}) async {
    try {
      isLoadingWeekly.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final targetDate = startDate ?? selectedDate.value;
      final formattedDate = targetDate.toIso8601String().split('T')[0];

      // Build URL with query parameters
      final uri = Uri.parse(ApiConstant.scheduleWeekly).replace(
        queryParameters: {
          'start_date': formattedDate,
        },
      );

      print('📅 Loading Weekly Schedule: $uri');

      final response =
          await http.get(uri, headers: _authHeaders).timeout(timeoutDuration);

      print('📅 Weekly Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final scheduleResponse = ScheduleResponse.fromJson(jsonData);

        if (scheduleResponse.success) {
          weeklyCalendar.value = scheduleResponse.data.calendar;
          weeklyStats.value = scheduleResponse.data.statistics;

          // Update selected date
          selectedDate.value = targetDate;

          print('📅 Weekly Schedule Loaded: ${weeklyCalendar.length} days');
        } else {
          _setError(scheduleResponse.message);
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _setError('Gagal memuat jadwal mingguan: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Weekly Schedule Error: $e');
      _setError('Gagal memuat jadwal mingguan: ${e.toString()}');
    } finally {
      isLoadingWeekly.value = false;
    }
  }

  // Navigation methods
  void goToPreviousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value = currentYear.value - 1;
    } else {
      currentMonth.value = currentMonth.value - 1;
    }
    loadMonthlySchedule(year: currentYear.value, month: currentMonth.value);
  }

  void goToNextMonth() {
    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value = currentYear.value + 1;
    } else {
      currentMonth.value = currentMonth.value + 1;
    }
    loadMonthlySchedule(year: currentYear.value, month: currentMonth.value);
  }

  void goToCurrentMonth() {
    final now = DateTime.now();
    currentMonth.value = now.month;
    currentYear.value = now.year;
    loadMonthlySchedule(year: currentYear.value, month: currentMonth.value);
  }

  // Weekly navigation
  void goToPreviousWeek() {
    final newDate = selectedDate.value.subtract(const Duration(days: 7));
    selectedDate.value = newDate;
    loadWeeklySchedule(startDate: newDate);
  }

  void goToNextWeek() {
    final newDate = selectedDate.value.add(const Duration(days: 7));
    selectedDate.value = newDate;
    loadWeeklySchedule(startDate: newDate);
  }

  void goToCurrentWeek() {
    selectedDate.value = DateTime.now();
    loadWeeklySchedule(startDate: DateTime.now());
  }

  // Switch view mode
  void switchToMonthlyView() {
    isMonthlyView.value = true;
    if (monthlyCalendar.isEmpty) {
      loadMonthlySchedule();
    }
  }

  void switchToWeeklyView() {
    isMonthlyView.value = false;
    if (weeklyCalendar.isEmpty) {
      loadWeeklySchedule();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    print('🔄 Refreshing schedule data...');
    if (isMonthlyView.value) {
      await loadMonthlySchedule(
          year: currentYear.value, month: currentMonth.value);
    } else {
      await loadWeeklySchedule(startDate: selectedDate.value);
    }
  }

  // Get calendar day by date
  CalendarDay? getDayByDate(String date) {
    final calendar = isMonthlyView.value ? monthlyCalendar : weeklyCalendar;
    try {
      return calendar.firstWhere((day) => day.date == date);
    } catch (e) {
      return null;
    }
  }

  // Get today's schedule
  CalendarDay? getTodaySchedule() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return getDayByDate(today);
  }

  // Helper untuk format periode
  String get currentPeriodText {
    if (isMonthlyView.value) {
      return periodInfo.value?.periodTextId ?? 'Loading...';
    } else {
      return periodInfo.value?.weekText ?? 'Loading...';
    }
  }

  // Helper untuk statistik ringkas
  Map<String, dynamic> get quickStats {
    final stats = isMonthlyView.value ? monthlyStats.value : weeklyStats.value;
    if (stats == null) return {};

    return {
      'hadir': stats.totalHadir,
      'terlambat': stats.totalTerlambat,
      'tidak_hadir': stats.totalTidakHadir,
      'izin': stats.totalIzin,
      'tingkat_kehadiran': stats.tingkatKehadiran,
    };
  }

  // Filter calendar by status
  List<CalendarDay> getCalendarByStatus(String status) {
    final calendar = isMonthlyView.value ? monthlyCalendar : weeklyCalendar;
    return calendar.where((day) => day.statusAbsen == status).toList();
  }

  // Get working days
  List<CalendarDay> get workingDays {
    final calendar = isMonthlyView.value ? monthlyCalendar : weeklyCalendar;
    return calendar.where((day) => day.hasSchedule).toList();
  }

  // Get weekend days
  List<CalendarDay> get weekendDays {
    final calendar = isMonthlyView.value ? monthlyCalendar : weeklyCalendar;
    return calendar.where((day) => day.isWeekend).toList();
  }

  // Get month name in Indonesian
  String getMonthName(int month) {
    const months = [
      '',
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
    return months[month];
  }

  // Get formatted current period
  String get formattedCurrentPeriod {
    if (isMonthlyView.value) {
      return '${getMonthName(currentMonth.value)} ${currentYear.value}';
    } else {
      return periodInfo.value?.weekText ?? 'Loading...';
    }
  }

  // Error handling
  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _handleUnauthorized() async {
    await _prefs?.remove('auth_token');
    await _prefs?.remove('user_data');
    Get.offAllNamed('/login');
    Get.snackbar(
      'Session Expired',
      'Silakan login kembali',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
    );
  }

  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    // Cleanup if needed
    super.onClose();
  }
}
