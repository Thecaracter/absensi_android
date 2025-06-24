// File: lib/app/controllers/leave_request_controller.dart

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:sistem_presensi/app/data/models/leave_model.dart';
import 'package:sistem_presensi/app/utils/api_constant.dart';

class LeaveRequestController extends GetxController {
  // Debug Mode - Set false untuk production
  static const bool _debugMode = kDebugMode;

  // Observable Variables
  var leaveRequests = <LeaveRequest>[].obs;
  var leaveStats = Rxn<LeaveRequestStats>();
  var isLoading = false.obs;
  var isLoadingStats = false.obs;
  var isSubmitting = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  var isLoadingMore = false.obs;

  // Filter Variables
  var selectedStatus = Rxn<String>();
  var selectedYear = DateTime.now().year.obs;

  // Form Variables
  var selectedJenisIzin = Rxn<String>();
  var tanggalMulaiController = TextEditingController();
  var tanggalSelesaiController = TextEditingController();
  var alasanController = TextEditingController();
  var selectedFile = Rxn<File>();
  var selectedFileName = ''.obs;

  // Form Validation
  var jenisIzinError = ''.obs;
  var tanggalMulaiError = ''.obs;
  var tanggalSelesaiError = ''.obs;
  var alasanError = ''.obs;

  // Network timeout duration
  static const Duration _timeoutDuration = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    _debugLog('Controller initialized');
    fetchLeaveRequests();
    fetchLeaveStats();
  }

  @override
  void onClose() {
    _debugLog('Controller disposing...');
    tanggalMulaiController.dispose();
    tanggalSelesaiController.dispose();
    alasanController.dispose();
    selectedFile.value = null;
    super.onClose();
  }

  // Debug Logging
  void _debugLog(String message) {
    if (_debugMode) {
      print('[LeaveController] ${DateTime.now().toIso8601String()}: $message');
    }
  }

  // Debug State Method
  void debugState() {
    if (!_debugMode) return;

    _debugLog('=== CONTROLLER STATE DEBUG ===');
    _debugLog('isLoading: ${isLoading.value}');
    _debugLog('isLoadingStats: ${isLoadingStats.value}');
    _debugLog('isSubmitting: ${isSubmitting.value}');
    _debugLog('hasError: ${hasError.value}');
    _debugLog('errorMessage: ${errorMessage.value}');
    _debugLog('leaveRequests count: ${leaveRequests.length}');
    _debugLog('currentPage: ${currentPage.value}');
    _debugLog('totalPages: ${totalPages.value}');
    _debugLog('hasMoreData: ${hasMoreData.value}');
    _debugLog('selectedStatus: ${selectedStatus.value}');
    _debugLog('selectedYear: ${selectedYear.value}');
    _debugLog('selectedFile: ${selectedFile.value?.path}');
    _debugLog('selectedFileName: ${selectedFileName.value}');
    _debugLog('===============================');
  }

  // Test API Connection
  Future<bool> testApiConnection() async {
    try {
      _debugLog('Testing API connection...');
      final headers = await _headers;
      final response = await http
          .get(
            Uri.parse(ApiConstant.leaveRequestStats),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));

      _debugLog('API Connection test - Status: ${response.statusCode}');
      _debugLog('API Connection test - Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      _debugLog('API Connection test failed: $e');
      return false;
    }
  }

  // Get Authorization Headers
  Future<Map<String, String>> get _headers async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      _debugLog('Getting headers - Token exists: ${token != null}');

      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
    } catch (e) {
      _debugLog('Error getting headers: $e');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  // Get Multipart Headers for file upload
  Future<Map<String, String>> get _multipartHeaders async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      _debugLog('Getting multipart headers - Token exists: ${token != null}');

      return {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
    } catch (e) {
      _debugLog('Error getting multipart headers: $e');
      return {
        'Accept': 'application/json',
      };
    }
  }

  // Enhanced Response Body Parser
  Map<String, dynamic>? _parseResponseBody(http.Response response) {
    try {
      if (response.body.isEmpty) {
        _debugLog('Response body is empty');
        return null;
      }

      _debugLog('Raw response body: ${response.body}');

      final decoded = json.decode(response.body);
      _debugLog('Parsed response body: $decoded');

      if (decoded is! Map<String, dynamic>) {
        _debugLog('Response body is not a valid JSON object');
        return null;
      }

      return decoded;
    } catch (e) {
      _debugLog('Error parsing response body: $e');
      _debugLog('Response body content: ${response.body}');
      return null;
    }
  }

  // Enhanced Response Body Parser for Multipart
  Map<String, dynamic>? _parseMultipartResponseBody(String responseBody) {
    try {
      if (responseBody.isEmpty) {
        _debugLog('Multipart response body is empty');
        return null;
      }

      _debugLog('Raw multipart response body: $responseBody');

      final decoded = json.decode(responseBody);
      _debugLog('Parsed multipart response body: $decoded');

      if (decoded is! Map<String, dynamic>) {
        _debugLog('Multipart response body is not a valid JSON object');
        return null;
      }

      return decoded;
    } catch (e) {
      _debugLog('Error parsing multipart response body: $e');
      _debugLog('Multipart response body content: $responseBody');
      return null;
    }
  }

  // Handle API Response
  void _handleApiResponse(http.Response response) {
    _debugLog('Handling API response - Status: ${response.statusCode}');

    if (response.statusCode == 401) {
      _debugLog('Token expired - redirecting to login');
      _handleTokenExpired();
    } else if (response.statusCode >= 500) {
      _debugLog('Server error detected: ${response.statusCode}');
    } else if (response.statusCode >= 400) {
      _debugLog('Client error detected: ${response.statusCode}');
    }
  }

  // Handle Token Expired
  void _handleTokenExpired() async {
    try {
      _debugLog('Handling token expiration...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed('/login');
      Get.snackbar(
        'Session Expired',
        'Please login again',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } catch (e) {
      _debugLog('Error handling token expiration: $e');
    }
  }

  // Enhanced Error Handler
  void _handleError(String operation, dynamic error) {
    _debugLog('Error in $operation: $error');

    String userMessage;
    if (error.toString().contains('SocketException')) {
      userMessage = 'Tidak ada koneksi internet';
    } else if (error.toString().contains('TimeoutException')) {
      userMessage = 'Koneksi timeout, coba lagi';
    } else if (error.toString().contains('FormatException')) {
      userMessage = 'Format data tidak valid';
    } else if (error.toString().contains('HandshakeException')) {
      userMessage = 'Masalah keamanan koneksi';
    } else {
      userMessage = 'Terjadi kesalahan: ${error.toString()}';
    }

    Get.snackbar(
      'Error',
      userMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
    );
  }

  // Fetch Leave Requests with Enhanced Error Handling
  Future<void> fetchLeaveRequests({bool refresh = true}) async {
    try {
      _debugLog(
          'Fetching leave requests - refresh: $refresh, page: ${currentPage.value}');

      if (refresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        isLoading.value = true;
        hasError.value = false;
        leaveRequests.clear();
      } else {
        isLoadingMore.value = true;
      }

      final headers = await _headers;
      final queryParams = <String, String>{
        'page': currentPage.value.toString(),
        'limit': '20',
        'tahun': selectedYear.value.toString(),
      };

      if (selectedStatus.value != null && selectedStatus.value!.isNotEmpty) {
        queryParams['status'] = selectedStatus.value!;
      }

      final uri = Uri.parse(ApiConstant.leaveRequest).replace(
        queryParameters: queryParams,
      );

      _debugLog('Request URL: $uri');
      _debugLog('Request headers: $headers');

      final response =
          await http.get(uri, headers: headers).timeout(_timeoutDuration);

      _debugLog('Response status: ${response.statusCode}');
      _debugLog('Response headers: ${response.headers}');

      _handleApiResponse(response);

      if (response.statusCode == 200) {
        final responseData = _parseResponseBody(response);

        if (responseData == null) {
          throw Exception('Invalid response format');
        }

        // Enhanced response validation
        if (responseData['success'] == true) {
          final dynamic dataField = responseData['data'];
          final dynamic paginationField = responseData['pagination'];

          // Validate data field
          if (dataField == null) {
            _debugLog('Warning: data field is null');
          }

          final List<dynamic> data = dataField is List ? dataField : [];
          final Map<String, dynamic> pagination = paginationField is Map
              ? Map<String, dynamic>.from(paginationField)
              : {};

          _debugLog('Received ${data.length} items');
          _debugLog('Pagination data: $pagination');

          final List<LeaveRequest> newLeaveRequests = [];

          // Safe parsing with individual error handling
          for (int i = 0; i < data.length; i++) {
            try {
              final item = data[i];
              if (item is Map<String, dynamic>) {
                final leaveRequest = LeaveRequest.fromJson(item);
                newLeaveRequests.add(leaveRequest);
              } else {
                _debugLog(
                    'Warning: Item at index $i is not a valid map: $item');
              }
            } catch (e) {
              _debugLog('Error parsing item at index $i: $e');
              _debugLog('Item data: ${data[i]}');
            }
          }

          if (refresh) {
            leaveRequests.value = newLeaveRequests;
          } else {
            leaveRequests.addAll(newLeaveRequests);
          }

          // Safe pagination parsing
          final int currentPageFromApi =
              _parseIntFromPagination(pagination, 'current_page', 1);
          final int lastPageFromApi =
              _parseIntFromPagination(pagination, 'last_page', 1);

          currentPage.value = currentPageFromApi;
          totalPages.value = lastPageFromApi;
          hasMoreData.value = currentPage.value < totalPages.value;

          _debugLog(
              'Updated: currentPage=${currentPage.value}, totalPages=${totalPages.value}, hasMore=${hasMoreData.value}');
        } else {
          final message = responseData['message']?.toString() ??
              'Failed to fetch leave requests';
          _debugLog('API returned success=false with message: $message');
          throw Exception(message);
        }
      } else {
        final responseData = _parseResponseBody(response);
        final message = responseData?['message']?.toString() ??
            'HTTP ${response.statusCode}';
        _debugLog('HTTP error: $message');
        throw Exception(message);
      }
    } catch (e) {
      _debugLog('Exception in fetchLeaveRequests: $e');
      _handleError('fetchLeaveRequests', e);
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Helper method to safely parse integers from pagination
  int _parseIntFromPagination(
      Map<String, dynamic> pagination, String key, int defaultValue) {
    try {
      final value = pagination[key];
      if (value is int) return value;
      if (value is String) return int.parse(value);
      return defaultValue;
    } catch (e) {
      _debugLog('Error parsing $key from pagination: $e');
      return defaultValue;
    }
  }

  // Load More Data (Pagination)
  Future<void> loadMoreData() async {
    if (!hasMoreData.value || isLoadingMore.value) {
      _debugLog(
          'Skipping loadMoreData - hasMore: ${hasMoreData.value}, isLoading: ${isLoadingMore.value}');
      return;
    }

    _debugLog('Loading more data - current page: ${currentPage.value}');
    currentPage.value++;
    await fetchLeaveRequests(refresh: false);
  }

  // Fetch Leave Statistics with Enhanced Error Handling
  Future<void> fetchLeaveStats() async {
    try {
      _debugLog('Fetching leave statistics...');
      isLoadingStats.value = true;

      final headers = await _headers;
      _debugLog('Stats request headers: $headers');

      final response = await http
          .get(
            Uri.parse(ApiConstant.leaveRequestStats),
            headers: headers,
          )
          .timeout(_timeoutDuration);

      _debugLog('Stats response status: ${response.statusCode}');

      _handleApiResponse(response);

      if (response.statusCode == 200) {
        final responseData = _parseResponseBody(response);

        if (responseData == null) {
          throw Exception('Invalid response format for stats');
        }

        if (responseData['success'] == true) {
          final dynamic statsData = responseData['data'];

          if (statsData != null && statsData is Map<String, dynamic>) {
            leaveStats.value = LeaveRequestStats.fromJson(statsData);
            _debugLog('Stats loaded successfully');
          } else {
            _debugLog('Warning: Stats data is null or invalid format');
            leaveStats.value = null;
          }
        } else {
          final message =
              responseData['message']?.toString() ?? 'Failed to fetch stats';
          _debugLog('Stats API returned success=false: $message');
          throw Exception(message);
        }
      } else {
        final responseData = _parseResponseBody(response);
        final message =
            responseData?['message']?.toString() ?? 'Failed to fetch stats';
        _debugLog('Stats HTTP error: $message');
        throw Exception(message);
      }
    } catch (e) {
      _debugLog('Exception in fetchLeaveStats: $e');
      _handleError('fetchLeaveStats', e);
    } finally {
      isLoadingStats.value = false;
    }
  }

  // Create New Leave Request with Enhanced Error Handling
  Future<void> createLeaveRequest() async {
    if (!_validateForm()) {
      _debugLog('Form validation failed for create request');
      return;
    }

    try {
      _debugLog('Creating leave request...');
      isSubmitting.value = true;

      final headers = await _multipartHeaders;
      _debugLog('Create request headers: $headers');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstant.createLeaveRequest),
      );

      // Add headers
      request.headers.addAll(headers);

      // Add form fields
      request.fields['jenis_izin'] = selectedJenisIzin.value!;
      request.fields['tanggal_mulai'] = tanggalMulaiController.text;
      request.fields['tanggal_selesai'] = tanggalSelesaiController.text;
      request.fields['alasan'] = alasanController.text;

      _debugLog('Create request fields: ${request.fields}');

      // Add file if selected
      if (selectedFile.value != null) {
        try {
          final file = selectedFile.value!;
          if (await file.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'lampiran',
                file.path,
              ),
            );
            _debugLog('File added to request: ${file.path}');
          } else {
            _debugLog('Selected file does not exist: ${file.path}');
          }
        } catch (e) {
          _debugLog('Error adding file to request: $e');
        }
      }

      final response = await request.send().timeout(_timeoutDuration);
      final responseBody = await response.stream.bytesToString();

      _debugLog('Create response status: ${response.statusCode}');
      _debugLog('Create response body: $responseBody');

      final responseData = _parseMultipartResponseBody(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData != null && responseData['success'] == true) {
          _debugLog('Leave request created successfully');

          Get.snackbar(
            'Berhasil',
            'Pengajuan izin berhasil dibuat',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );

          clearForm();
          await Future.wait([
            fetchLeaveRequests(),
            fetchLeaveStats(),
          ]);
          Get.back(); // Close form page
        } else {
          final message = responseData?['message']?.toString() ??
              'Failed to create leave request';
          _debugLog('Create request failed: $message');
          throw Exception(message);
        }
      } else {
        final message = responseData?['message']?.toString() ??
            'HTTP ${response.statusCode}';
        _debugLog('Create request HTTP error: $message');
        throw Exception(message);
      }
    } catch (e) {
      _debugLog('Exception in createLeaveRequest: $e');
      _handleError('createLeaveRequest', e);
    } finally {
      isSubmitting.value = false;
    }
  }

  // Update Leave Request with Enhanced Error Handling
  Future<void> updateLeaveRequest(int id) async {
    if (!_validateForm()) {
      _debugLog('Form validation failed for update request');
      return;
    }

    try {
      _debugLog('Updating leave request ID: $id');
      isSubmitting.value = true;

      final headers = await _multipartHeaders;
      _debugLog('Update request headers: $headers');

      var request = http.MultipartRequest(
        'POST', // Using POST with _method=PUT for Laravel
        Uri.parse(ApiConstant.updateLeaveRequest(id)),
      );

      // Add headers
      request.headers.addAll(headers);

      // Add form fields
      request.fields['_method'] = 'PUT';
      request.fields['jenis_izin'] = selectedJenisIzin.value!;
      request.fields['tanggal_mulai'] = tanggalMulaiController.text;
      request.fields['tanggal_selesai'] = tanggalSelesaiController.text;
      request.fields['alasan'] = alasanController.text;

      _debugLog('Update request fields: ${request.fields}');

      // Add file if selected
      if (selectedFile.value != null) {
        try {
          final file = selectedFile.value!;
          if (await file.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'lampiran',
                file.path,
              ),
            );
            _debugLog('File added to update request: ${file.path}');
          } else {
            _debugLog('Selected file does not exist: ${file.path}');
          }
        } catch (e) {
          _debugLog('Error adding file to update request: $e');
        }
      }

      final response = await request.send().timeout(_timeoutDuration);
      final responseBody = await response.stream.bytesToString();

      _debugLog('Update response status: ${response.statusCode}');
      _debugLog('Update response body: $responseBody');

      final responseData = _parseMultipartResponseBody(responseBody);

      if (response.statusCode == 200) {
        if (responseData != null && responseData['success'] == true) {
          _debugLog('Leave request updated successfully');

          Get.snackbar(
            'Berhasil',
            'Pengajuan izin berhasil diperbarui',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );

          clearForm();
          await Future.wait([
            fetchLeaveRequests(),
            fetchLeaveStats(),
          ]);
          Get.back(); // Close form page
        } else {
          final message = responseData?['message']?.toString() ??
              'Failed to update leave request';
          _debugLog('Update request failed: $message');
          throw Exception(message);
        }
      } else {
        final message = responseData?['message']?.toString() ??
            'HTTP ${response.statusCode}';
        _debugLog('Update request HTTP error: $message');
        throw Exception(message);
      }
    } catch (e) {
      _debugLog('Exception in updateLeaveRequest: $e');
      _handleError('updateLeaveRequest', e);
    } finally {
      isSubmitting.value = false;
    }
  }

  // Delete Leave Request with Enhanced Error Handling
  Future<void> deleteLeaveRequest(int id) async {
    try {
      _debugLog('Deleting leave request ID: $id');

      final headers = await _headers;
      _debugLog('Delete request headers: $headers');

      final response = await http
          .delete(
            Uri.parse(ApiConstant.deleteLeaveRequest(id)),
            headers: headers,
          )
          .timeout(_timeoutDuration);

      _debugLog('Delete response status: ${response.statusCode}');

      _handleApiResponse(response);

      if (response.statusCode == 200) {
        final responseData = _parseResponseBody(response);

        if (responseData != null && responseData['success'] == true) {
          _debugLog('Leave request deleted successfully');

          Get.snackbar(
            'Berhasil',
            'Pengajuan izin berhasil dihapus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );

          await Future.wait([
            fetchLeaveRequests(),
            fetchLeaveStats(),
          ]);
        } else {
          final message = responseData?['message']?.toString() ??
              'Failed to delete leave request';
          _debugLog('Delete request failed: $message');
          throw Exception(message);
        }
      } else {
        final responseData = _parseResponseBody(response);
        final message = responseData?['message']?.toString() ??
            'HTTP ${response.statusCode}';
        _debugLog('Delete request HTTP error: $message');
        throw Exception(message);
      }
    } catch (e) {
      _debugLog('Exception in deleteLeaveRequest: $e');
      _handleError('deleteLeaveRequest', e);
    }
  }

  // Pick File with Enhanced Validation
  Future<void> pickFile() async {
    try {
      _debugLog('Picking file...');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        // Validate file path
        if (platformFile.path == null) {
          _debugLog('File path is null');
          Get.snackbar(
            'Error',
            'File path tidak valid',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          return;
        }

        final file = File(platformFile.path!);

        // Check if file exists
        if (!await file.exists()) {
          _debugLog('Selected file does not exist: ${file.path}');
          Get.snackbar(
            'Error',
            'File tidak ditemukan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          return;
        }

        final fileSize = await file.length();
        _debugLog('File selected: ${file.path}, size: $fileSize bytes');

        // Check file size (max 2MB)
        if (fileSize > 2 * 1024 * 1024) {
          _debugLog('File too large: $fileSize bytes');
          Get.snackbar(
            'Error',
            'Ukuran file maksimal 2MB',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          return;
        }

        selectedFile.value = file;
        selectedFileName.value = platformFile.name;

        _debugLog('File selected successfully: ${selectedFileName.value}');

        Get.snackbar(
          'Berhasil',
          'File berhasil dipilih: ${selectedFileName.value}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        _debugLog('No file selected');
      }
    } catch (e) {
      _debugLog('Exception in pickFile: $e');
      Get.snackbar(
        'Error',
        'Gagal memilih file: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Remove Selected File
  void removeFile() {
    _debugLog('Removing selected file');
    selectedFile.value = null;
    selectedFileName.value = '';
  }

  // Enhanced Date Format Validation
  bool _isValidDateFormat(String date) {
    try {
      if (date.isEmpty) return false;

      // Check basic format YYYY-MM-DD
      final parts = date.split('-');
      if (parts.length != 3) return false;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // Basic range checks
      if (year < 1900 || year > 2100) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Try to parse as DateTime to validate
      final parsedDate = DateTime(year, month, day);
      return parsedDate.year == year &&
          parsedDate.month == month &&
          parsedDate.day == day;
    } catch (e) {
      _debugLog('Date validation error: $e');
      return false;
    }
  }

  // Enhanced Form Validation
  bool _validateForm() {
    bool isValid = true;
    _debugLog('Validating form...');

    // Reset errors
    jenisIzinError.value = '';
    tanggalMulaiError.value = '';
    tanggalSelesaiError.value = '';
    alasanError.value = '';

    // Validate Jenis Izin
    if (selectedJenisIzin.value == null || selectedJenisIzin.value!.isEmpty) {
      jenisIzinError.value = 'Jenis izin harus dipilih';
      isValid = false;
      _debugLog('Validation failed: Jenis izin empty');
    }

    // Validate Tanggal Mulai
    if (tanggalMulaiController.text.isEmpty) {
      tanggalMulaiError.value = 'Tanggal mulai harus diisi';
      isValid = false;
      _debugLog('Validation failed: Tanggal mulai empty');
    } else if (!_isValidDateFormat(tanggalMulaiController.text)) {
      tanggalMulaiError.value = 'Format tanggal tidak valid (YYYY-MM-DD)';
      isValid = false;
      _debugLog('Validation failed: Invalid date format for tanggal mulai');
    }

    // Validate Tanggal Selesai
    if (tanggalSelesaiController.text.isEmpty) {
      tanggalSelesaiError.value = 'Tanggal selesai harus diisi';
      isValid = false;
      _debugLog('Validation failed: Tanggal selesai empty');
    } else if (!_isValidDateFormat(tanggalSelesaiController.text)) {
      tanggalSelesaiError.value = 'Format tanggal tidak valid (YYYY-MM-DD)';
      isValid = false;
      _debugLog('Validation failed: Invalid date format for tanggal selesai');
    }

    // Validate Date Range
    if (tanggalMulaiController.text.isNotEmpty &&
        tanggalSelesaiController.text.isNotEmpty &&
        _isValidDateFormat(tanggalMulaiController.text) &&
        _isValidDateFormat(tanggalSelesaiController.text)) {
      try {
        final startDate = DateTime.parse(tanggalMulaiController.text);
        final endDate = DateTime.parse(tanggalSelesaiController.text);

        if (endDate.isBefore(startDate)) {
          tanggalSelesaiError.value =
              'Tanggal selesai tidak boleh sebelum tanggal mulai';
          isValid = false;
          _debugLog('Validation failed: End date before start date');
        }

        // Validate future dates (optional - remove if past dates are allowed)
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        if (startDate.isBefore(todayOnly)) {
          tanggalMulaiError.value = 'Tanggal mulai tidak boleh di masa lalu';
          isValid = false;
          _debugLog('Validation failed: Start date in the past');
        }
      } catch (e) {
        _debugLog('Error in date range validation: $e');
      }
    }

    // Validate Alasan
    final alasanText = alasanController.text.trim();
    if (alasanText.isEmpty) {
      alasanError.value = 'Alasan harus diisi';
      isValid = false;
      _debugLog('Validation failed: Alasan empty');
    } else if (alasanText.length < 10) {
      alasanError.value = 'Alasan minimal 10 karakter';
      isValid = false;
      _debugLog(
          'Validation failed: Alasan too short (${alasanText.length} chars)');
    }

    _debugLog('Form validation result: $isValid');
    return isValid;
  }

  // Clear Form
  void clearForm() {
    _debugLog('Clearing form...');
    selectedJenisIzin.value = null;
    tanggalMulaiController.clear();
    tanggalSelesaiController.clear();
    alasanController.clear();
    selectedFile.value = null;
    selectedFileName.value = '';

    // Clear errors
    jenisIzinError.value = '';
    tanggalMulaiError.value = '';
    tanggalSelesaiError.value = '';
    alasanError.value = '';
  }

  // Load Leave Request for Edit
  void loadLeaveRequestForEdit(LeaveRequest leaveRequest) {
    _debugLog('Loading leave request for edit: ${leaveRequest.id}');
    selectedJenisIzin.value = leaveRequest.jenisIzin;
    tanggalMulaiController.text = leaveRequest.tanggalMulai;
    tanggalSelesaiController.text = leaveRequest.tanggalSelesai;
    alasanController.text = leaveRequest.alasan;

    // Clear file selection for edit
    selectedFile.value = null;
    selectedFileName.value = '';
  }

  // Filter Methods
  void filterByStatus(String? status) {
    _debugLog('Filtering by status: $status');
    selectedStatus.value = status;
    fetchLeaveRequests();
  }

  void filterByYear(int year) {
    _debugLog('Filtering by year: $year');
    selectedYear.value = year;
    fetchLeaveRequests();
  }

  void clearFilters() {
    _debugLog('Clearing filters');
    selectedStatus.value = null;
    selectedYear.value = DateTime.now().year;
    fetchLeaveRequests();
  }

  // Refresh Data
  Future<void> refreshData() async {
    _debugLog('Refreshing all data...');
    await Future.wait([
      fetchLeaveRequests(),
      fetchLeaveStats(),
    ]);
  }

  // Get Filtered Leave Requests
  List<LeaveRequest> get filteredLeaveRequests {
    if (selectedStatus.value == null) {
      return leaveRequests;
    }
    return leaveRequests
        .where((request) => request.status == selectedStatus.value)
        .toList();
  }

  // Get Available Years
  List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - index);
  }
}
