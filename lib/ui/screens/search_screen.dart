import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
import '../../services/favorites_service.dart';
import '../../services/game_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/game_card.dart';
import '../widgets/search_bar_widget.dart';

class SearchScreen extends HookWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService.instance;
    final gameService = useMemoized(GameService.new);
    final favorites = useListenable(favoritesService.favoritesNotifier);
    final query = useState('');//texto digitado
    final results = useState<List<Game>>([]);//resultado da busca
    final isLoading = useState(false);// se esta buscando
    final error = useState<String?>(null);//erro da busca
    final size = MediaQuery.sizeOf(context);

    useEffect(() {
      final trimmedQuery = query.value.trim();
      if (trimmedQuery.isEmpty) {
        results.value = [];
        isLoading.value = false;
        error.value = null;
        return null;
      }

      var disposed = false;
      final timer = Timer(const Duration(milliseconds: 400), () async {//O app espera 400ms depois que o usuário para de digitar antes de chamar a API
        isLoading.value = true;
        error.value = null;
        try {
          final games = await gameService.searchGames(trimmedQuery);
          if (!disposed) {
            results.value = games;
          }
        } on GameServiceException catch (exception) {
          if (!disposed) {
            error.value = exception.message;
            results.value = [];
          }
        } finally {
          if (!disposed) {
            isLoading.value = false;
          }
        }
      });

      return () {
        disposed = true;
        timer.cancel();
      };
    }, [query.value]);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      bottomNavigationBar: const AppBottomNav(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = size.width >= 640;
          final width = constraints.maxWidth > 700
              ? 700.0
              : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchBarWidget(onChanged: (value) => query.value = value),//quando o usuario digita, query.value muda
                    const SizedBox(height: 18),
                    Expanded(
                      child: _SearchResults(
                        query: query.value,
                        results: results.value,
                        favorites: favorites.value,
                        isWide: isWide,
                        isLoading: isLoading.value,
                        error: error.value,
                        onFavoritePressed: favoritesService.toggleFavorite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.results,
    required this.favorites,
    required this.isWide,
    required this.isLoading,
    required this.error,
    required this.onFavoritePressed,
  });

  final String query;
  final List<Game> results;
  final List<Game> favorites;
  final bool isWide;
  final bool isLoading;
  final String? error;
  final ValueChanged<Game> onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return const _StateMessage(
        icon: Icons.search,
        message: 'Digite um titulo para pesquisar jogos.',
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (error != null) {
      return _StateMessage(icon: Icons.warning_amber, message: error!);
    }

    if (results.isEmpty) {
      return const _StateMessage(
        icon: Icons.block,
        message: 'Nenhum jogo encontrado para essa busca.',
      );
    }

    return GridView.builder(
      itemCount: results.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        childAspectRatio: isWide ? 0.68 : 0.64,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final game = results[index];
        return GameCard(
          game: game,
          isFavorite: favorites.any((favorite) => favorite.id == game.id),
          onTap: () => Get.toNamed('/game', arguments: game.id),
          onFavoritePressed: () => onFavoritePressed(game),
        );
      },
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
