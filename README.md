# Game Catalog

Aplicativo Flutter de catálogo de jogos feito para explorar títulos da [RAWG API](https://rawg.io/apidocs). O app permite navegar por categorias, buscar jogos pelo nome, abrir uma página de detalhes e montar uma lista simples de favoritos.

## Sobre o projeto

O objetivo é entregar uma experiência direta e responsiva para descobrir jogos. A tela inicial mostra jogos por categoria, a busca consulta a API conforme o usuário digita e os cards permitem favoritar ou remover jogos sem sair da tela atual.

O projeto prioriza simplicidade: estado local com `flutter_hooks`, favoritos globais com `ValueNotifier`, rotas com `GetX` e todas as chamadas HTTP concentradas no `GameService`.

## Funcionalidades
- Filtro por categorias como Ação, Aventura, RPG, Tiro, Estratégia, Esporte, Corrida e outras.
- Busca de jogos por título com debounce para evitar chamadas excessivas.
- Tela de favoritos com os jogos marcados pelo usuário.
- Tela de detalhes com capa, nota, data de lançamento, gêneros e descrição.
- Favoritar e desfavoritar direto pelos cards ou pela página de detalhes.
- Layout adaptado para telas pequenas e maiores.

## Tecnologias

- Flutter
- Dart
- RAWG API
- `flutter_hooks` para estado local nos widgets.
- `ValueNotifier` para estado global dos favoritos.
- `GetX` para navegação por rotas.
- `http` para requisições à API.
- `cached_network_image` para carregar e cachear capas dos jogos.

## Estrutura principal

```text
lib/
  core/
    constants/       # Cores e chave da API via dart-define
    theme/           # Tema visual do app
  models/            # Modelo Game
  services/          # GameService e FavoritesService
  ui/
    screens/         # Home, Busca, Favoritos e Detalhes
    widgets/         # Cards, barra de busca e navegação inferior
  main.dart          # Rotas e inicialização do app
```

## Como rodar

1. Instale as dependências:

```bash
flutter pub get
```

2. Crie uma chave gratuita da RAWG em:

```text
https://rawg.io/apidocs
```

3. Rode o app informando a chave com `--dart-define`:

```bash
flutter run --dart-define=RAWG_API_KEY=sua_key
```

Sem essa chave, o app não consegue buscar os jogos na RAWG API.

## Rotas

- `/` abre a Home.
- `/search` abre a busca.
- `/favorites` abre os favoritos.
- `/game` abre os detalhes de um jogo, recebendo o `id` por argumento.

## Observações

- Os favoritos ficam em memória usando `ValueNotifier`, então são perdidos ao fechar o app.
- O arquivo `lib/core/constants/api_keys.dart` lê a chave por `String.fromEnvironment`, evitando deixar a API key fixa no código.
- O app não usa `StatefulWidget` nem `setState`; o estado das telas fica nos hooks.

## Comandos úteis

```bash
flutter analyze
flutter test
flutter run --dart-define=RAWG_API_KEY=sua_key
```
