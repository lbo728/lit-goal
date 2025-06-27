import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lit_goal/views/screens/book_detail_screen.dart';
import 'package:lit_goal/views/screens/reading_start_screen.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            _bookService.hasBooks ? _buildBookContent() : _buildEmptyContent(),
      ),
    );
  }

  Widget _buildEmptyContent() {
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
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 20),
                  SizedBox(width: 8),
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

  Widget _buildBookContent() {
    final Book? latestBook = _bookService.latestBook;
    if (latestBook == null) return _buildEmptyContent();

    // 진행 상황 계산 (시작일부터 현재까지의 일수)
    final daysPassed = DateTime.now().difference(latestBook.startDate).inDays;
    final totalDays =
        latestBook.targetDate.difference(latestBook.startDate).inDays;
    final progressPercentage =
        totalDays > 0 ? (daysPassed / totalDays * 100).clamp(0, 100) : 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailScreen(
                      title: latestBook.title,
                      currentPage: latestBook.currentPage,
                      totalPages: latestBook.totalPages,
                      bookCode: "D-${daysPassed + 1}",
                      imageUrl:
                          latestBook.imageUrl ?? 'assets/images/book-cover.jpg',
                    ),
                  ),
                );
              },
              child: Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: latestBook.imageUrl != null
                      ? Image.asset(
                          latestBook.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.book,
                                size: 60,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.book,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              latestBook.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${latestBook.currentPage}페이지 / ${latestBook.totalPages}페이지',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'D-${daysPassed + 1} (${progressPercentage.toStringAsFixed(0)}% 진행)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '오늘 메모',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  if (index == 3) {
                    return GestureDetector(
                      onTap: () {},
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
            ),
          ],
        ),
      ),
    );
  }
}
