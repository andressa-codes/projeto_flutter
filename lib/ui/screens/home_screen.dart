import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
import '../../services/favorites_service.dart';
import '../../services/game_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/game_card.dart';

class HomeScreen extends HookWidget { //lista de categorias
  const HomeScreen({super.key});

  static const _categories = [
    _GameCategory('Todos', ''),
    _GameCategory('Acao', 'action'),
    _GameCategory('Aventura', 'adventure'),
    _GameCategory('RPG', 'role-playing-games-rpg'),
    _GameCategory('Tiro', 'shooter'),
    _GameCategory('Estrategia', 'strategy'),
    _GameCategory('Esporte', 'sports'),
    _GameCategory('Corrida', 'racing'),
    _GameCategory('Puzzle', 'puzzle'),
    _GameCategory('Indie', 'indie'),
    _GameCategory('Simulacao', 'simulation'),
    _GameCategory('Arcade', 'arcade'),
    _GameCategory('Plataforma', 'platformer'),
    _GameCategory('Luta', 'fighting'),
    _GameCategory('Familia', 'family'),
    _GameCategory('Casual', 'casual'),
    _GameCategory('Educacional', 'educational'),
    _GameCategory('Cartas', 'card'),
    _GameCategory('Tabuleiro', 'board-games'),
  ];

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService.instance;
    final gameService = useMemoized(GameService.new);
    final favorites = useListenable(favoritesService.favoritesNotifier);
    final selectedCategory = useState(_categories.first);// categoria selecionada
    final categoryScrollController = useScrollController();
    final games = useState<List<Game>>([]); //lista de jogos da categoria
    final isLoading = useState(true);// controla loading
    final error = useState<String?>(null); // estado que guarda erro da API
    final size = MediaQuery.sizeOf(context);

    useEffect(() {//quando a categoria muda, busca jogos de novo
      var disposed = false;

      Future<void> loadGames() async {
        isLoading.value = true;
        error.value = null;
        try {
          final loadedGames = await gameService.fetchGamesByCategory(
            selectedCategory.value.slug,
          );
          if (!disposed) {
            games.value = loadedGames;
          }
        } on GameServiceException catch (exception) {
          if (!disposed) {
            error.value = exception.message;
            games.value = [];
          }
        } finally {
          if (!disposed) {
            isLoading.value = false;
          }
        }
      }

      loadGames();
      return () => disposed = true;
    }, [selectedCategory.value.slug]);

    return Scaffold(
      appBar: AppBar(title: const Text('Jogos')),
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
                    Text(
                      'Categorias',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 54,
                      child: Scrollbar(
                        controller: categoryScrollController,
                        child: ListView.separated(
                          controller: categoryScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: _categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final selected =
                                category.slug == selectedCategory.value.slug;
                            return ChoiceChip(//quando ousuario escolhe uma categoria a tela atualiza e busca novos jogos
                              label: Text(category.label),
                              selected: selected,
                              onSelected: (_) =>
                                  selectedCategory.value = category,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.secondary,
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppColors.background
                                    : AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.accent.withValues(
                                          alpha: 0.22,
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _GameGrid(
                        games: games.value,
                        favorites: favorites.value,
                        isWide: isWide,
                        isLoading: isLoading.value,
                        error: error.value,
                        emptyMessage: 'Nenhum jogo encontrado nessa categoria.',
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

class _GameGrid extends StatelessWidget {
  const _GameGrid({
    required this.games,
    required this.favorites,
    required this.isWide,
    required this.isLoading,
    required this.error,
    required this.emptyMessage,
    required this.onFavoritePressed,
  });

  final List<Game> games;
  final List<Game> favorites;
  final bool isWide;
  final bool isLoading;
  final String? error;
  final String emptyMessage;
  final ValueChanged<Game> onFavoritePressed;

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

    if (games.isEmpty) {
      return _StateMessage(icon: Icons.sports_esports, message: emptyMessage);
    }

    return GridView.builder(
      itemCount: games.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        childAspectRatio: isWide ? 0.68 : 0.64,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          game: game,//passsa os dados do jogo
          isFavorite: favorites.any((favorite) => favorite.id == game.id),//diz se a estrela fica marcada
          onTap: () => Get.toNamed('/game', arguments: game.id), //navega para a rota que tem os detalhes do jogo passando o id do jogo como argumento
          onFavoritePressed: () => onFavoritePressed(game),//favorita ou remove
        );
      },
    );
  }
}

class _GameCategory {
  const _GameCategory(this.label, this.slug);

  final String label;
  final String slug;
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
