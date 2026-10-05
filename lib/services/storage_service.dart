import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file from [File] (mobile) and return download URL.
  Future<String?> uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final task = ref.putFile(file);

      task.snapshotEvents.listen((snap) {
        if (onProgress != null && snap.totalBytes > 0) {
          onProgress(snap.bytesTransferred / snap.totalBytes);
        }
      });

      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.uploadFile: $e');
      return null;
    }
  }

  /// Upload bytes (for web) and return download URL.
  Future<String?> uploadBytes({
    required Uint8List bytes,
    required String path,
    String contentType = 'image/jpeg',
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: contentType);
      final task = ref.putData(bytes, metadata);

      task.snapshotEvents.listen((snap) {
        if (onProgress != null && snap.totalBytes > 0) {
          onProgress(snap.bytesTransferred / snap.totalBytes);
        }
      });

      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.uploadBytes: $e');
      return null;
    }
  }

  /// Build a unique storage path for a thumbnail
  String thumbnailPath(String courseId, String fileName) {
    return '${AppConstants.thumbnailsPath}/$courseId/$fileName';
  }

  /// Build a unique storage path for a profile image
  String profileImagePath(String userId, String fileName) {
    return '${AppConstants.profileImagesPath}/$userId/$fileName';
  }

  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('StorageService.deleteFile: $e');
    }
  }
}
