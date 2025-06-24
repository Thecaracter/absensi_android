import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sistem_presensi/app/controller/theme_controller.dart';
import 'package:sistem_presensi/app/utils/color_constant.dart';
import 'package:sistem_presensi/app/data/models/leave_model.dart';
import '../controllers/leave_request_controller.dart';

class LeaveRequestView extends GetView<LeaveRequestController> {
  const LeaveRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    Get.put(LeaveRequestController());

    return Obx(() => Scaffold(
          backgroundColor: themeController.isDark
              ? const Color(0xFF1A1D29)
              : AppColors.backgroundLightMode,
          appBar: AppBar(
            title: Text(
              'Pengajuan Izin',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: themeController.isDark
                ? const Color(0xFF1A1D29)
                : AppColors.primary,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () => _showFilterModal(context),
                icon: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                ),
                tooltip: 'Filter',
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refreshData,
            child: Column(
              children: [
                // Statistics Card dengan data berguna
                _buildStatsCard(themeController),

                // Filter Chips
                _buildFilterChips(themeController),

                // Leave Requests List
                Expanded(child: _buildLeaveRequestsList(themeController)),
              ],
            ),
          ),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 100), // Margin untuk FAB
            child: FloatingActionButton.extended(
              onPressed: () => _showLeaveRequestModal(context, themeController),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Ajukan Izin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor:
                  const Color(0xFFFF8A00), // Orange color from design
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ));
  }

  Widget _buildStatsCard(ThemeController themeController) {
    return Obx(() {
      if (controller.isLoadingStats.value) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: themeController.isDark
                ? const Color(0xFF2A2D3A)
                : AppColors.surfaceLightMode,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8A00)),
          ),
        );
      }

      final stats = controller.leaveStats.value;
      if (stats == null) {
        // Tampilkan card sederhana jika stats tidak ada
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A00), Color(0xFFFF6B00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8A00).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.assignment,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengajuan Izin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${controller.leaveRequests.length} pengajuan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8A00), Color(0xFFFF6B00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8A00).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Statistik Izin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    stats.totalPengajuan.toString(),
                    Colors.white,
                    Icons.list_alt,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    stats.menunggu.toString(),
                    Colors.white.withOpacity(0.9),
                    Icons.pending,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Disetujui',
                    stats.disetujui.toString(),
                    Colors.white.withOpacity(0.9),
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Sisa Kuota',
                    stats.sisaKuota.toString(),
                    stats.sisaKuota > 5 ? Colors.white : Colors.orange[200]!,
                    Icons.event_busy,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ThemeController themeController) {
    return Obx(() {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterChip(
              'Semua',
              controller.selectedStatus.value == null,
              () => controller.filterByStatus(null),
              themeController,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Menunggu',
              controller.selectedStatus.value == 'menunggu',
              () => controller.filterByStatus('menunggu'),
              themeController,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Disetujui',
              controller.selectedStatus.value == 'disetujui',
              () => controller.filterByStatus('disetujui'),
              themeController,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Ditolak',
              controller.selectedStatus.value == 'ditolak',
              () => controller.filterByStatus('ditolak'),
              themeController,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap,
      ThemeController themeController) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected
              ? Colors.white
              : themeController.isDark
                  ? Colors.white70
                  : const Color(0xFF64748B),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor:
          themeController.isDark ? const Color(0xFF2A2D3A) : Colors.grey[100],
      selectedColor: const Color(0xFFFF8A00),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: selected
            ? const Color(0xFFFF8A00)
            : themeController.isDark
                ? const Color(0xFF374151)
                : Colors.grey[300]!,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildLeaveRequestsList(ThemeController themeController) {
    return Obx(() {
      if (controller.isLoading.value && controller.leaveRequests.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF8A00)),
        );
      }

      if (controller.hasError.value && controller.leaveRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color:
                    themeController.isDark ? Colors.white30 : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 16,
                  color: themeController.isDark
                      ? Colors.white60
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.fetchLeaveRequests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      }

      if (controller.leaveRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color:
                    themeController.isDark ? Colors.white30 : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada pengajuan izin',
                style: TextStyle(
                  fontSize: 16,
                  color: themeController.isDark
                      ? Colors.white60
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap tombol + untuk membuat pengajuan baru',
                style: TextStyle(
                  fontSize: 14,
                  color: themeController.isDark
                      ? Colors.white70
                      : Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              controller.hasMoreData.value &&
              !controller.isLoadingMore.value) {
            controller.loadMoreData();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
              16, 16, 16, 160), // Increased bottom padding
          itemCount: controller.leaveRequests.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.leaveRequests.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Color(0xFFFF8A00)),
                ),
              );
            }

            final leaveRequest = controller.leaveRequests[index];
            return _buildLeaveRequestCard(
                context, leaveRequest, themeController);
          },
        ),
      );
    });
  }

  Widget _buildLeaveRequestCard(BuildContext context, LeaveRequest leaveRequest,
      ThemeController themeController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeController.isDark ? const Color(0xFF2A2D3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeController.isDark
              ? const Color(0xFF374151)
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeController.isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              _showLeaveRequestDetail(context, leaveRequest, themeController),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        leaveRequest.jenisIzinText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: themeController.isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    _buildStatusChip(leaveRequest.status, themeController),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.calendar_today,
                  '${leaveRequest.tanggalMulaiFormatted} - ${leaveRequest.tanggalSelesaiFormatted}',
                  themeController,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  leaveRequest.durasiText,
                  themeController,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.description,
                  leaveRequest.alasan,
                  themeController,
                  maxLines: 2,
                ),
                if (leaveRequest.hasAttachment) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.attach_file,
                    'Ada lampiran',
                    themeController,
                    color: const Color(0xFFFF8A00),
                  ),
                ],
                if (leaveRequest.isPending &&
                    (leaveRequest.bisaDiedit ||
                        leaveRequest.bisaDibatalkan)) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (leaveRequest.bisaDiedit)
                        TextButton.icon(
                          onPressed: () => _showLeaveRequestModal(
                            context,
                            Get.find<ThemeController>(),
                            leaveRequest: leaveRequest,
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF8A00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      if (leaveRequest.bisaDiedit &&
                          leaveRequest.bisaDibatalkan)
                        const SizedBox(width: 8),
                      if (leaveRequest.bisaDibatalkan)
                        TextButton.icon(
                          onPressed: () => _showDeleteConfirmation(
                              context, leaveRequest, themeController),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Hapus'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String text, ThemeController themeController,
      {int maxLines = 1, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: color ??
              (themeController.isDark
                  ? Colors.white60
                  : const Color(0xFF6B7280)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color ??
                  (themeController.isDark
                      ? Colors.white70
                      : const Color(0xFF6B7280)),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, ThemeController themeController) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'disetujui':
        color = const Color(0xFF10B981);
        label = 'Disetujui';
        icon = Icons.check_circle;
        break;
      case 'ditolak':
        color = const Color(0xFFEF4444);
        label = 'Ditolak';
        icon = Icons.cancel;
        break;
      default:
        color = const Color(0xFFF59E0B);
        label = 'Menunggu';
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    showModalBottomSheet(
      context: context,
      backgroundColor:
          themeController.isDark ? const Color(0xFF2A2D3A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Color(0xFFFF8A00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter Pengajuan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: themeController.isDark
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Status:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: themeController.isDark
                    ? Colors.white
                    : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    _buildChoiceChip(
                        'Semua',
                        controller.selectedStatus.value == null,
                        () => controller.filterByStatus(null),
                        themeController),
                    _buildChoiceChip(
                        'Menunggu',
                        controller.selectedStatus.value == 'menunggu',
                        () => controller.filterByStatus('menunggu'),
                        themeController),
                    _buildChoiceChip(
                        'Disetujui',
                        controller.selectedStatus.value == 'disetujui',
                        () => controller.filterByStatus('disetujui'),
                        themeController),
                    _buildChoiceChip(
                        'Ditolak',
                        controller.selectedStatus.value == 'ditolak',
                        () => controller.filterByStatus('ditolak'),
                        themeController),
                  ],
                )),
            const SizedBox(height: 24),
            Text(
              'Tahun:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: themeController.isDark
                    ? Colors.white
                    : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<int>(
                  value: controller.selectedYear.value,
                  dropdownColor: themeController.isDark
                      ? const Color(0xFF2A2D3A)
                      : Colors.white,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: themeController.isDark
                            ? const Color(0xFF374151)
                            : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: themeController.isDark
                            ? const Color(0xFF374151)
                            : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8A00)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(
                    color: themeController.isDark
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
                  items: controller.availableYears.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (year) {
                    if (year != null) controller.filterByYear(year);
                  },
                )),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeController.isDark
                          ? Colors.white
                          : const Color(0xFF1F2937),
                      side: BorderSide(
                        color: themeController.isDark
                            ? const Color(0xFF374151)
                            : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool selected, VoidCallback onTap,
      ThemeController themeController) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected
              ? Colors.white
              : themeController.isDark
                  ? Colors.white
                  : const Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor:
          themeController.isDark ? const Color(0xFF1A1D29) : Colors.grey[100],
      selectedColor: const Color(0xFFFF8A00),
      side: BorderSide(
        color: selected
            ? const Color(0xFFFF8A00)
            : themeController.isDark
                ? const Color(0xFF374151)
                : Colors.grey[300]!,
      ),
    );
  }

  void _showLeaveRequestModal(
      BuildContext context, ThemeController themeController,
      {LeaveRequest? leaveRequest}) {
    final isEdit = leaveRequest != null;

    if (isEdit) {
      controller.loadLeaveRequestForEdit(leaveRequest);
    } else {
      controller.clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          themeController.isDark ? const Color(0xFF2A2D3A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A00).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEdit ? Icons.edit : Icons.add,
                          color: const Color(0xFFFF8A00),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEdit ? 'Edit Pengajuan Izin' : 'Ajukan Izin Baru',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: themeController.isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Jenis Izin
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedJenisIzin.value,
                        dropdownColor: themeController.isDark
                            ? const Color(0xFF2A2D3A)
                            : Colors.white,
                        decoration: _buildInputDecoration(
                          'Jenis Izin',
                          controller.jenisIzinError.value,
                          themeController,
                          icon: Icons.category,
                        ),
                        style: TextStyle(
                          color: themeController.isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                        items: JenisIzin.dropdownItems,
                        onChanged: (value) =>
                            controller.selectedJenisIzin.value = value,
                      )),
                  const SizedBox(height: 16),

                  // Tanggal Mulai
                  Obx(() => TextFormField(
                        controller: controller.tanggalMulaiController,
                        decoration: _buildInputDecoration(
                          'Tanggal Mulai',
                          controller.tanggalMulaiError.value,
                          themeController,
                          icon: Icons.calendar_today,
                        ),
                        style: TextStyle(
                          color: themeController.isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(
                            context, controller.tanggalMulaiController),
                      )),
                  const SizedBox(height: 16),

                  // Tanggal Selesai
                  Obx(() => TextFormField(
                        controller: controller.tanggalSelesaiController,
                        decoration: _buildInputDecoration(
                          'Tanggal Selesai',
                          controller.tanggalSelesaiError.value,
                          themeController,
                          icon: Icons.event,
                        ),
                        style: TextStyle(
                          color: themeController.isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(
                            context, controller.tanggalSelesaiController),
                      )),
                  const SizedBox(height: 16),

                  // Alasan
                  Obx(() => TextFormField(
                        controller: controller.alasanController,
                        decoration: _buildInputDecoration(
                          'Alasan',
                          controller.alasanError.value,
                          themeController,
                          icon: Icons.description,
                        ),
                        style: TextStyle(
                          color: themeController.isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                      )),
                  const SizedBox(height: 16),

                  // File Attachment
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.pickFile,
                              icon: const Icon(Icons.attach_file, size: 18),
                              label: const Text('Pilih Lampiran (Opsional)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF8A00),
                                side:
                                    const BorderSide(color: Color(0xFFFF8A00)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          if (controller.selectedFileName.value.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8A00).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFFFF8A00).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.description,
                                    size: 18,
                                    color: Color(0xFFFF8A00),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      controller.selectedFileName.value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFFF8A00),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: controller.removeFile,
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      )),
                  const SizedBox(height: 24),

                  // Buttons
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: themeController.isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                                side: BorderSide(
                                  color: themeController.isDark
                                      ? const Color(0xFF374151)
                                      : Colors.grey[300]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : () {
                                      if (isEdit) {
                                        controller.updateLeaveRequest(
                                            leaveRequest.id!);
                                      } else {
                                        controller.createLeaveRequest();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8A00),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: controller.isSubmitting.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(isEdit ? 'Update' : 'Ajukan'),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      String labelText, String errorText, ThemeController themeController,
      {IconData? icon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color:
            themeController.isDark ? Colors.white60 : const Color(0xFF6B7280),
      ),
      prefixIcon: icon != null
          ? Icon(
              icon,
              color: themeController.isDark
                  ? Colors.white60
                  : const Color(0xFF6B7280),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: themeController.isDark
              ? const Color(0xFF374151)
              : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: themeController.isDark
              ? const Color(0xFF374151)
              : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF8A00)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      errorText: errorText.isEmpty ? null : errorText,
      errorStyle: const TextStyle(color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _showLeaveRequestDetail(BuildContext context, LeaveRequest leaveRequest,
      ThemeController themeController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            themeController.isDark ? const Color(0xFF2A2D3A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFFFF8A00),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                leaveRequest.jenisIzinText,
                style: TextStyle(
                  color: themeController.isDark
                      ? Colors.white
                      : const Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Status', leaveRequest.statusText, themeController),
              _buildDetailRow('Tanggal Mulai',
                  leaveRequest.tanggalMulaiFormatted, themeController),
              _buildDetailRow('Tanggal Selesai',
                  leaveRequest.tanggalSelesaiFormatted, themeController),
              _buildDetailRow(
                  'Durasi', leaveRequest.durasiText, themeController),
              _buildDetailRow('Alasan', leaveRequest.alasan, themeController),
              _buildDetailRow('Tanggal Pengajuan',
                  leaveRequest.tanggalPengajuanFormatted, themeController),
              if (leaveRequest.disetujuiOleh != null &&
                  leaveRequest.disetujuiOleh!.isNotEmpty)
                _buildDetailRow('Disetujui Oleh', leaveRequest.disetujuiOleh!,
                    themeController),
              if (leaveRequest.tanggalPersetujuanFormatted != null &&
                  leaveRequest.tanggalPersetujuanFormatted!.isNotEmpty)
                _buildDetailRow('Tanggal Persetujuan',
                    leaveRequest.tanggalPersetujuanFormatted!, themeController),
              if (leaveRequest.catatanAdmin != null &&
                  leaveRequest.catatanAdmin!.isNotEmpty)
                _buildDetailRow('Catatan Admin', leaveRequest.catatanAdmin!,
                    themeController),
              if (leaveRequest.hasAttachment)
                _buildDetailRow('Lampiran', 'Ada lampiran', themeController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF8A00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: themeController.isDark
                    ? Colors.white60
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: themeController.isDark
                    ? Colors.white
                    : const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, LeaveRequest leaveRequest,
      ThemeController themeController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            themeController.isDark ? const Color(0xFF2A2D3A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                color: themeController.isDark
                    ? Colors.white
                    : const Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengajuan izin ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(
            color: themeController.isDark
                ? Colors.white70
                : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: themeController.isDark
                  ? Colors.white
                  : const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteLeaveRequest(leaveRequest.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final themeController = Get.find<ThemeController>();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF8A00),
              onPrimary: Colors.white,
              surface: themeController.isDark
                  ? const Color(0xFF2A2D3A)
                  : Colors.white,
              onSurface: themeController.isDark
                  ? Colors.white
                  : const Color(0xFF1F2937),
            ),
            dialogBackgroundColor:
                themeController.isDark ? const Color(0xFF2A2D3A) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }
}
