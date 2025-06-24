class ApiConstant {
  static const String baseUrl = 'https://check.codingin-indonesia.my.id';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  static const String apiCheck = '$apiBaseUrl/test';

  // dashboard endpoints
  static const String dashboardHome = '$apiBaseUrl/dashboard/home';
  static const String dashboardSummary = '$apiBaseUrl/dashboard/summary';
  static const String dashboardQuickActions =
      '$apiBaseUrl/dashboard/quick-actions';

  // attendance history endpoints
  static const String attendanceHistory = '$apiBaseUrl/attendance/history';
  static const String attendanceMonthlyStats =
      '$apiBaseUrl/attendance/monthly-stats';

  // auth endpoints
  static const String login = '$apiBaseUrl/auth/login';
  static const String logout = '$apiBaseUrl/auth/logout';
  static const String me = '$apiBaseUrl/auth/me';

  // profile endpoints
  static const String profile = '$apiBaseUrl/profile';
  static const String updateProfile = '$apiBaseUrl/profile';

  // ✅ ENDPOINT KHUSUS UNTUK FOTO DAN DATA
  static const String updateProfilePhoto = '$apiBaseUrl/profile/photo';
  static const String updateProfileData = '$apiBaseUrl/profile/data';

  // attendance endpoints
  static const String todayAttendance = '$apiBaseUrl/attendance/today';
  static const String checkIn = '$apiBaseUrl/attendance/check-in';
  static const String checkOut = '$apiBaseUrl/attendance/check-out';

  // ✅ SCHEDULE ENDPOINTS - BARU!
  static const String scheduleMonthly = '$apiBaseUrl/schedule/monthly';
  static const String scheduleWeekly = '$apiBaseUrl/schedule/weekly';

  // ✅ FIXED: Leave Request endpoints - HARUS pakai apiBaseUrl
  static const String leaveRequest = '$apiBaseUrl/leave-requests';
  static const String createLeaveRequest = '$apiBaseUrl/leave-requests';
  static const String leaveRequestStats = '$apiBaseUrl/leave-requests/stats';

  // ✅ FIXED: Helper methods untuk dynamic URLs
  static String getLeaveRequestDetail(int id) =>
      '$apiBaseUrl/leave-requests/$id';
  static String updateLeaveRequest(int id) => '$apiBaseUrl/leave-requests/$id';
  static String deleteLeaveRequest(int id) => '$apiBaseUrl/leave-requests/$id';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> headersWithAuth(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Map<String, String> headersMultipartWithAuth(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
