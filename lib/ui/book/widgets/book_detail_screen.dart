import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../reading/widgets/reading_start_screen.dart';
import '../../../domain/models/book.dart';
import '../../../data/services/book_service.dart';
import '../../core/ui/book_image_widget.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookService _bookService = BookService();
  late Book _currentBook;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
  }

  int get _remainingPages => _currentBook.totalPages - _currentBook.currentPage;

  int get _remainingDays {
    final now = DateTime.now();
    final remaining = _currentBook.targetDate.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }

  double get _progressPercentage => _currentBook.totalPages > 0
      ? (_currentBook.currentPage / _currentBook.totalPages) * 100
      : 0;

  double get _dailyTarget => _remainingDays > 0
      ? _remainingPages / _remainingDays
      : _remainingPages.toDouble();

  int get _totalDays =>
      _currentBook.targetDate.difference(_currentBook.startDate).inDays + 1;

  int get _elapsedDays =>
      DateTime.now().difference(_currentBook.startDate).inDays + 1;

  Future<void> _showUpdatePageDialog() async {
    final TextEditingController controller = TextEditingController(
      text: _currentBook.currentPage.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('현재 페이지 업데이트'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('총 ${_currentBook.totalPages} 페이지'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '현재 페이지',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null &&
                  page >= 0 &&
                  page <= _currentBook.totalPages) {
                Navigator.pop(context, page);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('올바른 페이지 번호를 입력해주세요.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('업데이트'),
          ),
        ],
      ),
    );

    if (result != null && _currentBook.id != null) {
      _updateCurrentPage(result);
    }
  }

  Future<void> _updateCurrentPage(int newPage) async {
    try {
      final updatedBook =
          await _bookService.updateCurrentPage(_currentBook.id!, newPage);
      if (updatedBook != null) {
        setState(() {
          _currentBook = updatedBook;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('페이지가 업데이트되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('페이지 업데이트에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildReadingProgressCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '독서 분량 설정기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressPercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        _progressPercentage >= 100 ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_progressPercentage.toStringAsFixed(0)}% 완료',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '현재 페이지',
                    '${_currentBook.currentPage}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '남은 페이지',
                    '$_remainingPages',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '전체 페이지',
                    '${_currentBook.totalPages}',
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '남은 일수',
                    '$_remainingDays일',
                    _remainingDays <= 3 ? Colors.red : Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '일일 목표',
                    '${_dailyTarget.toStringAsFixed(0)}p',
                    _dailyTarget > 50 ? Colors.red : Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '경과 일수',
                    '$_elapsedDays일',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '시작일',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${_currentBook.startDate.year}.${_currentBook.startDate.month}.${_currentBook.startDate.day}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '목표일',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${_currentBook.targetDate.year}.${_currentBook.targetDate.month}.${_currentBook.targetDate.day}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    '총 $_totalDays일 계획',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProgressMessageColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getProgressMessageColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getProgressIcon(),
                    color: _getProgressMessageColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getProgressMessage(),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getProgressMessageColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getProgressMessageColor() {
    if (_progressPercentage >= 100) return Colors.green;
    if (_remainingDays <= 0) return Colors.red;
    if (_dailyTarget > 50) return Colors.orange;
    return Colors.blue;
  }

  IconData _getProgressIcon() {
    if (_progressPercentage >= 100) return Icons.check_circle;
    if (_remainingDays <= 0) return Icons.warning;
    if (_dailyTarget > 50) return Icons.schedule;
    return Icons.trending_up;
  }

  String _getProgressMessage() {
    if (_progressPercentage >= 100) {
      return '🎉 독서 완료! 축하합니다!';
    } else if (_remainingDays <= 0) {
      return '⚠️ 목표일이 지났습니다. 계획을 재조정해보세요.';
    } else if (_dailyTarget > 50) {
      return '📚 일일 목표가 높습니다. 계획을 조정하는 것을 고려해보세요.';
    } else if (_dailyTarget <= 10) {
      return '😊 무리 없는 페이스로 진행 중입니다!';
    } else {
      return '📖 꾸준히 읽어서 목표를 달성해보세요!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '독서 상세',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BookImageWidget(
                          imageUrl: _currentBook.imageUrl,
                          iconSize: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        _currentBook.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_currentBook.author != null) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        _currentBook.author!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: GestureDetector(
                        onTap: _showUpdatePageDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '${_currentBook.currentPage}페이지 / ${_currentBook.totalPages}페이지 (탭하여 업데이트)',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildReadingProgressCard(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 메모',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        if (index == 3) {
                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  height: 120,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.book),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReadingStartScreen(
                                                    title: _currentBook.title,
                                                    totalPages:
                                                        _currentBook.totalPages,
                                                    imageUrl:
                                                        _currentBook.imageUrl,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const Text('독서 시작'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.camera_alt),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          const Text('사진 추가'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.add,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                            ),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      },
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
}
