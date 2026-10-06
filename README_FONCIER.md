# Foncier+ Mobile — Socle de base

Application Flutter (prospect / agent) branchée sur le backend Spring Boot.

## Démarrage

```bash
cd flutter_mobile_prospect_agent
flutter pub get
flutter run
```

### URL du backend

Par défaut : `http://10.0.2.2:8080/api` (émulateur Android).

```bash
# Simulateur iOS
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api

# Téléphone réel (remplacer l’IP)
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080/api
```

Le backend doit tourner et autoriser les appels (pas de CORS sur app native).

## Architecture livrée

```
lib/
├── core/
│   ├── constants/     api_endpoints, app_constants
│   ├── network/       ApiClient (Dio + JWT), ErrorHandler
│   ├── storage/       TokenStorage (secure)
│   ├── router/        go_router + redirects auth
│   └── theme/         couleurs Foncier+
├── data/
│   ├── models/        AuthUser, ApiResponse, LoginRequest…
│   └── repositories/  AuthRepository
├── features/
│   ├── auth/          login, register, role selection, AuthProvider
│   ├── prospect/shell socle acquéreur
│   └── agent/shell    socle agent
└── shared/widgets
```

## Répartition des tâches suggérée

| Binôme A (Prospect) | Binôme B (Agent) |
|---------------------|------------------|
| Catalogue programmes / lots | Dashboard KPI |
| Détail lot + réservation | Liste réservations à traiter |
| Mes réservations | RDV / visites |
| Projets construction (suivi avancement) | Notification / profil agent |

**Règle :** utiliser `ref.watch(apiClientProvider)` ou un repository dédié — ne pas recréer Dio ailleurs.

## Endpoints déjà mappés

- `POST /auth/login` `{ telephone, motDePasse }`
- `POST /auth/register` (acquéreur)
- Programmes, lots, réservations, projets-construction, modèles-maison (chemins dans `ApiEndpoints`)

## Prochaines étapes techniques

1. Models + repository catalogue (`ProgrammeFoncier`, `LotProgramme`)
2. Brancher `CatalogueScreen` sur l’API
3. Bottom nav prospect → vraies pages
4. Dashboard agent sur données réelles
