// File: lib/app/modules/attendance/controllers/attendance_controller.dart
// COMPLETE VERSION - Fixed Location JSON + Front Camera + No Fallback

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_presensi/app/data/models/attendance_model.dart';
import 'package:sistem_presensi/app/data/models/location_model.dart';
import 'package:sistem_presensi/app/utils/api_constant.dart';

class AttendanceController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isCheckingIn = false.obs;
  var isCheckingOut = false.obs;
  var attendanceData = Rxn<AttendanceModel>();
  var selectedImage = Rxn<File>();
  var isCameraInitialized = false.obs;

  // Location variables (Real GPS)
  var currentLatitude = (0.0).obs;
  var currentLongitude = (0.0).obs;
  var currentPosition = Rxn<Position>();
  var isGettingLocation = false.obs;
  var hasLocationPermission = false.obs;
  var locationError = ''.obs;
  var locationConfig = Rxn<LocationConfigModel>();
  var locationValidationResult = Rxn<LocationValidationResult>();
  var isLocationValid = false.obs;
  var locationAccuracy = (0.0).obs;
  var lastLocationUpdate = DateTime.now().obs;

  // Auto-tracking variables
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;
  var isAutoTrackingActive = false.obs;

  // ENHANCED Camera variables
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  var currentCameraIndex = 0.obs;
  var isFrontCamera = false.obs;
  var cameraError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
    loadLocationConfig();
    getTodayAttendance();
  }

  @override
  void onReady() {
    super.onReady();
    forceStartLocationTracking();
  }

  @override
  void onClose() {
    stopAutoLocationTracking();
    disposeCamera();
    super.onClose();
  }

  // FIXED: Initialize camera with FRONT camera priority
  Future<void> initializeCamera() async {
    try {
      print('🔥 CAMERA: Initializing camera...');
      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        print('🔥 CAMERA: ❌ No cameras available');
        cameraError.value = 'Tidak ada kamera yang tersedia di perangkat ini';
        Get.snackbar('Error', cameraError.value);
        return;
      }

      print('🔥 CAMERA: Found ${cameras!.length} cameras');

      // Log all available cameras
      for (int i = 0; i < cameras!.length; i++) {
        print(
            '🔥 CAMERA: Camera $i: ${cameras![i].lensDirection} (${cameras![i].name})');
      }

      // PRIORITY: Find FRONT camera first (for selfie attendance)
      int frontCameraIndex = -1;
      int backCameraIndex = -1;

      for (int i = 0; i < cameras!.length; i++) {
        if (cameras![i].lensDirection == CameraLensDirection.front) {
          frontCameraIndex = i;
          print('🔥 CAMERA: ✅ Front camera found at index $i');
        } else if (cameras![i].lensDirection == CameraLensDirection.back) {
          backCameraIndex = i;
          print('🔥 CAMERA: ✅ Back camera found at index $i');
        }
      }

      // Use front camera if available, otherwise back camera
      if (frontCameraIndex != -1) {
        currentCameraIndex.value = frontCameraIndex;
        isFrontCamera.value = true;
        print(
            '🔥 CAMERA: Using FRONT camera (index $frontCameraIndex) for selfie');
      } else if (backCameraIndex != -1) {
        currentCameraIndex.value = backCameraIndex;
        isFrontCamera.value = false;
        print(
            '🔥 CAMERA: Front camera not found, using BACK camera (index $backCameraIndex)');
      } else {
        currentCameraIndex.value = 0;
        isFrontCamera.value =
            cameras![0].lensDirection == CameraLensDirection.front;
        print('🔥 CAMERA: Using default camera (index 0)');
      }

      cameraController = CameraController(
        cameras![currentCameraIndex.value],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
      cameraError.value = '';

      print('🔥 CAMERA: ✅ Camera initialized successfully');
      print(
          '🔥 CAMERA: Current camera: ${isFrontCamera.value ? "FRONT" : "BACK"}');
    } catch (e) {
      print('🔥 CAMERA: ❌ Error initializing camera: $e');
      cameraError.value = 'Gagal menginisialisasi kamera: $e';
      Get.snackbar('Error', cameraError.value);
      isCameraInitialized.value = false;
    }
  }

  // ENHANCED: Switch between front and back camera
  Future<void> switchCamera() async {
    if (cameras == null || cameras!.length < 2) {
      print('🔥 CAMERA: ❌ Cannot switch - not enough cameras');
      Get.snackbar('Info', 'Hanya ada satu kamera di perangkat ini');
      return;
    }

    try {
      print('🔥 CAMERA: Switching camera...');

      // Dispose current camera
      await cameraController?.dispose();

      // Find next camera (prioritize switching between front/back)
      int newCameraIndex = currentCameraIndex.value;

      if (isFrontCamera.value) {
        // Currently front, switch to back
        for (int i = 0; i < cameras!.length; i++) {
          if (cameras![i].lensDirection == CameraLensDirection.back) {
            newCameraIndex = i;
            break;
          }
        }
      } else {
        // Currently back, switch to front
        for (int i = 0; i < cameras!.length; i++) {
          if (cameras![i].lensDirection == CameraLensDirection.front) {
            newCameraIndex = i;
            break;
          }
        }
      }

      currentCameraIndex.value = newCameraIndex;
      isFrontCamera.value =
          cameras![newCameraIndex].lensDirection == CameraLensDirection.front;

      // Initialize new camera
      cameraController = CameraController(
        cameras![newCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();

      print(
          '🔥 CAMERA: ✅ Switched to ${isFrontCamera.value ? "FRONT" : "BACK"} camera');

      Get.snackbar(
        'Kamera Beralih',
        'Menggunakan kamera ${isFrontCamera.value ? "depan" : "belakang"}',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('🔥 CAMERA: ❌ Error switching camera: $e');
      Get.snackbar('Error', 'Gagal beralih kamera: $e');

      // Try to reinitialize original camera
      try {
        await initializeCamera();
      } catch (reinitError) {
        print('🔥 CAMERA: ❌ Error reinitializing camera: $reinitError');
      }
    }
  }

  // Dispose camera
  void disposeCamera() {
    print('🔥 CAMERA: Disposing camera...');
    cameraController?.dispose();
    isCameraInitialized.value = false;
  }

  // Force start location tracking
  Future<void> forceStartLocationTracking() async {
    try {
      isAutoTrackingActive.value = true;
      locationError.value = '';

      // Force request permission
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        locationError.value =
            'Izin lokasi ditolak. Aplikasi memerlukan GPS untuk absensi.';
        hasLocationPermission.value = false;
        return;
      }

      hasLocationPermission.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationError.value =
            'GPS tidak aktif. Silakan aktifkan GPS di pengaturan ponsel.';
        return;
      }

      // Get location immediately
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        _updateLocationData(position);
      } catch (e) {
        // Continue with stream anyway
      }

      // Start position stream
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        timeLimit: Duration(seconds: 10),
      );

      _positionStream?.cancel();
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) => _updateLocationData(position),
        onError: (error) => locationError.value = 'GPS stream error: $error',
      );

      // Start backup timer
      _locationTimer?.cancel();
      _locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
        if (hasLocationPermission.value) {
          _getLocationNow();
        }
      });
    } catch (e) {
      locationError.value = 'Gagal memulai GPS tracking: $e';
    }
  }

  // Get location NOW - immediate
  Future<void> _getLocationNow() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      _updateLocationData(position);
    } catch (e) {
      // Silent failure for background updates
    }
  }

  // Stop automatic location tracking
  void stopAutoLocationTracking() {
    isAutoTrackingActive.value = false;
    _locationTimer?.cancel();
    _positionStream?.cancel();
    _locationTimer = null;
    _positionStream = null;
  }

  // Update location data from position
  void _updateLocationData(Position position) {
    currentPosition.value = position;
    currentLatitude.value = position.latitude;
    currentLongitude.value = position.longitude;
    locationAccuracy.value = position.accuracy;
    lastLocationUpdate.value = DateTime.now();
    locationError.value = '';

    // Auto validate location
    validateCurrentLocation();
  }

  // Manual refresh location
  Future<void> refreshLocation() async {
    try {
      isGettingLocation.value = true;
      locationError.value = '';

      await checkLocationPermissionOnly();

      if (!hasLocationPermission.value) {
        locationError.value =
            'Izin lokasi diperlukan. Silakan aktifkan di pengaturan.';
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationError.value =
            'GPS tidak aktif. Silakan aktifkan GPS di pengaturan.';
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _updateLocationData(position);

      Get.snackbar(
        'GPS Diperbarui',
        'Lokasi berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      locationError.value = 'Gagal mendapatkan lokasi: $e';
    } finally {
      isGettingLocation.value = false;
    }
  }

  // Check location permission only
  Future<void> checkLocationPermissionOnly() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          hasLocationPermission.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        hasLocationPermission.value = false;
        return;
      }

      hasLocationPermission.value = true;
    } catch (e) {
      hasLocationPermission.value = false;
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('Cannot open location settings: $e');
    }
  }

  // Open app settings for permission
  Future<void> openAppSettings() async {
    try {
      await Permission.location.request();
    } catch (e) {
      print('Cannot open app settings: $e');
    }
  }

  // Get stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // FIXED: Load location configuration - NO FALLBACK VERSION
  // FIXED: Update path ke assets/json/location.json

  Future<void> loadLocationConfig() async {
    try {
      print('🔥 LOCATION: Loading location config...');

      // PATH YANG BENAR sesuai lokasi file Anda
      final String jsonString =
          await rootBundle.loadString('assets/json/location.json');
      print(
          '🔥 LOCATION: ✅ Successfully loaded from assets/json/location.json');

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      locationConfig.value = LocationConfigModel.fromJson(jsonData);

      print('🔥 LOCATION: ✅ Config parsed successfully');
      print(
          '🔥 LOCATION: Office: ${locationConfig.value!.officeLocation.name}');
      print(
          '🔥 LOCATION: Office Coordinates: ${locationConfig.value!.officeLocation.latitude}, ${locationConfig.value!.officeLocation.longitude}');
      print(
          '🔥 LOCATION: Branches: ${locationConfig.value!.branchLocations.length}');

      // Log semua koordinat branch
      for (var branch in locationConfig.value!.branchLocations) {
        print(
            '🔥 LOCATION: Branch ${branch.name}: ${branch.latitude}, ${branch.longitude}');
      }

      validateCurrentLocation();
    } catch (e) {
      print('🔥 LOCATION: ❌ FATAL ERROR - Cannot load location.json: $e');
      print('🔥 LOCATION: ❌ Path: assets/json/location.json');
      print(
          '🔥 LOCATION: ❌ Check if file exists and pubspec.yaml includes assets/json/');

      // Show error dialog
      Get.dialog(
        AlertDialog(
          title: Text('FATAL ERROR'),
          content: Text('Cannot load location.json!\n\n'
              'Error: $e\n\n'
              'Make sure:\n'
              '1. File exists at assets/json/location.json\n'
              '2. pubspec.yaml includes assets/json/\n'
              '3. Run flutter clean && flutter pub get'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      // RE-THROW ERROR
      rethrow;
    }
  }

  // Calculate distance between two points using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth radius in meters

    double lat1Rad = lat1 * (pi / 180);
    double lat2Rad = lat2 * (pi / 180);
    double deltaLatRad = (lat2 - lat1) * (pi / 180);
    double deltaLonRad = (lon2 - lon1) * (pi / 180);

    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLonRad / 2) *
            sin(deltaLonRad / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Validate current location using real GPS
  void validateCurrentLocation() {
    if (locationConfig.value == null) {
      isLocationValid.value = false;
      locationValidationResult.value = LocationValidationResult.invalid(
          message: 'Konfigurasi lokasi tidak tersedia');
      return;
    }

    // Check if we have valid GPS coordinates
    if (currentLatitude.value == 0.0 && currentLongitude.value == 0.0) {
      isLocationValid.value = false;
      locationValidationResult.value =
          LocationValidationResult.invalid(message: 'Menunggu sinyal GPS...');
      return;
    }

    final config = locationConfig.value!;

    // If location validation is disabled
    if (!config.settings.enableLocationValidation) {
      locationValidationResult.value = LocationValidationResult.valid(
        locationName: 'Validasi Dinonaktifkan',
        distance: 0,
        locationType: 'disabled',
      );
      isLocationValid.value = true;
      return;
    }

    // Check office location
    double officeDistance = calculateDistance(
      currentLatitude.value,
      currentLongitude.value,
      config.officeLocation.latitude,
      config.officeLocation.longitude,
    );

    if (officeDistance <= config.officeLocation.radiusMeters) {
      locationValidationResult.value = LocationValidationResult.valid(
        locationName: config.officeLocation.name,
        distance: officeDistance,
        locationType: 'office',
      );
      isLocationValid.value = true;
      return;
    }

    // Check branch locations
    for (var branch in config.branchLocations) {
      double branchDistance = calculateDistance(
        currentLatitude.value,
        currentLongitude.value,
        branch.latitude,
        branch.longitude,
      );

      if (branchDistance <= branch.radiusMeters) {
        locationValidationResult.value = LocationValidationResult.valid(
          locationName: branch.name,
          distance: branchDistance,
          locationType: 'branch',
        );
        isLocationValid.value = true;
        return;
      }
    }

    // Find nearest location for error message
    String nearestLocationName = config.officeLocation.name;
    double nearestDistance = officeDistance;

    for (var branch in config.branchLocations) {
      double branchDistance = calculateDistance(
        currentLatitude.value,
        currentLongitude.value,
        branch.latitude,
        branch.longitude,
      );

      if (branchDistance < nearestDistance) {
        nearestDistance = branchDistance;
        nearestLocationName = branch.name;
      }
    }

    locationValidationResult.value = LocationValidationResult.invalid(
      message:
          'Jarak ${formatDistance(nearestDistance)} dari $nearestLocationName',
      distance: nearestDistance,
      nearestLocationName: nearestLocationName,
      locationType: 'office',
    );
    isLocationValid.value = false;
  }

  // Format distance for display
  String formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  // Get all office locations
  List<Map<String, dynamic>> getAllOfficeLocations() {
    if (locationConfig.value == null) {
      print('🔥 LOCATION: ❌ locationConfig is null');
      return [];
    }

    print(
        '🔥 LOCATION: ✅ Returning ${locationConfig.value!.allLocations.length} locations');
    return locationConfig.value!.allLocations;
  }

  // Show office locations dialog
  void showOfficeLocationsDialog() {
    final offices = getAllOfficeLocations();

    if (offices.isEmpty) {
      Get.snackbar('Error', 'Data lokasi kantor tidak tersedia');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Lokasi Kantor'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: offices.length,
            itemBuilder: (context, index) {
              final office = offices[index];
              final distance = calculateDistance(
                currentLatitude.value,
                currentLongitude.value,
                office['latitude'],
                office['longitude'],
              );

              return ListTile(
                leading: Icon(
                  office['type'] == 'office'
                      ? Icons.business
                      : Icons.location_city,
                  color: distance <= office['radius']
                      ? Colors.green
                      : Colors.orange,
                ),
                title: Text(office['name']),
                subtitle: Text(
                  '${office['address']}\n'
                  'Jarak: ${formatDistance(distance)} '
                  '(Radius: ${office['radius']}m)',
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Get today's attendance data with robust error handling
  Future<void> getTodayAttendance() async {
    try {
      print('🔥 SHIFT: ===== STARTING getTodayAttendance =====');
      isLoading.value = true;
      final token = await _getToken();

      if (token == null) {
        print('🔥 SHIFT: ❌ No token found');
        Get.snackbar('Error', 'Token tidak ditemukan');
        return;
      }

      // Force fresh data with cache busting
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomParam = DateTime.now().microsecond;
      final url =
          '${ApiConstant.todayAttendance}?_t=$timestamp&_r=$randomParam&_cache=false';

      print('🔥 SHIFT: Calling API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
          'Pragma': 'no-cache',
          'Expires': '0',
          'If-Modified-Since': 'Mon, 26 Jul 1997 05:00:00 GMT',
          'If-None-Match': '*',
        },
      );

      print('🔥 SHIFT: Response status: ${response.statusCode}');
      print('🔥 SHIFT: Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('🔥 SHIFT: JSON parsed successfully');
        print('🔥 SHIFT: Success flag: ${jsonResponse['success']}');
        print('🔥 SHIFT: Message: ${jsonResponse['message']}');

        if (jsonResponse['success'] == true) {
          if (jsonResponse['data'] != null && jsonResponse['data'] != false) {
            print('🔥 SHIFT: ✅ Valid data received, parsing...');

            try {
              // DETAILED PARSING DEBUG
              final rawData = jsonResponse['data'];
              print('🔥 PARSING: Raw data keys: ${rawData.keys.toList()}');
              print('🔥 PARSING: Shift data: ${rawData['shift']}');
              print(
                  '🔥 PARSING: Latitude masuk: ${rawData['latitude_masuk']} (${rawData['latitude_masuk'].runtimeType})');
              print(
                  '🔥 PARSING: Longitude masuk: ${rawData['longitude_masuk']} (${rawData['longitude_masuk'].runtimeType})');

              final newAttendance = AttendanceModel.fromJson(rawData);
              attendanceData.value = newAttendance;

              print('🔥 SHIFT: ✅ Attendance parsed successfully');
              print('🔥 SHIFT: ID: ${newAttendance.id}');
              print('🔥 SHIFT: Status absen: ${newAttendance.statusAbsen}');
              print('🔥 SHIFT: Sudah check in: ${newAttendance.sudahCheckIn}');
              print(
                  '🔥 SHIFT: Sudah check out: ${newAttendance.sudahCheckOut}');
              print(
                  '🔥 SHIFT: Dapat check out: ${newAttendance.dapatCheckOut}');

              // DETAILED SHIFT DEBUG
              if (newAttendance.shift != null) {
                print('🔥 SHIFT: ✅ SHIFT DATA FOUND:');
                print('🔥 SHIFT: Shift ID: ${newAttendance.shift!.id}');
                print('🔥 SHIFT: Shift Name: ${newAttendance.shift!.nama}');
                print('🔥 SHIFT: Jam Masuk: ${newAttendance.shift!.jamMasuk}');
                print(
                    '🔥 SHIFT: Jam Keluar: ${newAttendance.shift!.jamKeluar}');
                print(
                    '🔥 SHIFT: Toleransi: ${newAttendance.shift!.toleransiMenit} menit');
              } else {
                print('🔥 SHIFT: ❌ NO SHIFT DATA IN ATTENDANCE');
                print('🔥 SHIFT: Raw shift data: ${rawData['shift']}');
              }

              // COORDINATE DEBUG
              print(
                  '🔥 COORDINATES: Latitude masuk: ${newAttendance.latitudeMasuk}');
              print(
                  '🔥 COORDINATES: Longitude masuk: ${newAttendance.longitudeMasuk}');
            } catch (parseError) {
              print('🔥 SHIFT: ❌ PARSING ERROR: $parseError');
              print('🔥 SHIFT: ❌ Stack trace: ${StackTrace.current}');

              // Try to identify specific parsing issue
              final rawData = jsonResponse['data'];
              print('🔥 DEBUG: Problematic data analysis:');

              // Safely check each coordinate field
              _debugCoordinateField(
                  'latitude_masuk', rawData['latitude_masuk']);
              _debugCoordinateField(
                  'longitude_masuk', rawData['longitude_masuk']);
              _debugCoordinateField(
                  'latitude_keluar', rawData['latitude_keluar']);
              _debugCoordinateField(
                  'longitude_keluar', rawData['longitude_keluar']);

              print('🔥 DEBUG: shift data: ${rawData['shift']}');

              attendanceData.value = null;

              Get.snackbar(
                'Parsing Error',
                'Gagal memproses data dari server. Error: $parseError',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 5),
              );
            }
          } else {
            print(
                '🔥 SHIFT: ℹ️  No attendance data for today (data is null/false)');
            attendanceData.value = null;
          }
        } else {
          print('🔥 SHIFT: ❌ API returned success=false');
          print('🔥 SHIFT: Error message: ${jsonResponse['message']}');
          attendanceData.value = null;
        }
      } else {
        print('🔥 SHIFT: ❌ HTTP Error ${response.statusCode}');
        print('🔥 SHIFT: Error response: ${response.body}');
        Get.snackbar(
            'Error', 'Gagal mengambil data absensi (${response.statusCode})');
      }
    } catch (e) {
      print('🔥 SHIFT: ❌ Exception occurred: $e');
      print('🔥 SHIFT: Stack trace: ${StackTrace.current}');
      Get.snackbar('Error', 'Terjadi kesalahan saat mengambil data: $e');
    } finally {
      isLoading.value = false;
      print('🔥 SHIFT: ===== getTodayAttendance FINISHED =====');
    }
  }

  // Helper method to debug coordinate fields
  void _debugCoordinateField(String fieldName, dynamic value) {
    print('🔥 DEBUG: $fieldName value: "$value"');
    print('🔥 DEBUG: $fieldName type: ${value.runtimeType}');

    if (value is String) {
      try {
        final parsed = double.parse(value);
        print('🔥 DEBUG: $fieldName can be parsed to: $parsed');
      } catch (e) {
        print('🔥 DEBUG: $fieldName CANNOT be parsed: $e');
      }
    }
  }

  // SUPER FORCE REFRESH - Clear everything and reload
  Future<void> forceRefreshAttendance() async {
    print('🔥 FORCE REFRESH: Starting super force refresh...');

    try {
      isLoading.value = true;

      // Clear all cached data
      attendanceData.value = null;

      // Add loading delay to show user something is happening
      await Future.delayed(const Duration(milliseconds: 300));

      // Multiple refresh attempts
      for (int attempt = 1; attempt <= 3; attempt++) {
        print('🔥 FORCE REFRESH: Attempt $attempt of 3');

        try {
          await getTodayAttendance();

          // If we got data, break out of retry loop
          if (attendanceData.value != null) {
            print('🔥 FORCE REFRESH: Success on attempt $attempt');
            break;
          }

          // Wait between attempts
          if (attempt < 3) {
            print('🔥 FORCE REFRESH: No data on attempt $attempt, retrying...');
            await Future.delayed(const Duration(milliseconds: 500));
          }
        } catch (e) {
          print('🔥 FORCE REFRESH: Attempt $attempt failed: $e');
          if (attempt == 3) {
            rethrow; // Re-throw on final attempt
          }
        }
      }

      if (attendanceData.value != null) {
        Get.snackbar(
          'Data Diperbarui',
          'Data absensi berhasil disinkronkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Tidak Ada Data',
          'Belum ada data absensi untuk hari ini',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('🔥 FORCE REFRESH: Final error: $e');
      Get.snackbar(
        'Error Sync',
        'Gagal menyinkronkan data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ENHANCED: Take photo with camera
  Future<void> takePhoto() async {
    print(
        '🔥 CAMERA: Taking photo with ${isFrontCamera.value ? "FRONT" : "BACK"} camera...');

    if (!isCameraInitialized.value || cameraController == null) {
      print('🔥 CAMERA: ❌ Camera not ready');
      Get.snackbar('Error', 'Kamera belum siap');
      return;
    }

    try {
      print('🔥 CAMERA: Capturing image...');
      final XFile photo = await cameraController!.takePicture();
      selectedImage.value = File(photo.path);

      print('🔥 CAMERA: ✅ Photo captured successfully');
      print('🔥 CAMERA: Photo path: ${photo.path}');
      print('🔥 CAMERA: File size: ${await File(photo.path).length()} bytes');
      print(
          '🔥 CAMERA: Camera used: ${isFrontCamera.value ? "FRONT" : "BACK"}');

      Get.back(); // Close camera view
      Get.snackbar(
        'Berhasil',
        'Foto berhasil diambil dengan kamera ${isFrontCamera.value ? "depan" : "belakang"}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('🔥 CAMERA: ❌ Error taking photo: $e');
      Get.snackbar('Error', 'Gagal mengambil foto: $e');
    }
  }

  // Pick image from gallery using file_picker
  Future<void> pickImageFromGallery() async {
    try {
      print('🔥 CAMERA: Opening gallery...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        selectedImage.value = File(result.files.single.path!);

        print('🔥 CAMERA: ✅ Image selected from gallery');
        print('🔥 CAMERA: Image path: ${result.files.single.path}');
        print('🔥 CAMERA: File size: ${result.files.single.size} bytes');

        Get.snackbar('Berhasil', 'Foto berhasil dipilih dari galeri');
      } else {
        print('🔥 CAMERA: ❌ No image selected');
      }
    } catch (e) {
      print('🔥 CAMERA: ❌ Error picking image: $e');
      Get.snackbar('Error', 'Gagal memilih foto: $e');
    }
  }

  // ENHANCED: Show camera view with switch camera button
  void showCameraView() {
    print('🔥 CAMERA: Showing camera view...');

    if (!isCameraInitialized.value) {
      print('🔥 CAMERA: ❌ Camera not initialized');
      Get.snackbar('Error', 'Kamera belum siap');
      return;
    }

    Get.dialog(
      Dialog(
        child: Container(
          height: Get.height * 0.8,
          width: Get.width * 0.9,
          child: Column(
            children: [
              // Camera preview with overlay info
              Expanded(
                child: Stack(
                  children: [
                    CameraPreview(cameraController!),

                    // Camera info overlay
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isFrontCamera.value
                              ? '📱 Kamera Depan'
                              : '📷 Kamera Belakang',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Switch camera button (if multiple cameras available)
                    if (cameras != null && cameras!.length > 1)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: switchCamera,
                            icon: const Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print('🔥 CAMERA: Camera view cancelled');
                        Get.back();
                      },
                      child: const Text('Batal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: takePhoto,
                      child:
                          Text(isFrontCamera.value ? 'Selfie' : 'Ambil Foto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Check In with Real GPS Validation
  Future<void> checkIn() async {
    print('🔥 CHECK-IN: ===== STARTING CHECK IN =====');
    print('🔥 CHECK-IN: Attendance data: ${attendanceData.value}');
    print('🔥 CHECK-IN: Shift data: ${attendanceData.value?.shift}');

    // Check if GPS is ready
    if (!isGpsReady) {
      print('🔥 CHECK-IN: ❌ GPS not ready');
      Get.dialog(
        AlertDialog(
          title: const Text('GPS Belum Siap'),
          content: Text(locationError.value.isNotEmpty
              ? locationError.value
              : 'GPS belum terdeteksi. Pastikan GPS aktif dan izin lokasi telah diberikan.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                refreshLocation();
              },
              child: const Text('Refresh GPS'),
            ),
          ],
        ),
      );
      return;
    }

    // Validate location first
    if (locationConfig.value?.settings.enableLocationValidation == true) {
      if (!isLocationValid.value) {
        print('🔥 CHECK-IN: ❌ Location not valid');
        Get.dialog(
          AlertDialog(
            title: const Text('Lokasi Tidak Valid'),
            content: Text(locationValidationResult.value?.message ??
                'Anda berada di luar area kantor'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  showOfficeLocationsDialog();
                },
                child: const Text('Lihat Lokasi Kantor'),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (selectedImage.value == null) {
      print('🔥 CHECK-IN: ❌ No photo selected');
      Get.snackbar('Error', 'Foto diperlukan untuk check in');
      return;
    }

    if (attendanceData.value?.shift == null) {
      print('🔥 CHECK-IN: ❌ No shift data, refreshing...');
      await getTodayAttendance(); // Refresh data

      if (attendanceData.value?.shift == null) {
        print('🔥 CHECK-IN: ❌ Still no shift data after refresh');
        Get.snackbar('Error',
            'Data shift tidak tersedia. Silakan refresh atau hubungi admin.');
        return;
      }
    }

    try {
      isCheckingIn.value = true;
      print('🔥 CHECK-IN: Starting check-in process...');

      final token = await _getToken();

      if (token == null) {
        print('🔥 CHECK-IN: ❌ No token found');
        Get.snackbar('Error', 'Token tidak ditemukan');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstant.checkIn),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['latitude'] = currentLatitude.value.toString();
      request.fields['longitude'] = currentLongitude.value.toString();
      request.fields['shift_id'] = attendanceData.value!.shift!.id.toString();

      print('🔥 CHECK-IN: Request fields:');
      print('🔥 CHECK-IN: - latitude: ${currentLatitude.value}');
      print('🔥 CHECK-IN: - longitude: ${currentLongitude.value}');
      print('🔥 CHECK-IN: - shift_id: ${attendanceData.value!.shift!.id}');
      print('🔥 CHECK-IN: - photo: ${selectedImage.value!.path}');

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          selectedImage.value!.path,
        ),
      );

      print('🔥 CHECK-IN: Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔥 CHECK-IN: Response status: ${response.statusCode}');
      print('🔥 CHECK-IN: Response body: ${response.body}');

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success']) {
        print('🔥 CHECK-IN: ✅ Check-in successful');
        Get.snackbar(
          'Berhasil',
          jsonResponse['message'] ?? 'Check in berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        selectedImage.value = null;
        await getTodayAttendance();
      } else {
        print('🔥 CHECK-IN: ❌ Check-in failed');
        Get.snackbar('Error', jsonResponse['message'] ?? 'Check in gagal');
      }
    } catch (e) {
      print('🔥 CHECK-IN: ❌ Exception: $e');
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isCheckingIn.value = false;
      print('🔥 CHECK-IN: ===== CHECK IN FINISHED =====');
    }
  }

  // Check Out with Real GPS Validation
  Future<void> checkOut() async {
    print('🔥 CHECK-OUT: ===== STARTING CHECK OUT =====');

    // Check if GPS is ready
    if (!isGpsReady) {
      print('🔥 CHECK-OUT: ❌ GPS not ready');
      Get.dialog(
        AlertDialog(
          title: const Text('GPS Belum Siap'),
          content: Text(locationError.value.isNotEmpty
              ? locationError.value
              : 'GPS belum terdeteksi. Pastikan GPS aktif dan izin lokasi telah diberikan.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                refreshLocation();
              },
              child: const Text('Refresh GPS'),
            ),
          ],
        ),
      );
      return;
    }

    // Validate location first
    if (locationConfig.value?.settings.enableLocationValidation == true) {
      if (!isLocationValid.value) {
        print('🔥 CHECK-OUT: ❌ Location not valid');
        Get.dialog(
          AlertDialog(
            title: const Text('Lokasi Tidak Valid'),
            content: Text(locationValidationResult.value?.message ??
                'Anda berada di luar area kantor'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  showOfficeLocationsDialog();
                },
                child: const Text('Lihat Lokasi Kantor'),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (selectedImage.value == null) {
      print('🔥 CHECK-OUT: ❌ No photo selected');
      Get.snackbar('Error', 'Foto diperlukan untuk check out');
      return;
    }

    try {
      isCheckingOut.value = true;
      print('🔥 CHECK-OUT: Starting check-out process...');

      final token = await _getToken();

      if (token == null) {
        print('🔥 CHECK-OUT: ❌ No token found');
        Get.snackbar('Error', 'Token tidak ditemukan');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstant.checkOut),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['latitude'] = currentLatitude.value.toString();
      request.fields['longitude'] = currentLongitude.value.toString();

      print('🔥 CHECK-OUT: Request fields:');
      print('🔥 CHECK-OUT: - latitude: ${currentLatitude.value}');
      print('🔥 CHECK-OUT: - longitude: ${currentLongitude.value}');
      print('🔥 CHECK-OUT: - photo: ${selectedImage.value!.path}');

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          selectedImage.value!.path,
        ),
      );

      print('🔥 CHECK-OUT: Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔥 CHECK-OUT: Response status: ${response.statusCode}');
      print('🔥 CHECK-OUT: Response body: ${response.body}');

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success']) {
        print('🔥 CHECK-OUT: ✅ Check-out successful');
        Get.snackbar(
          'Berhasil',
          jsonResponse['message'] ?? 'Check out berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        selectedImage.value = null;
        await getTodayAttendance();
      } else {
        print('🔥 CHECK-OUT: ❌ Check-out failed');
        Get.snackbar('Error', jsonResponse['message'] ?? 'Check out gagal');
      }
    } catch (e) {
      print('🔥 CHECK-OUT: ❌ Exception: $e');
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isCheckingOut.value = false;
      print('🔥 CHECK-OUT: ===== CHECK OUT FINISHED =====');
    }
  }

  // Show image picker dialog
  void showImagePickerDialog() {
    print('🔥 CAMERA: Showing image picker dialog...');

    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isFrontCamera.value ? Icons.camera_front : Icons.camera_alt,
                color: Colors.blue,
              ),
              title: Text(
                  isFrontCamera.value ? 'Kamera Depan (Selfie)' : 'Kamera'),
              subtitle: Text(cameras != null && cameras!.length > 1
                  ? 'Tap untuk ganti kamera'
                  : 'Ambil foto dengan kamera'),
              onTap: () {
                print('🔥 CAMERA: Camera option selected');
                Get.back();
                showCameraView();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Galeri'),
              subtitle: const Text('Pilih dari galeri foto'),
              onTap: () {
                print('🔥 CAMERA: Gallery option selected');
                Get.back();
                pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show shift info dialog
  void showShiftInfoDialog() {
    final shift = attendanceData.value?.shift;

    if (shift == null) {
      Get.snackbar('Info', 'Data shift tidak tersedia');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Informasi Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Shift: ${shift.nama}'),
            const SizedBox(height: 8),
            Text('Jam Masuk: ${shift.jamMasuk}'),
            Text('Jam Keluar: ${shift.jamKeluar}'),
            Text('Toleransi: ${shift.toleransiMenit} menit'),
            const SizedBox(height: 16),
            const Text('Waktu Check-in yang diizinkan:'),
            Text(getCheckInTimeInfo()),
            const SizedBox(height: 8),
            const Text('Waktu Check-out:'),
            Text(getCheckOutTimeInfo()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Method untuk validasi waktu check-in (harus sesuai shift)
  bool canCheckInNow() {
    final shift = attendanceData.value?.shift;
    if (shift == null) return false;

    final now = TimeOfDay.fromDateTime(DateTime.now());

    try {
      // Parse jam masuk shift
      final jamMasukParts = shift.jamMasuk.split(':');
      final jamMasuk = TimeOfDay(
          hour: int.parse(jamMasukParts[0]),
          minute: int.parse(jamMasukParts[1]));

      // Hitung waktu mulai check-in (jam masuk - toleransi)
      final toleransiMenit = shift.toleransiMenit ?? 0;
      final jamMulaiCheckIn = _subtractMinutes(jamMasuk, toleransiMenit);

      // Hitung waktu akhir check-in (jam masuk + toleransi)
      final jamAkhirCheckIn = _addMinutes(jamMasuk, toleransiMenit);

      // Cek apakah waktu sekarang dalam rentang check-in
      return _isTimeInRange(now, jamMulaiCheckIn, jamAkhirCheckIn);
    } catch (e) {
      print('🔥 TIME: Error parsing check-in time: $e');
      return false;
    }
  }

  // Method untuk validasi waktu check-out (bisa kapan saja setelah check-in)
  bool canCheckOutNow() {
    final attendance = attendanceData.value;
    if (attendance == null) return false;

    // Bisa check-out kapan saja asal sudah check-in
    return attendance.sudahCheckIn && attendance.dapatCheckOut;
  }

  // Method untuk mendapatkan info waktu check-in
  String getCheckInTimeInfo() {
    final shift = attendanceData.value?.shift;
    if (shift == null) return 'Data shift tidak tersedia';

    try {
      final toleransiMenit = shift.toleransiMenit ?? 0;
      final jamMasukParts = shift.jamMasuk.split(':');
      final jamMasuk = TimeOfDay(
          hour: int.parse(jamMasukParts[0]),
          minute: int.parse(jamMasukParts[1]));

      final jamMulai = _subtractMinutes(jamMasuk, toleransiMenit);
      final jamAkhir = _addMinutes(jamMasuk, toleransiMenit);

      return 'Check-in: ${_formatTimeOfDay(jamMulai)} - ${_formatTimeOfDay(jamAkhir)}';
    } catch (e) {
      return 'Error: ${shift.jamMasuk}';
    }
  }

  // Method untuk mendapatkan info waktu check-out
  String getCheckOutTimeInfo() {
    final attendance = attendanceData.value;
    if (attendance == null) return 'Belum check-in';

    if (!attendance.sudahCheckIn) {
      return 'Check-out: Setelah check-in';
    }

    return 'Check-out: Kapan saja (sudah check-in)';
  }

  // Method untuk cek apakah waktu dalam rentang
  bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    // Handle case jika melewati tengah malam
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  // Method untuk menambah menit ke TimeOfDay
  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    final hours = (totalMinutes ~/ 60) % 24;
    final mins = totalMinutes % 60;
    return TimeOfDay(hour: hours, minute: mins);
  }

  // Method untuk mengurangi menit dari TimeOfDay
  TimeOfDay _subtractMinutes(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute - minutes;
    final hours = totalMinutes < 0
        ? ((totalMinutes + 1440) ~/ 60) % 24
        : // Handle negative (previous day)
        (totalMinutes ~/ 60) % 24;
    final mins =
        totalMinutes < 0 ? (totalMinutes + 1440) % 60 : totalMinutes % 60;
    return TimeOfDay(hour: hours, minute: mins);
  }

  // Method untuk format TimeOfDay ke string
  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Format time
  String formatTime(String? time) {
    if (time == null) return '-';
    try {
      final parts = time.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (e) {
      return time;
    }
  }

  // Get status color
  Color getStatusColor(String? status) {
    switch (status) {
      case 'hadir':
        return Colors.green;
      case 'terlambat':
        return Colors.orange;
      case 'tidak_hadir':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String getStatusText(String? status) {
    switch (status) {
      case 'hadir':
        return 'Hadir';
      case 'terlambat':
        return 'Terlambat';
      case 'tidak_hadir':
        return 'Tidak Hadir';
      case 'menunggu':
        return 'Menunggu Approval';
      default:
        return 'Belum Absen';
    }
  }

  // Location helpers (Real GPS) - CLEAN GETTERS
  String get currentLocationText {
    if (!isAutoTrackingActive.value) {
      return '🔄 Memulai tracking GPS...\nMohon tunggu sebentar';
    }

    if (locationError.value.isNotEmpty) {
      return '❌ ${locationError.value}';
    }

    if (currentLatitude.value == 0.0 && currentLongitude.value == 0.0) {
      return '📍 Menunggu sinyal GPS...\nPastikan GPS aktif';
    }

    final result = locationValidationResult.value;
    if (result != null) {
      final timeAgo = _getTimeAgoText();
      return '${result.message}\n'
          'Akurasi: ${locationAccuracy.value.toStringAsFixed(0)}m • $timeAgo';
    }

    final timeAgo = _getTimeAgoText();
    return 'GPS: ${currentLatitude.value.toStringAsFixed(6)}, ${currentLongitude.value.toStringAsFixed(6)}\n'
        'Akurasi: ${locationAccuracy.value.toStringAsFixed(0)}m • $timeAgo';
  }

  String _getTimeAgoText() {
    final now = DateTime.now();
    final diff = now.difference(lastLocationUpdate.value);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}d yang lalu';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m yang lalu';
    } else {
      return '${diff.inHours}j yang lalu';
    }
  }

  String get locationStatusText {
    if (!isAutoTrackingActive.value) return 'Starting...';
    if (locationError.value.isNotEmpty) return 'GPS Error';
    if (currentLatitude.value == 0.0 && currentLongitude.value == 0.0)
      return 'Menunggu GPS';

    final result = locationValidationResult.value;
    if (result == null) return 'Checking...';
    return result.isValid ? 'Area Valid ✓' : 'Di Luar Area ✗';
  }

  Color get locationStatusColor {
    if (!isAutoTrackingActive.value) return Colors.blue;
    if (locationError.value.isNotEmpty) return Colors.orange;
    if (currentLatitude.value == 0.0 && currentLongitude.value == 0.0)
      return Colors.grey;

    final result = locationValidationResult.value;
    if (result == null) return Colors.grey;
    return result.isValid ? Colors.green : Colors.red;
  }

  // Check if GPS is ready for attendance
  bool get isGpsReady {
    final ready = hasLocationPermission.value &&
        currentLatitude.value != 0.0 &&
        currentLongitude.value != 0.0 &&
        locationError.value.isEmpty &&
        isAutoTrackingActive.value;

    return ready;
  }

  // ENHANCED: Get camera info text for UI
  String get cameraInfoText {
    if (!isCameraInitialized.value) {
      return 'Kamera belum siap';
    }

    if (cameraError.value.isNotEmpty) {
      return 'Error: ${cameraError.value}';
    }

    final cameraType = isFrontCamera.value ? 'Depan (Selfie)' : 'Belakang';
    final switchAvailable = cameras != null && cameras!.length > 1;

    return 'Kamera $cameraType${switchAvailable ? ' • Tap untuk ganti' : ''}';
  }

  // ENHANCED: Get camera status color
  Color get cameraStatusColor {
    if (!isCameraInitialized.value || cameraError.value.isNotEmpty) {
      return Colors.red;
    }
    return isFrontCamera.value ? Colors.blue : Colors.green;
  }
}
