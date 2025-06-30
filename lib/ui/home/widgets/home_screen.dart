import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../book/widgets/book_detail_screen.dart';
import '../../reading/widgets/reading_start_screen.dart';
import '../../../domain/models/book.dart';
import '../../../domain/models/book_image.dart';
import '../../core/ui/book_image_widget.dart';
import '../../core/ui/image_grid_widget.dart';
import '../view_model/home_view_model.dart';
import '../../book/view_model/book_images_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.Provider.of<HomeViewModel>(context, listen: false).loadBooks();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final homeViewModel =
            provider.Provider.of<HomeViewModel>(context, listen: false);
        final latestBook = homeViewModel.latestBook;

        if (latestBook?.id != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이미지를 업로드 중입니다...'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          final imageNotifier =
              ref.read(bookImagesProvider(latestBook!.id!).notifier);
          await imageNotifier.addImage(File(image.path));

          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이미지가 추가되었습니다!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 추가 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage(BookImage image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 삭제'),
        content: const Text('이 이미지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final homeViewModel = provider.Provider.of<HomeViewModel>(
        context,
        listen: false,
      );
      final latestBook = homeViewModel.latestBook;

      if (latestBook?.id != null) {
        final imageNotifier =
            ref.read(bookImagesProvider(latestBook!.id!).notifier);
        final success = await imageNotifier.deleteImage(image);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '이미지가 삭제되었습니다.' : '이미지 삭제에 실패했습니다.'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildReadingProgressCard(Book book, HomeViewModel viewModel) {
    final int remainingPages = book.totalPages - book.currentPage;
    final int remainingDays = () {
      final now = DateTime.now();
      final remaining = book.targetDate.difference(now).inDays;
      return remaining > 0 ? remaining : 0;
    }();
    final double progressPercentage =
        book.totalPages > 0 ? (book.currentPage / book.totalPages) * 100 : 0;
    final double dailyTarget = remainingDays > 0
        ? remainingPages / remainingDays
        : remainingPages.toDouble();
    final int totalDays = book.targetDate.difference(book.startDate).inDays + 1;
    final int elapsedDays =
        DateTime.now().difference(book.startDate).inDays + 1;

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
            const SizedBox(height: 16),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        progressPercentage >= 100 ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progressPercentage.toStringAsFixed(0)}% 완료',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '현재 페이지',
                    '${book.currentPage}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '남은 페이지',
                    '$remainingPages',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '전체 페이지',
                    '${book.totalPages}',
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '남은 일수',
                    '$remainingDays일',
                    remainingDays <= 3 ? Colors.red : Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '일일 목표',
                    '${dailyTarget.toStringAsFixed(0)}p',
                    dailyTarget > 50 ? Colors.red : Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '경과 일수',
                    '$elapsedDays일',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                            '${book.startDate.year}.${book.startDate.month}.${book.startDate.day}',
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
                            '${book.targetDate.year}.${book.targetDate.month}.${book.targetDate.day}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '총 $totalDays일 계획',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProgressMessageColor(
                  progressPercentage,
                  remainingDays,
                  dailyTarget,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getProgressMessageColor(
                    progressPercentage,
                    remainingDays,
                    dailyTarget,
                  ).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getProgressIcon(
                      progressPercentage,
                      remainingDays,
                      dailyTarget,
                    ),
                    color: _getProgressMessageColor(
                      progressPercentage,
                      remainingDays,
                      dailyTarget,
                    ),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getProgressMessage(
                        progressPercentage,
                        remainingDays,
                        dailyTarget,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getProgressMessageColor(
                          progressPercentage,
                          remainingDays,
                          dailyTarget,
                        ),
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
        const SizedBox(height: 4),
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

  Color _getProgressMessageColor(
      double progressPercentage, int remainingDays, double dailyTarget) {
    if (progressPercentage >= 100) return Colors.green;
    if (remainingDays <= 0) return Colors.red;
    if (dailyTarget > 50) return Colors.orange;
    return Colors.blue;
  }

  IconData _getProgressIcon(
      double progressPercentage, int remainingDays, double dailyTarget) {
    if (progressPercentage >= 100) return Icons.check_circle;
    if (remainingDays <= 0) return Icons.warning;
    if (dailyTarget > 50) return Icons.schedule;
    return Icons.trending_up;
  }

  String _getProgressMessage(
      double progressPercentage, int remainingDays, double dailyTarget) {
    if (progressPercentage >= 100) {
      return '🎉 독서 완료! 축하합니다!';
    } else if (remainingDays <= 0) {
      return '⚠️ 목표일이 지났습니다. 계획을 재조정해보세요.';
    } else if (dailyTarget > 50) {
      return '📚 일일 목표가 높습니다. 계획을 조정하는 것을 고려해보세요.';
    } else if (dailyTarget <= 10) {
      return '😊 무리 없는 페이스로 진행 중입니다!';
    } else {
      return '📖 꾸준히 읽어서 목표를 달성해보세요!';
    }
  }

  Widget _buildImagesGrid(Book book) {
    if (book.id == null) {
      return const SizedBox.shrink();
    }

    final imagesAsync = ref.watch(bookImagesProvider(book.id!));

    return ImageGridWidget(
      bookId: book.id,
      bookTitle: book.title,
      totalPages: book.totalPages,
      bookImageUrl: book.imageUrl,
      imagesAsync: imagesAsync,
      onPickImage: _pickImage,
      onDeleteImage: _deleteImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: provider.Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                viewModel.clearError();
              });
            }

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return viewModel.hasBooks
                ? _buildBookContent(viewModel)
                : _buildEmptyContent(viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyContent(HomeViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '새로운 독서를 시작해보세요!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadingStartScreen(),
                  ),
                );
                viewModel.loadBooks();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 20,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    '새 독서 시작',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookContent(HomeViewModel viewModel) {
    final Book? latestBook = viewModel.latestBook;
    if (latestBook == null) return _buildEmptyContent(viewModel);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(
                          book: latestBook,
                        ),
                      ),
                    );
                  },
                  child: Container(
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
                        imageUrl: latestBook.imageUrl,
                        iconSize: 80,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    latestBook.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (latestBook.author != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    latestBook.author!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(
                            book: latestBook,
                          ),
                        ),
                      );
                    },
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
                        '${latestBook.currentPage}페이지 / ${latestBook.totalPages}페이지 (탭하여 업데이트)',
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
          _buildReadingProgressCard(latestBook, viewModel),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '인상깊은 내용',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildImagesGrid(latestBook),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
