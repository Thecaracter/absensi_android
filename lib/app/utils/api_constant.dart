class ApiConstant {
  static const String baseUrl = 'https://check.codingin-indonesia.my.id';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  static const String apiCheck = '$apiBaseUrl/test';

  //auth endpoints
  static const String login = '$apiBaseUrl/auth/login';
  static const String logout = '$apiBaseUrl/auth/logout';
  static const String me = '$apiBaseUrl/auth/me';

  //profile endpoints
  static const String profile = '$apiBaseUrl/profile';
  static const String updateProfile = '$apiBaseUrl/profile';

  //attendance endpoints
  static const String todayAttendance = '$apiBaseUrl/attendance/today';
  static const String checkIn = '$apiBaseUrl/attendance/check-in';
  static const String checkOut = '$apiBaseUrl/attendance/check-out';

  //leave endpoints
  static const String leaveRequest = '$apiBaseUrl/leave-requests';
  static const String createLeaveRequest = '$apiBaseUrl/leave-requests';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> headersWithAuth(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
