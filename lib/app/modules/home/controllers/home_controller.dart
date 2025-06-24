import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sistem_presensi/app/modules/BottomNavBar/controllers/bottom_nav_bar_controller.dart';
import 'package:sistem_presensi/app/utils/api_constant.dart';
import 'package:sistem_presensi/app/utils/color_constant.dart';
import '../../../data/models/dashboard_model.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var isLoading = true.obs;
  var dashboardData = Rxn<DashboardData>();
  var currentTime = ''.obs;
  var currentDate = ''.obs;
  var errorMessage = ''.obs;
  var isRefreshing = false.obs;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  String? _token;

  @override
  void onInit() async {
    super.onInit();

    await _loadToken();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    loadDashboard();
    updateCurrentTime();

    ever(currentTime, (_) => update());
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void updateCurrentTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('HH:mm').format(now);
    currentDate.value = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);

    final nextMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    final delay = nextMinute.difference(now);

    Future.delayed(delay, () {
      if (!isClosed) {
        updateCurrentTime();
      }
    });
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse(ApiConstant.dashboardHome),
        headers: ApiConstant.headersWithAuth(_token ?? ''),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        print("Raw API Response: $jsonData");

        final dashboardResponse = DashboardResponse.fromJson(jsonData);

        if (dashboardResponse.success) {
          dashboardData.value = dashboardResponse.data;
          animationController.forward();
        } else {
          errorMessage.value = dashboardResponse.message;
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Token expired. Please login again.';

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        Get.offAllNamed('/login');
      } else {
        final errorData = json.decode(response.body);
        errorMessage.value =
            errorData['message'] ?? 'Failed to load dashboard data';
      }
    } catch (e, stackTrace) {
      print("Parse Error: $e");
      print("Stack Trace: $stackTrace");
      errorMessage.value = 'Data parsing error: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Gagal memuat data dashboard: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;

      final response = await http.get(
        Uri.parse(ApiConstant.dashboardHome),
        headers: ApiConstant.headersWithAuth(_token ?? ''),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final dashboardResponse = DashboardResponse.fromJson(jsonData);

        if (dashboardResponse.success) {
          dashboardData.value = dashboardResponse.data;
          Get.snackbar(
            'Berhasil',
            'Data dashboard telah diperbarui',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        } else {
          errorMessage.value = dashboardResponse.message;
        }
      } else {
        final errorData = json.decode(response.body);
        errorMessage.value =
            errorData['message'] ?? 'Failed to refresh dashboard';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui data: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  void navigateSchedule() {
    Get.toNamed('/schedule');
  }

  void navigateToCheckIn() {
    if (Get.isRegistered<BottomNavBarController>()) {
      Get.find<BottomNavBarController>().changeIndex(1);
    }
  }

  void navigateToCheckOut() {
    if (Get.isRegistered<BottomNavBarController>()) {
      Get.find<BottomNavBarController>().changeIndex(1);
    }
  }

  void navigateToLeaveRequest() {
    if (Get.isRegistered<BottomNavBarController>()) {
      Get.find<BottomNavBarController>().changeIndex(2);
    }
  }

  void navigateToAttendanceHistory() {
    if (Get.isRegistered<BottomNavBarController>()) {
      Get.find<BottomNavBarController>().changeIndex(1);
    }
  }

  void navigateToProfile() {
    if (Get.isRegistered<BottomNavBarController>()) {
      Get.find<BottomNavBarController>().changeIndex(3);
    }
  }

  void navigateToLeaveHistory() {
    if (Get.isRegistered<BottomNavBarController>()) {
      Get.find<BottomNavBarController>().changeIndex(2);
    }
  }

  void handleNotificationAction(String action) {
    switch (action) {
      case 'check_in':
        navigateToCheckIn();
        break;
      case 'check_out':
        navigateToCheckOut();
        break;
      case 'view_leaves':
        navigateToLeaveHistory();
        break;
      default:
        break;
    }
  }

  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String get attendanceStatusText {
    final data = dashboardData.value;
    if (data == null) return 'Memuat...';

    final attendance = data.absensiHariIni;
    if (!attendance.sudahCheckIn) {
      return 'Belum Check In';
    } else if (!attendance.sudahCheckOut) {
      return 'Sudah Check In';
    } else {
      return 'Selesai';
    }
  }

  Color get attendanceStatusColor {
    final data = dashboardData.value;
    if (data == null) return Colors.grey;

    final attendance = data.absensiHariIni;
    if (!attendance.sudahCheckIn) {
      return Colors.orange;
    } else if (!attendance.sudahCheckOut) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  IconData get attendanceStatusIcon {
    final data = dashboardData.value;
    if (data == null) return Icons.timer;

    final attendance = data.absensiHariIni;
    if (!attendance.sudahCheckIn) {
      return Icons.login;
    } else if (!attendance.sudahCheckOut) {
      return Icons.logout;
    } else {
      return Icons.check_circle;
    }
  }

  void performQuickAction(String action) {
    switch (action) {
      case 'check_in':
        if (canCheckIn) {
          navigateToCheckIn();
        } else {
          Get.snackbar(
            'Info',
            'Anda sudah melakukan check-in hari ini',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
        break;
      case 'check_out':
        if (canCheckOut) {
          navigateToCheckOut();
        } else {
          Get.snackbar(
            'Info',
            'Anda belum check-in atau sudah check-out hari ini',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
        break;
      case 'leave_request':
        navigateToLeaveRequest();
        break;
      case 'attendance_history':
        navigateToAttendanceHistory();
        break;
      default:
        break;
    }
  }

  bool get canCheckIn {
    final data = dashboardData.value;
    if (data == null) return false;
    return data.quickActions.canCheckIn;
  }

  bool get canCheckOut {
    final data = dashboardData.value;
    if (data == null) return false;
    return data.quickActions.canCheckOut;
  }

  bool get canRequestLeave {
    final data = dashboardData.value;
    if (data == null) return false;
    return data.quickActions.canRequestLeave;
  }

  String get todayCheckInTime {
    final data = dashboardData.value;
    if (data == null) return '-';
    return data.absensiHariIni.jamMasuk ?? '-';
  }

  String get todayCheckOutTime {
    final data = dashboardData.value;
    if (data == null) return '-';
    return data.absensiHariIni.jamKeluar ?? '-';
  }

  String get shiftInfo {
    final data = dashboardData.value;
    if (data?.absensiHariIni.shift == null) return 'Tidak ada shift';

    final shift = data!.absensiHariIni.shift!;
    return '${shift.nama} (${shift.jamMasuk} - ${shift.jamKeluar})';
  }

  String get lateMinutesText {
    final data = dashboardData.value;
    if (data == null || data.absensiHariIni.menitTerlambat == 0) return '';
    return 'Terlambat ${data.absensiHariIni.menitTerlambat} menit';
  }

  String get attendanceRate {
    final data = dashboardData.value;
    if (data == null) return '0%';
    return '${data.statistikAbsensi.tingkatKehadiran.toStringAsFixed(1)}%';
  }

  int get totalWorkDays {
    final data = dashboardData.value;
    if (data == null) return 0;
    return data.statistikAbsensi.totalHariKerja;
  }

  int get totalPresent {
    final data = dashboardData.value;
    if (data == null) return 0;
    return data.statistikAbsensi.totalHadir;
  }

  int get totalLate {
    final data = dashboardData.value;
    if (data == null) return 0;
    return data.statistikAbsensi.totalTerlambat;
  }

  int get pendingLeaveRequests {
    final data = dashboardData.value;
    if (data == null) return 0;
    return data.statistikIzin.menungguApproval;
  }

  int get remainingLeaveQuota {
    final data = dashboardData.value;
    if (data == null) return 0;
    return data.statistikIzin.sisaKuota;
  }

  int get usedLeaveDays {
    final data = dashboardData.value;
    if (data == null) return 0;
    return data.statistikIzin.totalHariIzinTahunIni;
  }

  int get totalLeaveQuota {
    final data = dashboardData.value;
    if (data == null) return 0;
    return data.statistikIzin.kuotaCuti;
  }

  double get attendancePercentage {
    final data = dashboardData.value;
    if (data == null || data.statistikAbsensi.totalHariKerja == 0) return 0.0;
    return data.statistikAbsensi.tingkatKehadiran / 100.0;
  }

  double get leaveQuotaUsagePercentage {
    final data = dashboardData.value;
    if (data == null || data.statistikIzin.kuotaCuti == 0) return 0.0;
    return (data.statistikIzin.kuotaCuti - data.statistikIzin.sisaKuota) /
        data.statistikIzin.kuotaCuti;
  }

  List<Map<String, dynamic>> get weeklyAttendanceData {
    final data = dashboardData.value;
    if (data == null) return [];

    return data.riwayat7Hari.map((attendance) {
      return {
        'day': getDayAbbreviation(attendance.hari),
        'status': attendance.statusAbsen,
        'present': attendance.statusAbsen == 'hadir' ? 1 : 0,
        'late': attendance.statusAbsen == 'terlambat' ? 1 : 0,
        'absent': (attendance.statusAbsen == 'tidak_hadir' ||
                attendance.statusAbsen == null)
            ? 1
            : 0,
      };
    }).toList();
  }

  List<RecentAttendance> get recentAttendances {
    final data = dashboardData.value;
    if (data == null) return [];
    return data.riwayat7Hari;
  }

  List<NotificationItem> get notifications {
    final data = dashboardData.value;
    if (data == null) return [];
    return data.notifikasi;
  }

  String get userName {
    final data = dashboardData.value;
    if (data == null) return '';
    return data.user.name;
  }

  String get userIdKaryawan {
    final data = dashboardData.value;
    if (data == null) return '';
    return data.user.idKaryawan;
  }

  String? get userPhotoUrl {
    final data = dashboardData.value;
    if (data == null) return null;
    return data.user.fotoUrl;
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'terlambat':
        return Colors.orange;
      case 'tidak_hadir':
        return Colors.red;
      case 'izin':
        return Colors.blue;
      case 'sakit':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle;
      case 'terlambat':
        return Icons.access_time;
      case 'tidak_hadir':
        return Icons.cancel;
      case 'izin':
        return Icons.event_note;
      case 'sakit':
        return Icons.local_hospital;
      default:
        return Icons.help;
    }
  }

  String getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'terlambat':
        return 'Terlambat';
      case 'tidak_hadir':
        return 'Tidak Hadir';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      default:
        return 'Tidak Diketahui';
    }
  }

  Color getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'success':
        return Icons.check_circle;
      case 'info':
      default:
        return Icons.info;
    }
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '-';
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String getDayAbbreviation(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
      case 'senin':
        return 'Sen';
      case 'tuesday':
      case 'selasa':
        return 'Sel';
      case 'wednesday':
      case 'rabu':
        return 'Rab';
      case 'thursday':
      case 'kamis':
        return 'Kam';
      case 'friday':
      case 'jumat':
        return 'Jum';
      case 'saturday':
      case 'sabtu':
        return 'Sab';
      case 'sunday':
      case 'minggu':
        return 'Min';
      default:
        return day.substring(0, 3);
    }
  }

  List<Map<String, dynamic>> getAttendanceChartData() {
    final data = dashboardData.value;
    if (data == null) return [];

    final stats = data.statistikAbsensi;
    final absent = stats.totalHariKerja - stats.totalHadir;

    return [
      {
        'label': 'Hadir',
        'value': stats.totalHadir,
        'color': Colors.green,
      },
      {
        'label': 'Terlambat',
        'value': stats.totalTerlambat,
        'color': Colors.orange,
      },
      {
        'label': 'Tidak Hadir',
        'value': absent > 0 ? absent : 0,
        'color': Colors.red,
      },
    ];
  }

  double get workEfficiency {
    final data = dashboardData.value;
    if (data == null || data.statistikAbsensi.totalHariKerja == 0) return 0.0;

    final stats = data.statistikAbsensi;
    final onTimeAttendance = stats.totalHadir - stats.totalTerlambat;
    return onTimeAttendance / stats.totalHariKerja;
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.logout),
        headers: ApiConstant.headersWithAuth(_token ?? ''),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      Get.offAllNamed('/login');

      Get.snackbar(
        'Info',
        'Anda telah logout',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      Get.offAllNamed('/login');
    }
  }

  void showProfileBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // User Info Section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  backgroundImage:
                      userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                  child: userPhotoUrl == null
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: $userIdKaryawan',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 20),

            // Menu Items
            _buildProfileMenuItem(
              icon: Icons.person,
              title: 'Edit Profile',
              onTap: () {
                Get.back();
                navigateToProfile();
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.calendar_today,
              title: 'Jadwal',
              onTap: () {
                Get.back();
                navigateSchedule();
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.history,
              title: 'Riwayat Absensi',
              onTap: () {
                Get.back();
                navigateToAttendanceHistory();
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.event_note,
              title: 'Riwayat Izin',
              onTap: () {
                Get.back();
                navigateToLeaveHistory();
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Get.back();
                _showLogoutConfirmation();
              },
              isDestructive: true,
            ),

            // Safe area padding
            SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Apakah Anda yakin ingin logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
