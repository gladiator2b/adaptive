# ASO Keyword Tracker - Application de Suivi de Mots Clés

Application Flutter pour suivre et optimiser les mots clés ASO (App Store Optimization) de votre application sur le Google Play Store.

## Fonctionnalités

### Gestion des Mots Clés
- **Ajout de mots clés** : Ajoutez les mots clés que vous souhaitez suivre
- **Position actuelle** : Enregistrez la position de votre app dans les résultats de recherche
- **Volume de recherche** : Suivez le volume de recherche estimé
- **Difficulté** : Catégorisez la difficulté (Easy, Medium, Hard)

### Suivi et Analyse
- **Historique des positions** : Visualisez l'évolution de vos positions dans le temps
- **Graphique d'évolution** : Graphique interactif montrant les tendances
- **Statistiques globales** :
  - Nombre total de mots clés suivis
  - Mots clés en progression
  - Mots clés en baisse
  - Position moyenne
- **Tendances** : Icônes visuelles indiquant si votre position s'améliore ou se dégrade

### Interface Utilisateur
- **Tableau de bord** : Vue d'ensemble de tous vos mots clés
- **Détails par mot clé** : Page détaillée avec graphique et historique complet
- **Mise à jour facile** : Mettez à jour les positions en un clic
- **Tri et filtrage** : Triez par position, nom ou date de mise à jour

## Installation

### Prérequis
- Flutter SDK (>=2.17.0)
- Dart SDK

### Étapes d'installation

1. Clonez le repository
```bash
git clone https://github.com/gladiator2b/adaptive.git
cd adaptive/example
```

2. Installez les dépendances
```bash
flutter pub get
```

3. Lancez l'application
```bash
# Sur Android
flutter run

# Sur iOS
flutter run

# Sur Web
flutter run -d chrome
```

## Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  shared_preferences: ^2.0.15  # Stockage local
  intl: ^0.17.0                # Formatage des dates
  fl_chart: ^0.55.0            # Graphiques
  http: ^0.13.5                # Requêtes HTTP (pour futures intégrations)
```

## Structure du Projet

```
lib/
├── main.dart                          # Point d'entrée de l'application
├── models/
│   ├── keyword.dart                   # Modèle de données pour un mot clé
│   └── keyword_tracking.dart          # Modèle pour l'historique de tracking
├── services/
│   └── storage_service.dart           # Service de stockage local (SharedPreferences)
├── screens/
│   ├── home_screen.dart               # Écran principal avec liste des mots clés
│   ├── add_keyword_screen.dart        # Formulaire d'ajout de mot clé
│   └── keyword_detail_screen.dart     # Détails et historique d'un mot clé
└── widgets/
    ├── keyword_card.dart              # Carte d'affichage d'un mot clé
    └── position_chart.dart            # Widget graphique de l'évolution
```

## Utilisation

### Ajouter un mot clé

1. Appuyez sur le bouton "Ajouter" (FAB) sur l'écran principal
2. Remplissez le formulaire :
   - **Mot clé** : Le mot clé à suivre (ex: "jeu de puzzle gratuit")
   - **Position actuelle** : La position actuelle dans les résultats (ex: 42)
   - **Volume de recherche** : Nombre de recherches mensuelles estimé (optionnel)
   - **Difficulté** : Sélectionnez la difficulté estimée
3. Appuyez sur "Ajouter le mot clé"

### Mettre à jour une position

1. Depuis l'écran principal, appuyez sur une carte de mot clé
2. Sur l'écran de détails, appuyez sur l'icône de rafraîchissement
3. Entrez la nouvelle position
4. Validez

La nouvelle position sera enregistrée et le graphique sera automatiquement mis à jour.

### Consulter les statistiques

L'écran principal affiche :
- **Nombre total** de mots clés
- **Mots clés en progression** (position améliorée)
- **Mots clés en baisse** (position dégradée)
- **Position moyenne** de tous vos mots clés

### Supprimer un mot clé

1. Appuyez sur l'icône de suppression (poubelle) sur la carte du mot clé
2. Confirmez la suppression

## Conseils ASO

L'application intègre des conseils pour optimiser votre ASO :

- Choisissez des mots clés pertinents pour votre application
- Suivez régulièrement vos positions (idéalement quotidiennement)
- Privilégiez les mots clés avec un bon volume de recherche
- Variez entre mots clés faciles et difficiles
- Analysez les tendances pour ajuster votre stratégie

## Fonctionnalités Futures

- [ ] Intégration avec l'API Google Play Console
- [ ] Suggestions de mots clés automatiques
- [ ] Comparaison avec la concurrence
- [ ] Notifications pour les changements importants de position
- [ ] Export des données (CSV, PDF)
- [ ] Support multi-applications
- [ ] Thème sombre

## Technologies Utilisées

- **Flutter** : Framework UI
- **Dart** : Langage de programmation
- **SharedPreferences** : Stockage local persistant
- **fl_chart** : Bibliothèque de graphiques
- **Material Design 3** : Design système

## Licence

MIT License - Voir le fichier LICENSE pour plus de détails

## Auteur

Fabrice PASCAL

## Support

Pour toute question ou problème, veuillez ouvrir une issue sur GitHub.
