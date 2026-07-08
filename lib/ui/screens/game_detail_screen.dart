import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
import '../../services/favorites_service.dart';
import '../../services/game_service.dart';

class GameDetailScreen extends HookWidget {
  const GameDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = useMemoized(GameService.new);
    final favoritesService = FavoritesService.instance;
    final favorites = useListenable(favoritesService.favoritesNotifier);
    final game = useState<Game?>(null); //jogo carregado
    final isLoading = useState(true);// se está carregando detalhes
    final error = useState<String?>(null);//erro ao buscar detalhes
    final gameId = _gameIdFromArgument(Get.arguments);

    useEffect(() {
      var disposed = false;

      Future<void> loadGame() async {
        if (gameId == null) {
          error.value = 'Jogo invalido.';
          isLoading.value = false;
          return;
        }

        isLoading.value = true;
        error.value = null;
        try {
          final loadedGame = await gameService.fetchGameDetail(gameId);
          if (!disposed) {
            game.value = loadedGame;
          }
        } on GameServiceException catch (exception) {
          if (!disposed) {
            error.value = exception.message;
          }
        } finally {
          if (!disposed) {
            isLoading.value = false;
          }
        }
      }

      loadGame();
      return () => disposed = true;
    }, [gameId]);

    return Scaffold(
      appBar: AppBar(title: Text(game.value?.title ?? 'Detalhes')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 700
              ? 700.0
              : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: width,
              child: _DetailContent(
                game: game.value,
                isLoading: isLoading.value,
                error: error.value,
                isFavorite: game.value == null
                    ? false
                    : favorites.value.any(
                        (favorite) => favorite.id == game.value!.id,
                      ),
                onFavoritePressed: game.value == null
                    ? null
                    : () => favoritesService.toggleFavorite(game.value!),
              ),
            ),
          );
        },
      ),
    );
  }

  int? _gameIdFromArgument(Object? argument) {
    if (argument is int) {
      return argument;
    }
    if (argument is String) {
      return int.tryParse(argument);
    }
    return null;
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.game,
    required this.isLoading,
    required this.error,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  final Game? game;
  final bool isLoading;
  final String? error;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (error != null) {
      return _StateMessage(icon: Icons.warning_amber, message: error!);
    }

    final currentGame = game;
    if (currentGame == null) {
      return const _StateMessage(
        icon: Icons.block,
        message: 'Jogo nao encontrado.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _Cover(imageUrl: currentGame.backgroundImage),
          ),
          const SizedBox(height: 16),
          Text(
            currentGame.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                text: 'Nota ${currentGame.rating?.toStringAsFixed(1) ?? 'N/A'}',
              ),
              if (currentGame.released != null)
                _Chip(text: currentGame.released!),
              for (final genre in currentGame.genres) _Chip(text: genre),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onFavoritePressed,
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            label: Text(isFavorite ? 'Remover dos favoritos' : 'Favoritar'),
          ),
          const SizedBox(height: 20),
          Text('Descricao', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            currentGame.description?.trim().isNotEmpty == true
                ? currentGame.description!.trim()
                : 'Sem descricao disponivel.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.78),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _CoverPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
      placeholder: (context, url) => const _CoverPlaceholder(),
      errorWidget: (context, url, error) => const _CoverPlaceholder(),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      color: AppColors.secondary,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_esports,
        color: AppColors.primary,
        size: 52,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.white)),
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
