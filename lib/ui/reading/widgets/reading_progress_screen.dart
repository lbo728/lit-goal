import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReadingProgressScreen extends StatelessWidget {
  final String bookId;
  const ReadingProgressScreen({super.key, required this.bookId});

  Future<List<Map<String, dynamic>>> fetchProgressHistory(String bookId) async {
    final response = await Supabase.instance.client
        .from('reading_progress_history')
        .select('page, created_at')
        .eq('book_id', bookId)
        .order('created_at', ascending: true);
    return (response as List)
        .map((e) => {
              'page': e['page'] as int,
              'created_at': DateTime.parse(e['created_at'] as String),
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('진행률 히스토리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchProgressHistory(bookId),
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
            final spots = data.asMap().entries.map((entry) {
              final idx = entry.key;
              final page = entry.value['page'] as int;
              return FlSpot(idx.toDouble(), page.toDouble());
            }).toList();
            return SizedBox(
              height: 240,
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
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length)
                            return const SizedBox();
                          final date = data[idx]['created_at'] as DateTime;
                          return Text(
                            '${date.month}/${date.day}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        interval:
                            (data.length / 4).ceilToDouble().clamp(1, 999),
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
