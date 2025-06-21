import 'package:get/get.dart';

import '../controllers/leave_request_controller.dart';

class LeaveRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveRequestController>(
      () => LeaveRequestController(),
    );
  }
}
