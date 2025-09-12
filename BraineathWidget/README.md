# Braineath Widgets

Ce dossier contient les widgets iOS pour l'application Braineath.

## Configuration dans Xcode

Pour activer les widgets dans votre projet Xcode :

### 1. Ajouter une nouvelle target Widget Extension

1. Dans Xcode, allez dans `File` > `New` > `Target`
2. Sélectionnez `Widget Extension`
3. Nommez la target `BraineathWidget`
4. Assurez-vous que l'ID du bundle est `com.yourcompany.Braineath.BraineathWidget`
5. Cochez "Include Configuration Intent" si vous voulez des widgets configurables

### 2. Copier les fichiers

Remplacez les fichiers générés automatiquement par ceux présents dans ce dossier :

- `BraineathWidget.swift` - Widget principal avec les trois tailles
- `SOSWidget.swift` - Widget spécialisé pour l'urgence
- `BraineathWidgetBundle.swift` - Bundle contenant tous les widgets
- `BraineathIntents.swift` - Intents pour les actions rapides
- `Info.plist` - Configuration du widget

### 3. Ajouter les dépendances

Assurez-vous que les frameworks suivants sont liés :

- `WidgetKit`
- `SwiftUI`
- `AppIntents` (iOS 16+)

### 4. Configurer les App Groups (optionnel)

Si vous voulez partager des données entre l'app principale et le widget :

1. Activez App Groups dans les deux targets
2. Créez un groupe partagé : `group.com.yourcompany.Braineath`
3. Utilisez `UserDefaults(suiteName:)` pour partager les données

### 5. Permissions Info.plist

Ajoutez dans le `Info.plist` de l'app principale :

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

## Widgets disponibles

### 1. Widget Principal (BraineathWidget)

- **Petit** : Affiche l'humeur et la série de respiration
- **Moyen** : Affiche les stats + boutons d'action rapide
- **Grand** : Vue complète avec toutes les informations et actions

### 2. Widget SOS (SOSWidget)

- **Petit uniquement** : Accès rapide aux ressources d'urgence
- Apparence distinctive rouge pour les situations de crise

## Actions disponibles

- **Respiration rapide** : Lance une session de respiration de 2 minutes
- **Ajouter humeur** : Ouvre la vue d'enregistrement d'humeur
- **SOS Urgence** : Accès direct aux ressources d'aide

## Notes importantes

- Les widgets se mettent à jour automatiquement selon la timeline configurée
- Les données affichées sont simulées dans cet exemple
- Pour les vraies données, implémentez le partage avec App Groups
- Les intents nécessitent iOS 16+ pour les interactions