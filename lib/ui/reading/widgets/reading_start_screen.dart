import 'package:flutter/material.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/book.dart';
import '../../../data/services/book_service.dart';
import '../../../data/services/aladin_api_service.dart';
import '../../core/ui/book_image_widget.dart';

class ReadingStartScreen extends StatefulWidget {
  final String? title;
  final int? totalPages;
  final String? imageUrl;

  const ReadingStartScreen({
    super.key,
    this.title,
    this.totalPages,
    this.imageUrl,
  });

  @override
  State<ReadingStartScreen> createState() => _ReadingStartScreenState();
}

class _ReadingStartScreenState extends State<ReadingStartScreen> {
  final TextEditingController _titleController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _debounce;

  DateTime selectedDate = DateTime.now();
  DateTime targetDate = DateTime.now().add(const Duration(
    days: 14,
  ));

  List<BookSearchResult> _searchResults = [];
  bool _isSearching = false;
  BookSearchResult? _selectedBook;

  @override
  void initState() {
    super.initState();
    if (widget.title != null) {
      _titleController.text = widget.title!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = 1;
        });
      });
    }

    _titleController.addListener(() {
      final text = _titleController.text;
      if (_selectedBook != null) {
        setState(() => _selectedBook = null);
      }
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () {
        final query = text.trim();
        if (query.isEmpty) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
          return;
        }
        _searchBooks(query);
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchBooks(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await AladinApiService.searchBooks(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _selectBook(BookSearchResult book) {
    setState(() {
      _selectedBook = book;
    });
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentPage > 0) {
              _previousPage();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          '독서 시작하기',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildBookTitleInputPage(),
          _buildReadingSchedulePage(),
        ],
      ),
    );
  }

  Widget _buildBookTitleInputPage() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '책 이름을 입력해주세요.',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                onSubmitted: (_) {},
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              if (_isSearching)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final book = _searchResults[index];
                      final isSelected = _selectedBook != null &&
                          _isSameBook(_selectedBook!, book);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          selected: isSelected,
                          tileColor:
                              isSelected ? Colors.blue.withOpacity(0.06) : null,
                          leading: book.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    book.imageUrl!,
                                    width: 40,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 40,
                                        height: 60,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.book, size: 20),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 40,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.book, size: 20),
                                ),
                          title: Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            book.author,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (book.totalPages != null)
                                Text(
                                  '${book.totalPages}p',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                          onTap: () => _selectBook(book),
                        ),
                      );
                    },
                  ),
                )
              else if (_titleController.text.trim().isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      '검색 결과가 없습니다',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedBook != null ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '다음',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingSchedulePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 150,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BookImageWidget(
                    imageUrl: _selectedBook?.imageUrl ?? widget.imageUrl,
                    iconSize: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _selectedBook?.title ?? _titleController.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_selectedBook?.totalPages != null ||
                widget.totalPages != null) ...[
              Center(
                child: Text(
                  '${_selectedBook?.totalPages ?? widget.totalPages} 페이지',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            const Text(
              '독서 시작일',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '목표 마감일',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: targetDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != targetDate) {
                  setState(() {
                    targetDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${targetDate.year}년 ${targetDate.month}월 ${targetDate.day}일',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  final book = Book(
                    title: _selectedBook?.title ?? _titleController.text,
                    author: _selectedBook?.author,
                    startDate: selectedDate,
                    targetDate: targetDate,
                    imageUrl: _selectedBook?.imageUrl ?? widget.imageUrl,
                    totalPages:
                        _selectedBook?.totalPages ?? widget.totalPages ?? 0,
                  );
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final bookData = book.toJson();
                    bookData['user_id'] = userId;
                    final result =
                        await BookService().addBookWithUserId(bookData);
                    if (mounted) {
                      Navigator.pop(context);

                      if (result != null) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('독서 정보 저장에 실패했습니다.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '독서 시작',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameBook(BookSearchResult a, BookSearchResult b) {
    final sameTitle = a.title == b.title;
    final sameAuthor = a.author == b.author;
    final samePages = (a.totalPages ?? -1) == (b.totalPages ?? -1);
    final sameImage = (a.imageUrl ?? '') == (b.imageUrl ?? '');
    return sameTitle && sameAuthor && samePages && sameImage;
  }
}
