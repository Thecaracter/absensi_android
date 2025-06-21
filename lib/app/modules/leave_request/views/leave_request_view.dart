import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/leave_request_controller.dart';

class LeaveRequestView extends GetView<LeaveRequestController> {
  const LeaveRequestView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LeaveRequestView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'LeaveRequestView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
