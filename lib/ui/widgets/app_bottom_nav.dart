import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  static const _routes = ['/', '/search', '/favorites']; //lista das rotas de navegação da navbar

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute; //retorna a rota atual
    final currentIndex = _routes.indexOf(currentRoute);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (index) {
          final route = _routes[index]; //rota clicada
          if (route != Get.currentRoute) { // se a rota clicada for diferente da rota atual então realmente muda pra outra pagina
            Get.offNamed(route);//remove a tela atual e coloca a nova
          }
        },
        backgroundColor: AppColors.secondary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.white.withValues(alpha: 0.54),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Busca'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoritos'),
        ],
      ),
    );
  }
}
