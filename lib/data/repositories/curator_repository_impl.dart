import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/image_resize.dart';
import '../../domain/entities/curator_recommendation.dart';
import '../../domain/repositories/curator_repository.dart';

/// Calls the recommend-photo Edge Function with resized base64 images.
class CuratorRepositoryImpl implements CuratorRepository {
  CuratorRepositoryImpl({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const int _maxWidth = 1024;

  @override
  Future<CuratorRecommendation> getRecommendation(
    List<List<int>> imageBytesList,
  ) async {
    if (imageBytesList.length < 2 || imageBytesList.length > 10) {
      throw CuratorException('Select between 2 and 10 photos.');
    }

    final images = <Map<String, String>>[];
    for (final bytes in imageBytesList) {
      final resized = resizeImageForCurator(
        Uint8List.fromList(bytes),
        maxWidth: _maxWidth,
      );
      if (resized == null)
        throw CuratorException('Could not process one or more images.');
      images.add({'base64': base64Encode(resized), 'mimeType': 'image/jpeg'});
    }

    final response = await _client.functions.invoke(
      'recommend-photo',
      body: {'images': images},
    );

    if (response.status != 200) {
      final msg = _errorMessage(response);
      throw CuratorException(msg);
    }

    final data = response.data as Map<String, dynamic>?;
    if (data == null) throw CuratorException('Empty response from Curator.');

    final index = data['recommendedIndex'] as int?;
    final caption = data['caption'] as String? ?? '';
    final vibe = data['vibe'] as String? ?? '';

    if (index == null || index < 0 || index >= imageBytesList.length) {
      throw CuratorException('Invalid recommended index from Curator.');
    }

    return CuratorRecommendation(
      recommendedIndex: index,
      caption: caption,
      vibe: vibe,
      recommendedImageBytes: imageBytesList[index],
    );
  }

  String _errorMessage(FunctionResponse response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'] as String?;
      final detail = data['detail'] as String?;
      if (error != null) return detail != null ? '$error: $detail' : error;
    }
    return response.status == 429
        ? 'Too many requests. Try again later.'
        : 'Curator request failed.';
  }
}

/// Thrown when the Curator request fails or input is invalid.
class CuratorException implements Exception {
  CuratorException(this.message);
  final String message;
  @override
  String toString() => message;
}
