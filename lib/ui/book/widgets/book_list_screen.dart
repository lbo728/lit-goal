import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/book.dart';
import '../../core/ui/book_image_widget.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('독서 목록'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        scrolledUnderElevation: 0,
      ),
      body: userId == null
          ? const SizedBox.shrink()
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('books')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', userId)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('목록을 불러오지 못했습니다: ${snapshot.error}'),
                  );
                }
                final rows = snapshot.data ?? [];
                final books = rows.map((e) => Book.fromJson(e)).toList();
                if (books.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: books.map(_buildBookCard).toList(),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '아직 시작한 독서가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    final daysPassed = DateTime.now().difference(book.startDate).inDays;
    final totalDays = book.targetDate.difference(book.startDate).inDays;
    final progressPercentage =
        totalDays > 0 ? (daysPassed / totalDays * 100).clamp(0, 100) : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(book: book),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: BookImageWidget(
                  imageUrl: book.imageUrl,
                  iconSize: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'D-${daysPassed + 1} (${progressPercentage.toStringAsFixed(0)}% 진행)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.currentPage}/${book.totalPages}페이지',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
