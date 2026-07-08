class Game {
  const Game({
    required this.id,
    required this.title,
    this.backgroundImage,
    this.released,
    this.rating,
    this.genres = const [],
    this.description,
  });

  final int id;
  final String title;
  final String? backgroundImage;
  final String? released;
  final double? rating;
  final List<String> genres;
  final String? description;

  factory Game.fromJson(Map<String, dynamic> json) { //transforma o JSON da API em um objeto Game
    return Game(
      id: json['id'] as int? ?? 0,
      title: json['name'] as String? ?? 'Sem titulo',
      backgroundImage: json['background_image'] as String?,
      released: json['released'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      genres: _parseGenres(json['genres']),
      description:
          json['description_raw'] as String? ?? json['description'] as String?,
    );
  }

  static List<String> _parseGenres(Object? value) {//Ele pega a lista de gêneros que vem da API e transforma em uma lista de textos
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map((genre) => genre['name'] as String?)
        .whereType<String>()
        .toList(growable: false);
  }
}
