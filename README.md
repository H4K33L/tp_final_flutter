# SnapThème

Groupe: Jean-Baptiste BODUSSEAU, Jeremy GAUDIN, Kelyan DANIS, Aurelien DUGAST

## Principe

Les joueurs rejoignent une room via un code. À chaque manche, le maître du thème choisit un mot ou une phrase. Tous les joueurs actifs ont 60 secondes pour prendre une photo correspondant au thème, puis 30 secondes pour voter pour leur photo préférée (pas la leur). Le joueur avec le plus de votes remporte la manche. Le classement final est affiché en fin de partie.

## Stack technique

- **Flutter** 3.12+ / Dart
- **Firebase** : Firestore (temps réel), Storage (photos), Auth (anonyme)
- **Riverpod** 3 : gestion d'état et providers
- **Freezed** : modèles immuables avec sérialisation JSON

## Lancer l'application

```
Bash
cd tp_final_fluter
flutter pub get
flutter run
```

## Architecture

```
lib/
  main.dart                   # Point d'entrée, auth anonyme, routing
  game_page.dart              # Router de room (status → widget)
  game_page_widget/
    waiting_widget.dart       # Lobby avec code de room
    starting_widget.dart      # Saisie du thème
    playing_widget.dart       # Capture photo (caméra)
    voting_widget.dart        # Galerie de vote
    result_widget.dart        # Scores de manche
    finished_widget.dart      # Podium final
  models/                     # Modèles Freezed (Room, Round, Player…)
  repositories/               # CRUD Firestore par entité
  providers/                  # Providers Riverpod (auth, storage)
```

## Règles métier

- Chaque manche : tous les joueurs actifs soumettent une photo, puis votent.
- La phase capture et la phase vote se ferment automatiquement (timer) ou dès que tous les joueurs ont soumis/voté.
- Les spectateurs (rejoints après le début) peuvent observer sans participer.
- Seul le host peut démarrer la partie et passer à la manche suivante.
