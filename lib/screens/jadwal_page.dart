import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

final dio = Dio();

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<dynamic> doctors = [];
  bool isLoading = true;

  Future<void> getHttp() async {
    try {
      final response = await dio.get(
        'http://192.168.167.141:8000/api/v1/schedules',
      );

      if (response.statusCode == 200) {
        setState(() {
          doctors = response.data['doctors'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getHttp();
  }

  Color _getDayColor(String day) {
    switch (day.toLowerCase()) {
      case 'senin':
        return Colors.blue.shade100;
      case 'selasa':
        return Colors.green.shade100;
      case 'rabu':
        return Colors.orange.shade100;
      case 'kamis':
        return Colors.purple.shade100;
      case 'jumat':
        return Colors.teal.shade100;
      case 'sabtu':
        return Colors.pink.shade100;
      case 'minggu':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: const Text(
          'Jadwal Dokter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              getHttp();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat jadwal dokter...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : doctors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Tidak ada data dokter",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: getHttp,
                  color: Colors.teal,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      final schedules = doctor['schedules'] as List<dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            childrenPadding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.teal.shade700,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              "${doctor['name']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.medical_services,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      doctor['specialty']?['name'] ?? "-",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${schedules.length} Jadwal",
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              ...schedules.map((schedule) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getDayColor(
                                        schedule['day_of_week']),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: schedule['is_active'] == 1
                                          ? Colors.green.shade200
                                          : Colors.red.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              schedule['day_of_week'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Colors.grey[700],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${schedule['start_time']} - ${schedule['end_time']}",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: schedule['is_active'] == 1
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              schedule['is_active'] == 1
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              schedule['is_active'] == 1
                                                  ? "Aktif"
                                                  : "Nonaktif",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}