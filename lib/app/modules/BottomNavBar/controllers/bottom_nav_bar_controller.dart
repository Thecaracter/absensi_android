import 'package:get/get.dart';
import 'package:sistem_presensi/app/modules/home/controllers/home_controller.dart';
import 'package:sistem_presensi/app/modules/leave_request/controllers/leave_request_controller.dart';
import 'package:sistem_presensi/app/modules/profile/controllers/profile_controller.dart';

import '../../attendance/controllers/attendance_controller.dart';

class BottomNavBarController extends GetxController {
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;

      _refreshCurrentPage(index);
    }
  }

  void _refreshCurrentPage(int index) {
    switch (index) {
      case 0:
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>();
        }
        break;
      case 1:
        if (Get.isRegistered<AttendanceController>()) {
          Get.find<AttendanceController>();
        }
        break;
      case 2:
        if (Get.isRegistered<LeaveRequestController>()) {
          Get.find<LeaveRequestController>();
        }
        break;
      case 3:
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>();
        }
        break;
    }
  }

  void refreshCurrentPage() {
    _refreshCurrentPage(currentIndex.value);
  }
}
