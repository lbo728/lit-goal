import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/models/book_image.dart';
import '../../reading/widgets/reading_start_screen.dart';

class ImageGridWidget extends StatelessWidget {
  final String? bookId;
  final String? bookTitle;
  final int? totalPages;
  final String? bookImageUrl;
  final AsyncValue<List<BookImage>> imagesAsync;
  final Function(ImageSource) onPickImage;
  final Function(BookImage) onDeleteImage;
  final VoidCallback? onReadingStart;

  const ImageGridWidget({
    super.key,
    required this.bookId,
    this.bookTitle,
    this.totalPages,
    this.bookImageUrl,
    required this.imagesAsync,
    required this.onPickImage,
    required this.onDeleteImage,
    this.onReadingStart,
  });

  Future<void> _showImageSourceDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    Navigator.pop(context);
                    onPickImage(ImageSource.camera);
                  },
                ),
                const Text('카메라'),
              ],
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () {
                    Navigator.pop(context);
                    onPickImage(ImageSource.gallery);
                  },
                ),
                const Text('갤러리'),
              ],
            ),
            if (onReadingStart != null &&
                bookTitle != null &&
                totalPages != null)
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.book),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReadingStartScreen(
                            title: bookTitle!,
                            totalPages: totalPages!,
                            imageUrl: bookImageUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  const Text('독서 시작'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return imagesAsync.when(
      data: (images) {
        final totalItems = images.length + 1;
        const maxDisplayItems = 6;
        final displayItems =
            totalItems > maxDisplayItems ? maxDisplayItems : totalItems;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: displayItems,
          itemBuilder: (context, index) {
            // 추가 버튼 또는 더보기 버튼
            if (index == images.length ||
                (totalItems > maxDisplayItems &&
                    index == maxDisplayItems - 1)) {
              return GestureDetector(
                onTap: () => _showImageSourceDialog(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.add,
                        color: Colors.blue,
                        size: 24,
                      ),
                      if (totalItems > maxDisplayItems &&
                          index == maxDisplayItems - 1)
                        Text(
                          '+${totalItems - maxDisplayItems}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            // 이미지 아이템
            final image = images[index];
            return GestureDetector(
              onLongPress: () => onDeleteImage(image),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: image.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onDeleteImage(image),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('이미지 로드 실패: $error'),
      ),
    );
  }
}
