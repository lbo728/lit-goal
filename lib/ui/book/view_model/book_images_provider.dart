import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/book_image_service.dart';
import '../../../domain/models/book_image.dart';

final bookImageServiceProvider = Provider<BookImageService>((ref) {
  return BookImageService();
});

class BookImagesNotifier extends StateNotifier<AsyncValue<List<BookImage>>> {
  BookImagesNotifier(this._service, this._bookId)
      : super(const AsyncValue.loading()) {
    loadImages();
  }

  final BookImageService _service;
  final String _bookId;

  Future<void> loadImages() async {
    try {
      state = const AsyncValue.loading();
      final images = await _service.getBookImages(_bookId);
      state = AsyncValue.data(images);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addImage(File imageFile, {String? caption}) async {
    try {
      final newImage = await _service.uploadAndSaveImage(imageFile, _bookId,
          caption: caption);
      if (newImage != null) {
        final currentImages = state.value ?? [];
        state = AsyncValue.data([newImage, ...currentImages]);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> deleteImage(BookImage image) async {
    try {
      final success = await _service.deleteImage(image);
      if (success) {
        final currentImages = state.value ?? [];
        final updatedImages =
            currentImages.where((img) => img.id != image.id).toList();
        state = AsyncValue.data(updatedImages);
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadImages();
  }
}

final bookImagesProvider = StateNotifierProvider.family<BookImagesNotifier,
    AsyncValue<List<BookImage>>, String>(
  (ref, bookId) {
    final service = ref.watch(bookImageServiceProvider);
    return BookImagesNotifier(service, bookId);
  },
);
