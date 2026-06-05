// lib/data/datasources/network/jsonplaceholder_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/post_item.dart';

class JsonPlaceholderService {
  static const _tag = 'JsonPlaceholderService';
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  JsonPlaceholderService({http.Client? client})
      : _client = client ?? http.Client();

  /// GET /posts/{id}
  Future<PostItem> getPost(int id) async {
    final url = Uri.parse('$_baseUrl/posts/$id');
    AppLogger.info('GET $url', tag: _tag);

    final response = await _client.get(url);

    AppLogger.debug('Respuesta GET: ${response.statusCode}', tag: _tag);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PostItem.fromJson(json);
    } else {
      AppLogger.error(
          'Error GET posts/$id → ${response.statusCode}', tag: _tag);
      throw Exception('Error al obtener post $id: ${response.statusCode}');
    }
  }

  /// PUT /posts/{id}
  Future<PostItem> updatePost(PostItem post) async {
    final url = Uri.parse('$_baseUrl/posts/${post.id}');
    AppLogger.info('PUT $url', tag: _tag);

    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(post.toJson()),
    );

    AppLogger.debug('Respuesta PUT: ${response.statusCode}', tag: _tag);

    if (response.statusCode == 200) {
      AppLogger.info('PUT exitoso para post ${post.id}', tag: _tag);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PostItem.fromJson(json);
    } else {
      AppLogger.error(
          'Error PUT posts/${post.id} → ${response.statusCode}', tag: _tag);
      throw Exception(
          'Error al actualizar post ${post.id}: ${response.statusCode}');
    }
  }
}