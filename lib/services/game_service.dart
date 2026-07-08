import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_keys.dart';
import '../models/game.dart';

class GameService {
  static const _baseUrl = 'https://api.rawg.io/api';
  static const _timeout = Duration(seconds: 12);

  Future<List<Game>> fetchGamesByCategory(String genreSlug) async { //buscar jogos por categoria
    final json = await _get(
      '/games',
      query: {
        'ordering': '-added',
        'page_size': '20',
        if (genreSlug.isNotEmpty) 'genres': genreSlug,
      },
    );
    final results = json['results'];
    if (results is! List) {
      return const [];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(Game.fromJson)
        .toList(growable: false);
  }

  Future<List<Game>> searchGames(String query) async {//buscar jogos pelo texto digitado
    final json = await _get(
      '/games',
      query: {'search': query, 'page_size': '20'},
    );
    final results = json['results'];
    if (results is! List) {
      return const [];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(Game.fromJson)
        .toList(growable: false);
  }

  Future<Game> fetchGameDetail(int id) async { //buscar os detalhes de um jogo especifico
    final json = await _get('/games/$id');
    return Game.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(//Esse método monta a URL, adiciona a chave da API, faz a chamada HTTP e trata erros
    String path, {
    Map<String, String> query = const {},
  }) async {
    if (ApiKeys.rawgApiKey.isEmpty) {
      throw const GameServiceException(
        'Configure a API key da RAWG com --dart-define=RAWG_API_KEY=sua_key.',
      );
    }

    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: {'key': ApiKeys.rawgApiKey, ...query});

    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw const GameServiceException('Resposta invalida da RAWG.');
      }

      throw GameServiceException(_messageForStatus(response.statusCode));
    } on TimeoutException {
      throw const GameServiceException('Tempo esgotado ao acessar a RAWG.');
    } on http.ClientException {
      throw const GameServiceException('Sem conexao com a RAWG.');
    } on FormatException {
      throw const GameServiceException('Resposta invalida da RAWG.');
    }
  }

  String _messageForStatus(int statusCode) {
    return switch (statusCode) {
      401 || 403 => 'API key da RAWG invalida ou sem permissao.',
      404 => 'Jogo nao encontrado.',
      429 => 'Limite de requisicoes da RAWG atingido. Tente novamente depois.',
      >= 500 => 'RAWG indisponivel no momento. Tente novamente depois.',
      _ => 'Erro ao carregar dados da RAWG ($statusCode).',
    };
  }
}

class GameServiceException implements Exception {// erros do serviço
  const GameServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
