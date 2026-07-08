import 'package:flutter/foundation.dart';

import '../models/game.dart';

class FavoritesService {
  FavoritesService._();

  static final instance = FavoritesService._();

  final ValueNotifier<List<Game>> favoritesNotifier = ValueNotifier([]);// guarda os jogos favoritados(estado global)

  void toggleFavorite(Game game) {
    final list = List<Game>.from(favoritesNotifier.value);
    if (list.any((g) => g.id == game.id)) {
      list.removeWhere((g) => g.id == game.id);
    } else {
      list.add(game);
    }
    favoritesNotifier.value = list;
  } // adiciona ou remove o jogos da lista global 

  bool isFavorite(int gameId) {
    return favoritesNotifier.value.any((g) => g.id == gameId);
  } //verifica se um jogo esta favoritado
}
