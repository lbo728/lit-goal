import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/book_image.dart';

class BookImageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<String?> uploadImage(File imageFile, String bookId) async {
    try {
      final fileName = '${bookId}_${_uuid.v4()}.jpg';
      final path = 'book_images/$fileName';

      await _supabase.storage.from('book-images').upload(path, imageFile);

      final imageUrl = _supabase.storage.from('book-images').getPublicUrl(path);

      return imageUrl;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      return null;
    }
  }

  Future<BookImage?> saveImageMetadata(String bookId, String imageUrl,
      {String? caption}) async {
    try {
      final bookImage = BookImage(
        bookId: bookId,
        imageUrl: imageUrl,
        caption: caption,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('book_images')
          .insert(bookImage.toJson())
          .select()
          .single();

      return BookImage.fromJson(response);
    } catch (e) {
      print('이미지 메타데이터 저장 실패: $e');
      return null;
    }
  }

  Future<List<BookImage>> getBookImages(String bookId) async {
    try {
      final response = await _supabase
          .from('book_images')
          .select()
          .eq('book_id', bookId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => BookImage.fromJson(json))
          .toList();
    } catch (e) {
      print('이미지 목록 조회 실패: $e');
      return [];
    }
  }

  Future<bool> deleteImage(BookImage bookImage) async {
    try {
      final uri = Uri.parse(bookImage.imageUrl);
      final path = uri.path.split('/').last;
      final filePath = 'book_images/$path';

      await _supabase.storage.from('book-images').remove([filePath]);

      await _supabase.from('book_images').delete().eq('id', bookImage.id!);

      return true;
    } catch (e) {
      print('이미지 삭제 실패: $e');
      return false;
    }
  }

  Future<BookImage?> uploadAndSaveImage(File imageFile, String bookId,
      {String? caption}) async {
    try {
      final imageUrl = await uploadImage(imageFile, bookId);
      if (imageUrl == null) return null;

      final bookImage =
          await saveImageMetadata(bookId, imageUrl, caption: caption);
      return bookImage;
    } catch (e) {
      print('이미지 업로드 및 저장 실패: $e');
      return null;
    }
  }
}
