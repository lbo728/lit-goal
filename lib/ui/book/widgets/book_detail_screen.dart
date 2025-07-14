import 'package:flutter/material.dart';
import '../../../domain/models/book.dart';
import '../../../data/services/book_service.dart';
import '../../core/ui/book_image_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';

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
  int? _todayStartPage;
  int? _todayTargetPage;

  bool get _todayGoalAchieved =>
      _todayTargetPage != null &&
      _currentBook.currentPage >= _todayTargetPage!;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
    _todayStartPage = _currentBook.startDate.day;
    _todayTargetPage = _currentBook.targetDate.day;
  }

  Future<void> _showUpdatePageDialog() async {
    final TextEditingController controller = TextEditingController(
      text: _currentBook.currentPage.toString(),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '현재 페이지 업데이트',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text('총 ${_currentBook.totalPages} 페이지'),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '현재 페이지',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final page = int.tryParse(controller.text);
                          if (page != null &&
                              page >= 0 &&
                              page <= _currentBook.totalPages) {
                            Navigator.pop(context);
                            _updateCurrentPage(page);
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
                ],
              ),
            ),
          ),
        );
      },
    );
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

  Future<List<Map<String, dynamic>>> fetchBookImages(String bookId) async {
    final response = await Supabase.instance.client
        .from('book_images')
        .select('id, image_url, caption')
        .eq('book_id', bookId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => {
              'id': e['id'] as String,
              'image_url': e['image_url'] as String,
              'caption': e['caption'] as String? ?? '',
            })
        .where((e) => e['image_url']!.isNotEmpty)
        .toList();
  }

  Future<void> _deleteBookImage(String imageId, String imageUrl) async {
    final storage = Supabase.instance.client.storage;
    final bucketPath =
        imageUrl.split('/storage/v1/object/public/book-images/').last;
    await storage.from('book-images').remove([bucketPath]);
    await Supabase.instance.client
        .from('book_images')
        .delete()
        .eq('id', imageId);
    setState(() {});
  }

  void _confirmDeleteImage(String imageId, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 삭제'),
        content: const Text('정말 이미지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBookImage(imageId, imageUrl);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadBookImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final fileName = 'book_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final storage = Supabase.instance.client.storage;
    await storage.from('book-images').uploadBinary(fileName, bytes,
        fileOptions: const FileOptions(upsert: true));

    final publicUrl = storage.from('book-images').getPublicUrl(fileName);

    if (!mounted) return;

    final captionController = TextEditingController();
    final pageController = TextEditingController();

    final caption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('페이지 및 메모 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '페이지 번호'),
            ),
            TextField(
              controller: captionController,
              decoration: const InputDecoration(labelText: '간단한 메모'),
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
              final page = int.tryParse(pageController.text);
              if (page != null) {
                Navigator.pop(context, 'Page ${pageController.text}: ${captionController.text}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('유효한 페이지 번호를 입력해주세요.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (caption != null && caption.isNotEmpty) {
      await Supabase.instance.client.from('book_images').insert({
        'book_id': _currentBook.id,
        'image_url': publicUrl,
        'caption': caption,
      });
    }

    setState(() {});
  }

  void _showAddImageBottomSheet() {
    final isCameraAvailable = !kIsWeb &&
        (Platform.isAndroid || Platform.isIOS) &&
        (Platform.isAndroid || (Platform.isIOS && !Platform.isMacOS));
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라 촬영하기'),
                enabled: isCameraAvailable && !Platform.isIOS ? true : false,
                onTap: isCameraAvailable && !Platform.isIOS
                    ? () async {
                        Navigator.pop(context);
                        await _pickAndUploadBookImage(ImageSource.camera);
                      }
                    : () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('시뮬레이터에서는 카메라를 사용할 수 없습니다.'),
                          ),
                        );
                      },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('라이브러리에서 가져오기'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndUploadBookImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTodayGoalSheet() {
    final startController =
        TextEditingController(text: _todayStartPage?.toString() ?? '');
    final endController =
        TextEditingController(text: _todayTargetPage?.toString() ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('오늘의 분량 설정',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: startController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '시작 페이지'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: endController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '목표 페이지'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final start = int.tryParse(startController.text);
                  final end = int.tryParse(endController.text);
                  if (start != null && end != null && start < end) {
                    setState(() {
                      _todayStartPage = start;
                      _todayTargetPage = end;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('저장'),
              ),
            ],
          ),
        );
      },
    );
  }

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

  double _calculateAveragePagesPerDay() {
    final daysSinceStart = DateTime.now().difference(_currentBook.startDate).inDays;
    if (daysSinceStart <= 0) {
      return _currentBook.currentPage.toDouble();
    }
    return _currentBook.currentPage / daysSinceStart;
  }

  String _predictCompletionDate() {
    final avgPages = _calculateAveragePagesPerDay();
    if (avgPages <= 0) {
      return "독서를 시작해보세요!";
    }
    final remainingPages = _currentBook.totalPages - _currentBook.currentPage;
    if (remainingPages <= 0) {
      return "완독을 축하합니다!";
    }
    final remainingDays = (remainingPages / avgPages).ceil();
    final predictedDate = DateTime.now().add(Duration(days: remainingDays));

    if (_currentBook.targetDate == null) {
      return "${predictedDate.month}월 ${predictedDate.day}일에 완독할 수 있어요.";
    }

    final difference = _currentBook.targetDate.difference(predictedDate).inDays;

    if (difference == 0) {
      return "목표일에 맞춰 완독할 수 있어요!";
    } else if (difference > 0) {
      return "목표일보다 $difference일 빠르게 완독할 수 있어요!";
    } else {
      return "목표일에 맞추려면 하루에 ${(remainingPages / (_currentBook.targetDate.difference(DateTime.now()).inDays + 1)).toStringAsFixed(1)}페이지씩 더 읽어야 해요.";
    }
  }

  Widget _buildReadingPaceInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일 평균 ${_calculateAveragePagesPerDay().toStringAsFixed(1)} 페이지를 읽고 있어요',
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _predictCompletionDate(),
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 책 커버
                    Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[100]!,
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
                    const SizedBox(width: 16),
                    // 주요 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목 + 상태 뱃지
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  _currentBook.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Builder(
                                builder: (context) {
                                  String status;
                                  Color badgeColor;
                                  Color textColor;
                                  if (_currentBook.currentPage >=
                                          _currentBook.totalPages &&
                                      _currentBook.totalPages > 0) {
                                    status = '완독';
                                    badgeColor = Colors.green.withOpacity(0.12);
                                    textColor = Colors.green[700]!;
                                  } else {
                                    status = '독서 중';
                                    badgeColor = Colors.blue.withOpacity(0.12);
                                    textColor = Colors.blue;
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          if (_currentBook.author != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _currentBook.author!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'D-${(_currentBook.targetDate != null) ? (_currentBook.targetDate.difference(DateTime.now()).inDays + 1) : '?'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                '독서 시작일: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _currentBook.startDate
                                      .toString()
                                      .substring(0, 10)
                                      .replaceAll('-', '.'),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('목표 완료일: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              Expanded(
                                child: Text(
                                  _currentBook.targetDate != null
                                      ? _currentBook.targetDate
                                          .toString()
                                          .substring(0, 10)
                                          .replaceAll('-', '.')
                                      : '미설정',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _currentBook.targetDate ??
                                        DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _currentBook = _currentBook.copyWith(
                                          targetDate: picked);
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 32),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: Text(
                                  _currentBook.targetDate == null
                                      ? '설정하기'
                                      : '변경하기',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                '총 페이지: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _currentBook.totalPages.toString(),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Text('오늘의 분량: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              if (_todayStartPage != null &&
                                  _todayTargetPage != null)
                                Text(
                                    '$_todayStartPage ~ $_todayTargetPage 페이지'),
                              if (_todayStartPage == null ||
                                  _todayTargetPage == null)
                                const Text(
                                  '미설정',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              const SizedBox(
                                width: 8,
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 80,
                                ),
                                child: ElevatedButton(
                                  onPressed: _showTodayGoalSheet,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(0, 32),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text(
                                    '변경하기',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 달성 여부 자동 계산
                          Row(
                            children: [
                              const Text('달성 여부: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  )),
                              Icon(
                                _todayGoalAchieved
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _todayGoalAchieved
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(_todayGoalAchieved ? '달성' : '미달성',
                                  style: TextStyle(
                                    color: _todayGoalAchieved
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildReadingPaceInfo(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                LinearProgressIndicator(
                  value: (_currentBook.totalPages > 0)
                      ? (_currentBook.currentPage / _currentBook.totalPages)
                          .clamp(0.0, 1.0)
                      : 0.0,
                  minHeight: 16,
                  backgroundColor: Colors.blue.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _currentBook.totalPages > 0
                          ? '${((_currentBook.currentPage / _currentBook.totalPages) * 100).toStringAsFixed(0)}% (${_currentBook.currentPage}페이지 / ${_currentBook.totalPages}페이지)'
                          : '0% (0페이지 / 0페이지)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '인상적인 페이지 기록',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchBookImages(_currentBook.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('이미지 불러오기 실패');
                    }
                    final images = snapshot.data ?? [];
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: images.length + 1,
                      itemBuilder: (context, index) {
                        if (index == images.length) {
                          return GestureDetector(
                            onTap: _showAddImageBottomSheet,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '새로운 사진\n추가하기',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final img = images[index];
                        final imgUrl = img['image_url']!;
                        final imgId = img['id']!;
                        final caption = img['caption'] as String? ?? '';

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.network(imgUrl),
                                    const SizedBox(height: 8),
                                    Text(caption),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('닫기'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _confirmDeleteImage(imgId, imgUrl),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (caption.isNotEmpty)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Text(
                                      caption,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '진행률 히스토리',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchProgressHistory(_currentBook.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
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
                      height: 180,
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
                                  final date =
                                      data[idx]['created_at'] as DateTime;
                                  return Text(
                                    '${date.month}/${date.day}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                                interval: (data.length / 4)
                                    .ceilToDouble()
                                    .clamp(1, 999),
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
                const SizedBox(height: 24),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('책 정보 삭제'),
                        content: const Text(
                            '정말 이 책 정보를 삭제하시겠습니까?\n삭제 후 복구할 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('삭제',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      final success =
                          await _bookService.deleteBook(_currentBook.id!);
                      if (success && mounted) {
                        Navigator.pop(context);
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('책 삭제에 실패했습니다.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('책 정보 삭제하기'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_todayStartPage == null || _todayTargetPage == null)
                          ? _showTodayGoalSheet
                          : _showUpdatePageDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    (_todayStartPage == null || _todayTargetPage == null)
                        ? '오늘의 분량을 설정해주세요'
                        : '현재 페이지 업데이트',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
