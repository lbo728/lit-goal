import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:collection';

class ReadingChartScreen extends StatelessWidget {
  const ReadingChartScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchUserProgressHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final response = await Supabase.instance.client
        .from('reading_progress_history')
        .select('page, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: true);
    return (response as List)
        .map((e) => {
              'page': e['page'] as int,
              'created_at': DateTime.parse(e['created_at'] as String),
            })
        .toList();
  }

  List<Map<String, dynamic>> aggregateByDate(List<Map<String, dynamic>> data) {
    final SplayTreeMap<DateTime, int> dateToPage = SplayTreeMap();
    for (final entry in data) {
      final date = DateTime(entry['created_at'].year, entry['created_at'].month,
          entry['created_at'].day);
      final page = entry['page'] as int;
      dateToPage[date] =
          (dateToPage[date] ?? 0) < page ? page : dateToPage[date]!;
    }

    int lastPage = 0;
    final result = <Map<String, dynamic>>[];
    for (final entry in dateToPage.entries) {
      lastPage = entry.value > lastPage ? entry.value : lastPage;
      result.add({'date': entry.key, 'page': lastPage});
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 독서 상태'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchUserProgressHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('진행률 불러오기 실패');
              }
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return const Text('진행률 기록이 없습니다.');
              }
              final aggregated = aggregateByDate(data);
              final spots = aggregated.asMap().entries.map((entry) {
                final idx = entry.key;
                final page = entry.value['page'] as int;
                return FlSpot(idx.toDouble(), page.toDouble());
              }).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '날짜별 누적 페이지',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= aggregated.length)
                                  return const SizedBox();
                                final date =
                                    aggregated[idx]['date'] as DateTime;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    '${date.month}/${date.day}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                              interval: (aggregated.length / 4)
                                  .ceilToDouble()
                                  .clamp(1, 999),
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
