import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/product.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = _resolveBaseUrl(baseUrl);

  static String _resolveBaseUrl(String? configured) {
    const fromEnvironment = String.fromEnvironment('API_BASE_URL');
    final selected = configured ?? fromEnvironment;
    return (selected.trim().isEmpty ? _defaultBaseUrl : selected.trim())
        .replaceAll(RegExp(r'/+$'), '');
  }

  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8080',
      TargetPlatform.iOS => 'http://127.0.0.1:8080',
      _ => 'http://localhost:8080',
    };
  }

  final http.Client _client;
  final String baseUrl;

  Future<List<MenuCategory>> fetchCategories() async {
    final data = await _getList('/categories');
    return data.map(MenuCategory.fromJson).toList(growable: false);
  }

  Future<List<Product>> fetchProducts() async {
    final data = await _getList('/products?available=true');
    return data.map(Product.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> createOrder({
    required String customerName,
    String? customerPhone,
    required String orderType,
    String? address,
    String? notes,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$baseUrl/orders'),
          headers: const {'content-type': 'application/json; charset=utf-8'},
          body: jsonEncode({
            'customer_name': customerName,
            'customer_phone': _emptyToNull(customerPhone),
            'order_type': orderType,
            if (address != null && address.trim().isNotEmpty) 'address': address.trim(),
            if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
            'payment_method': paymentMethod,
            'items': items,
          }),
        )
        .timeout(const Duration(seconds: 20));
    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(decoded), statusCode: response.statusCode);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('A API retornou uma confirmação inválida.');
    }
    return decoded;
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final response = await _client
        .get(Uri.parse('$baseUrl$path'))
        .timeout(const Duration(seconds: 15));
    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(decoded), statusCode: response.statusCode);
    }
    if (decoded is! List) {
      throw const ApiException('A API retornou um formato inesperado.');
    }
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Object? _decodeResponse(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw ApiException('Resposta inválida da API (HTTP ${response.statusCode}).');
    }
  }

  String _errorMessage(Object? decoded) {
    if (decoded is Map && decoded['error'] is String) {
      return decoded['error'] as String;
    }
    return 'Não foi possível comunicar com a API.';
  }

  String? _emptyToNull(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
