import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ghost_money_world/config/api_config.dart';
import 'package:ghost_money_world/models/feed_comment.dart';
import 'package:ghost_money_world/models/feed_interactions.dart';
import 'package:ghost_money_world/models/feed_video.dart';

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
