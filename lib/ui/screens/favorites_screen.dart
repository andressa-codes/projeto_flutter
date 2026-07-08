import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../services/favorites_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/game_card.dart';

class FavoritesScreen extends HookWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService.instance;
    final favorites = useListenable(favoritesService.favoritesNotifier);//escuta os favoritos
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
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
                child: favorites.value.isEmpty //se não tiver favoritos (ou seja, vazio)
                    ? const _EmptyFavorites()
                    : GridView.builder(
                        itemCount: favorites.value.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 3 : 2,
                          childAspectRatio: isWide ? 0.68 : 0.64,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final game = favorites.value[index];
                          return GameCard(
                            game: game,
                            isFavorite: true,
                            onTap: () =>
                                Get.toNamed('/game', arguments: game.id),
                            onFavoritePressed: () =>
                                favoritesService.toggleFavorite(game),
                          );//vai para a tela de detalhes do jogo clicado na tela dos favoritos
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border,
            color: AppColors.primary.withValues(alpha: 0.86),
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text('Nenhum jogo favoritado ainda.'),
        ],
      ),
    );
  }
}
