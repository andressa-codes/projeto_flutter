# AGENTS.md — Game Catalog App

## Objetivo
App Flutter simples de catálogo de jogos usando a RAWG API.

## Funcionalidades
- Home com filtro por categoria no topo.
- Página de busca por título.
- Página de favoritos.
- Página simples de detalhes ao clicar no card do jogo.
- Favoritar/desfavoritar direto nos cards.

## Stack
- Flutter
- flutter_hooks para estado local
- ValueNotifier para favoritos globais
- GetX para rotas
- http para RAWG API
- cached_network_image para capas

## Regras
- Sem `StatefulWidget` e sem `setState`.
- `GameService` é a única classe que faz HTTP.
- API key em `lib/core/constants/api_keys.dart`, usando `--dart-define=RAWG_API_KEY=sua_key`.
- Manter o app simples: Home, Busca, Favoritos e Detalhes do jogo.
