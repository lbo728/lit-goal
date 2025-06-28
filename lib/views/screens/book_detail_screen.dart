import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lit_goal/views/screens/reading_start_screen.dart';
import '../../models/book.dart';
import '../widgets/book_image_widget.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '독서 상세',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BookImageWidget(
                      imageUrl: widget.book.imageUrl,
                      iconSize: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.book.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.book.author != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.book.author!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${widget.book.currentPage}페이지 / ${widget.book.totalPages}페이지',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'D-${DateTime.now().difference(widget.book.startDate).inDays + 1} (${((widget.book.currentPage / widget.book.totalPages) * 100).toStringAsFixed(0)}% 진행)',
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
                                                  title: widget.book.title,
                                                  totalPages:
                                                      widget.book.totalPages,
                                                  imageUrl:
                                                      widget.book.imageUrl,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
