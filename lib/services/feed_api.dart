import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ghost_money_world/config/api_config.dart';
import 'package:mime/mime.dart';
import 'package:ghost_money_world/models/feed_comment.dart';
import 'package:ghost_money_world/models/feed_interactions.dart';
import 'package:ghost_money_world/models/feed_video.dart';

class FeedUploadSession {
  final String url;
  final String uploadId;

  const FeedUploadSession({required this.url, required this.uploadId});

  factory FeedUploadSession.fromJson(Map<String, dynamic> json) {
    return FeedUploadSession(
      url: json['url']?.toString() ?? '',
      uploadId: json['uploadId']?.toString() ?? '',
    );
  }
}

class FeedUploadResult {
  final String id;
  final String title;
  final String status;
  final String? playbackId;

  const FeedUploadResult({
    required this.id,
    required this.title,
    required this.status,
    this.playbackId,
  });

  factory FeedUploadResult.fromJson(Map<String, dynamic> json) {
    return FeedUploadResult(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'processing',
      playbackId: json['playbackId']?.toString(),
    );
  }
}

class FeedApiException implements Exception {
  final String message;
  final int? statusCode;

  const FeedApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class FeedApi {
  FeedApi({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<String?> _token() async {
    return FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _token();
    if (token == null || token.isEmpty) {
      throw const FeedApiException('Unauthorized', statusCode: 401);
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<FeedVideo>> getFeed({int limit = 20}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/feed',
        queryParameters: {'limit': limit.clamp(1, 50)},
      );
      final data = response.data;
      if (data == null) return [];
      return data
          .whereType<Map>()
          .map((e) => FeedVideo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'Failed to fetch feed');
    }
  }

  Future<FeedInteractions> getInteractions(String videoId) async {
    try {
      final token = await _token();
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/feed/$videoId/interactions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      final data = response.data;
      if (data == null) return const FeedInteractions();
      return FeedInteractions.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'Failed to load interactions');
    }
  }

  Future<void> like(String videoId) async {
    await _postAction(videoId, {'action': 'like'}, auth: true);
  }

  Future<void> unlike(String videoId) async {
    await _postAction(videoId, {'action': 'unlike'}, auth: true);
  }

  Future<FeedComment> comment(String videoId, String text) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/feed/$videoId/interactions',
        data: {'action': 'comment', 'text': text.trim()},
        options: Options(headers: await _authHeaders()),
      );
      final commentJson = response.data?['comment'];
      if (commentJson is! Map) {
        throw const FeedApiException('Invalid comment response');
      }
      return FeedComment.fromJson(Map<String, dynamic>.from(commentJson));
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'Failed to post comment');
    }
  }

  Future<void> trackShare(String videoId) async {
    await _postAction(videoId, {'action': 'share'}, auth: false);
  }

  /// Step 1: backend returns Mux direct-upload URL.
  Future<FeedUploadSession> createFeedUploadSession() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/feed/direct-upload',
        options: Options(headers: await _authHeaders()),
      );
      final data = response.data;
      if (data == null || data['url'] == null || data['uploadId'] == null) {
        throw const FeedApiException('Invalid upload session response');
      }
      return FeedUploadSession.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'Failed to start upload');
    }
  }

  /// Step 2: upload raw video bytes to Mux.
  Future<void> uploadVideoToMux(
    String muxUploadUrl,
    File file, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    final mime = lookupMimeType(file.path) ?? 'video/mp4';
    final uploadDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(minutes: 15),
        receiveTimeout: const Duration(minutes: 15),
      ),
    );
    try {
      await uploadDio.put<void>(
        muxUploadUrl,
        data: bytes,
        options: Options(
          headers: {'Content-Type': mime},
          contentType: mime,
        ),
        onSendProgress: onProgress,
      );
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'Failed to upload video to Mux');
    }
  }

  /// Step 3: register video in feed after Mux upload.
  Future<FeedUploadResult> saveFeedVideo({
    required String uploadId,
    required String title,
    String description = '',
    int? videoWidth,
    int? videoHeight,
  }) async {
    try {
      final body = <String, dynamic>{
        'uploadId': uploadId,
        'title': title.trim(),
        'description': description.trim(),
        'aspectRatio': '9:16',
      };
      if (videoWidth != null && videoHeight != null) {
        body['videoWidth'] = videoWidth;
        body['videoHeight'] = videoHeight;
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/feed/upload',
        data: body,
        options: Options(
          headers: await _authHeaders(),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const FeedApiException('Invalid save response');
      }
      return FeedUploadResult.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'Failed to save feed video');
    }
  }

  /// Full flow: session → Mux PUT → save to feed.
  Future<FeedUploadResult> uploadFeedVideo({
    required File file,
    required String title,
    String description = '',
    void Function(String step)? onStep,
    void Function(int sent, int total)? onUploadProgress,
  }) async {
    onStep?.call('Preparing upload…');
    final session = await createFeedUploadSession();
    onStep?.call('Uploading video…');
    await uploadVideoToMux(
      session.url,
      file,
      onProgress: onUploadProgress,
    );
    onStep?.call('Saving to feed…');
    return saveFeedVideo(
      uploadId: session.uploadId,
      title: title,
      description: description,
    );
  }

  Future<void> _postAction(
    String videoId,
    Map<String, dynamic> body, {
    required bool auth,
  }) async {
    try {
      await _dio.post<void>(
        '/api/feed/$videoId/interactions',
        data: body,
        options: Options(
          headers: auth ? await _authHeaders() : const {
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'Failed to update interactions');
    }
  }

  FeedApiException _mapDioError(DioException e, {required String fallback}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return FeedApiException(
        data['error'].toString(),
        statusCode: status,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return FeedApiException(
        'Network error. Check your connection.',
        statusCode: status,
      );
    }
    return FeedApiException(fallback, statusCode: status);
  }
}
