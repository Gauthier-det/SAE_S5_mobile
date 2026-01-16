# Orient'Action - Application Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Project Structure](#project-structure)
5. [Core Systems](#core-systems)
6. [Feature Modules](#feature-modules)
7. [Data Flow](#data-flow)
8. [State Management](#state-management)
9. [User Interfaces](#user-interfaces)
10. [Setup and Installation](#setup-and-installation)

---

## Overview

**Orient'Action** is a Flutter mobile application for managing orientation races and raid events. It serves two primary audiences:

- **Race Organizers (B2B)**: Clubs and administrators managing events
- **Participants (B2C)**: Runners and team members participating in races

### Core Purpose

The application provides a unified platform for:
- Creating and managing orientation races and raids
- Team registration and validation
- Participant profile management
- Real-time race validation and dossard distribution
- Results tracking and performance monitoring

### Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Backend**: Laravel REST API
- **Local Storage**: SQLite (via sqflite)
- **Persistent Storage**: SharedPreferences
- **Localization**: French (fr_FR) primary, English support
- **HTTP Client**: http package with bearer token authentication

### Target Platform

- iOS and Android (mobile-first responsive design)
- Supports both phones and tablets

---

## Architecture

The application follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/                 # Shared infrastructure
│   ├── config/          # App configuration (API base URL)
│   ├── database/        # SQLite initialization and helpers
│   └── theme/           # App theme and styling
├── features/            # Domain-specific modules
│   ├── auth/            # Authentication
│   ├── user/            # User profiles
│   ├── team/            # Team management
│   ├── raid/            # Raid events
│   ├── race/            # Race configuration
│   ├── club/            # Club management
│   └── address/         # Address data
├── shared/              # Shared utilities
│   └── utils/           # Date formatters, helpers
└── main.dart            # Entry point
```

### Architectural Layers

Each feature module follows three-layer architecture:

```
feature/
├── domain/              # Business logic (interfaces)
│   ├── <entity>.dart
│   └── <repository>.dart (abstract interface)
├── data/                # Data access (implementations)
│   ├── datasources/
│   │   ├── <entity>_api_sources.dart (remote)
│   │   └── <entity>_local_sources.dart (cache)
│   └── repositories/
│       └── <entity>_repository_impl.dart
└── presentation/        # UI layer
    ├── providers/       # State management (Provider)
    ├── screens/         # Full-page widgets
    ├── views/           # View components
    └── widgets/         # Reusable widgets
```

#### Layer Responsibilities

**Domain Layer**: Defines business rules and abstract contracts
- Entity models (pure Dart classes)
- Repository interfaces (abstract classes)
- No framework dependencies
- Business logic for validation and rules

**Data Layer**: Implements data access
- API data sources (HTTP client)
- Local data sources (SQLite, SharedPreferences)
- Repository implementations
- Data transformation (JSON ↔ Entity)
- Caching strategies (network-first with fallback)

**Presentation Layer**: UI and user interaction
- Screens (full-page widgets)
- Views (major components)
- Widgets (reusable components)
- State management via Provider
- Navigation and routing

### Design Patterns

**Repository Pattern**: Abstracts data sources behind a single interface
- Repositories handle API/local source coordination
- Network-first strategy with offline fallback
- Atomic operations (all-or-nothing transactions)

**Provider Pattern**: State management
- `ChangeNotifierProvider`: Stateful providers (Auth, Club)
- `Provider`: Read-only immutable providers (Repositories)
- `Consumer`: Reactive widgets that rebuild on changes
- `Provider.of()`: Manual access without rebuilding

**Data Source Pattern**: Separation of remote and local data
- API sources handle HTTP requests with authentication
- Local sources manage SQLite persistence
- Repositories coordinate between both

**DTO Pattern**: Data Transfer Objects
- JSON-serializable models for API communication
- Entity models for domain logic
- Automatic conversion via `fromJson`/`toJson`

---

## Features

### 1. Authentication

**Functionality**:
- User registration with email and password
- Login with persistent token storage
- Automatic token injection in API requests
- Login persistence (remembers user across app restarts)
- Logout and session cleanup

**Auth Flow**:
1. User registers/logs in
2. Backend returns JWT token
3. Token stored in SharedPreferences
4. Token automatically injected in all repository requests
5. On app restart, AuthProvider.create() recovers token
6. If token invalid, user sent to login screen

**Implementation Details**:
- AuthProvider manages current user state
- AuthLocalSources handles token persistence
- API sources receive token via setAuthToken()
- 401 responses trigger logout automatically

### 2. User Profile Management

**Functionality**:
- View personal and sports information
- Edit profile (name, phone, birth date, club, licence)
- Professional section shows immutable email
- Display profile picture with fallback
- Age calculation from birth date

**Profile Information**:
- Personal: First name, last name, phone, birth date
- Sports: Club, licence number, PPS form, chip number
- Account: Email (locked), creation date
- Image: Network URL with default icon fallback

**Update Strategy**:
- Validates required fields (first/last name)
- Trims and coalesces empty fields to null
- Updates API first, then local cache (write-through)
- Provides error feedback via SnackBar
- Auto-navigates on success

### 3. Team Management

**Core Concepts**:
- **Team**: Group of participants led by a creator
- **Team Members**: Individual participants in a team
- **Team Validation**: Requires all members have licence OR PPS
- **Dossard Number**: Auto-generated when team registers to race

**Team Registration**:
1. User creates team (min. 1, max. varies by race)
2. Adds members from available users (pre-filtered)
3. All members must have age ≥12 years
4. Gender filtering applied if race gender-specific
5. On submission, atomic operation:
   - Team created
   - Team registered to race (generates dossard)
   - Members individually registered to race

**Team Detail Operations**:
- View team info and all members
- Add/remove team members (creator or race manager only)
- Edit member details (licence, PPS form, chip number)
- Validate/invalidate team (race manager only)
- Delete team (race manager only)

**Permission Model**:
- **Team Creator**: Add/remove members, edit own info
- **Race Manager**: Full control (validate, delete, edit all)
- **Team Member**: View team, edit own details only

**Validation Rules**:
- Team can only be validated if:
  - All members have valid licence number OR valid PPS form
  - No missing required documentation
- Optional fields (phone, club, chip) don't block validation

### 4. Race and Raid Management

**Race**: Competition event with specific rules
- Max team size (configurable)
- Gender requirement (Mixte, Men, Women)
- Age requirements
- Registration deadlines
- Team validation workflow

**Raid**: Multi-stage competition format
- Individual or team-based
- Multiple checkpoints/stages
- Results tracking

**Management Features** (for race managers):
- Dashboard with team overview
- Real-time validation during race day
- Dossard number distribution
- Results import and publication
- Team and member file validation

### 5. Offline-First Caching

**Strategy**: Network-first with local fallback
- Attempt API request first
- Cache successful responses locally
- On network error, serve cached data
- Write-through: successful API responses cached immediately

**Caching Implementation**:
- SQLite database for structured data (races, users)
- SharedPreferences for auth token
- Repository coordinates cache/API coordination
- Automatic cache invalidation on updates

**Benefits**:
- App works offline with cached data
- Fast subsequent loads from cache
- Seamless network error recovery
- User experience uninterrupted by network issues

### 6. Multi-Language Support

**Primary Language**: French (fr_FR)
**Fallback**: English (en_US)

**Localization**:
- Flutter Material localizations delegated
- Custom date formatting utility (French months)
- Month names: Full and abbreviated versions
- Time format: 24-hour (14h30)

**Date Formatting Utility**:
```
formatDate(DateTime) → "13 jan 2026"
formatDateTime(DateTime) → "13 janvier 2026 à 14h30"
formatTime(DateTime) → "14h30"
```

---

## Project Structure

### Directory Organization

```
lib/
├── core/                          # Infrastructure
│   ├── config/
│   │   └── app_config.dart        # API base URL, app name
│   ├── database/
│   │   └── database_helper.dart   # SQLite initialization
│   └── theme/
│       └── app_theme.dart         # Material theme, colors
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── datasources/
│   │   │       └── auth_local_sources.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   │
│   ├── user/
│   │   ├── domain/
│   │   │   ├── user.dart
│   │   │   └── user_repository.dart (abstract)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── user_api_sources.dart
│   │   │   │   └── user_local_sources.dart
│   │   │   └── repositories/
│   │   │       └── user_repository_impl.dart
│   │   └── presentation/
│   │       ├── edit_profile_screen.dart
│   │       └── profile_screen.dart
│   │
│   ├── team/
│   │   ├── domain/
│   │   │   ├── team.dart
│   │   │   └── team_repository.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── team_api_sources.dart
│   │   │   │   └── team_local_sources.dart
│   │   │   └── repositories/
│   │   │       └── team_repository_impl.dart
│   │   └── presentation/
│   │       ├── team_detail_view.dart
│   │       ├── team_race_list_view.dart
│   │       ├── team_race_registration_view.dart
│   │       └── widgets/
│   │
│   ├── raid/
│   │   ├── domain/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── raid_api_sources.dart
│   │   │   │   └── raid_local_sources.dart
│   │   │   └── repositories/
│   │   └── presentation/
│   │       └── raid_list_view.dart
│   │
│   ├── race/
│   │   ├── domain/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── race_api_sources.dart
│   │   │   │   └── race_local_sources.dart
│   │   │   └── repositories/
│   │   └── presentation/
│   │
│   ├── club/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── club_provider.dart
│   │       └── screens/
│   │           └── club_list_screen.dart
│   │
│   └── address/
│       ├── domain/
│       ├── data/
│       └── presentation/
│
├── shared/
│   └── utils/
│       └── date_formatter.dart    # French date formatting
│
└── main.dart                      # App entry point
```

### Key Files

- **main.dart**: Application entry point with MultiProvider initialization
- **app_config.dart**: Environment configuration (API base URL)
- **app_theme.dart**: Material Design theme with app colors
- **auth_provider.dart**: Authentication state management
- **auth_local_sources.dart**: Token persistence in SharedPreferences

---

## Core Systems

### 1. Dependency Injection (main.dart)

**FutureBuilder Pattern**:
```
main() → AuthProvider.create() 
      → SanglierExplorerApp(authProvider)
      → FutureBuilder(_createRepositories)
      → MultiProvider(all repositories)
      → MaterialApp
```

**Repository Initialization**:
All repositories created in `_createRepositories()`:
- RaidRepository
- RacesRepository
- UserRepository
- ClubRepository
- AddressRepository
- TeamRepository

**Shared Dependencies**:
- AuthLocalSources: Shared across all repositories for token injection
- DatabaseHelper: Shared SQLite instance
- SharedPreferences: Shared app preferences instance

**Provider Tree**:
```dart
MultiProvider([
  ChangeNotifierProvider<AuthProvider>.value(authProvider),
  ChangeNotifierProvider<ClubProvider>(),
  Provider<RaidRepository>.value(),
  Provider<RacesRepository>.value(),
  Provider<UserRepository>.value(),
  Provider<ClubRepository>.value(),
  Provider<AddressRepository>.value(),
  Provider<TeamRepository>.value(),
])
```

### 2. Authentication Flow

**Login Process**:
1. User enters email and password
2. LoginScreen calls AuthProvider.login()
3. AuthProvider calls API via authLocalSources
4. Backend validates and returns JWT token
5. Token stored in SharedPreferences
6. currentUser updated
7. App navigates to MainScreen

**Token Persistence**:
1. On app startup, AuthProvider.create() called
2. Reads token from SharedPreferences
3. If token exists, validates and loads user
4. Sets _isAuthenticated = true
5. User automatically logged in

**Logout Process**:
1. User taps logout in drawer
2. AuthProvider.logout() called
3. Token cleared from SharedPreferences
4. currentUser cleared
5. _isAuthenticated = false
6. App navigates back to Home

**Token Injection**:
- All repositories store reference to AuthLocalSources
- Before each API call, retrieve current token
- Pass token to API sources via setAuthToken()
- HTTP headers automatically include: `Authorization: Bearer <token>`

### 3. API Communication

**Data Sources Architecture**:
```
UserApiSources (HTTP client)
    ↓
    getUserById(int) → GET /users/{id}
    updateUser(User) → PUT /users/{id}
    updateUserFields(Map) → PUT /users/{id}
    
Response Format:
    {
      "data": { /* entity */ }
    }
```

**Error Handling**:
- 200: Success, parse data
- 401: Authentication failed, re-login required
- 403: Authorization failed, insufficient permissions
- 404: Resource not found, return null
- 422: Validation error, show error message
- Other: Network error, fallback to local

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer {token}
```

### 4. Local Storage

**SQLite Database**:
- Used for structured data (races, teams, users)
- DatabaseHelper singleton manages connections
- Tables: Configurable per feature (users, races, teams, etc.)

**SharedPreferences**:
- Used for simple key-value data
- Auth token storage
- User preferences and flags

**Caching Strategy**:
1. On successful API response, save to SQLite
2. On network error, fetch from SQLite
3. Manual refresh triggers fresh API call
4. Pull-to-refresh invalidates cache

---

## Feature Modules

### Auth Module

**Responsibilities**:
- Handle login/registration
- Manage authentication state
- Persist and restore sessions
- Token lifecycle management

**Key Classes**:
- `AuthProvider`: State management (ChangeNotifierProvider)
- `AuthLocalSources`: Token and session persistence
- `LoginScreen`: UI for authentication
- `RegisterScreen`: User registration form

**User State**:
```dart
AuthProvider {
  currentUser: User?          // Currently logged-in user
  isAuthenticated: bool       // Authentication status
  login(email, password)      // Login method
  register(email, password)   // Registration method
  logout()                    // Logout and clear session
}
```

### User Module

**Responsibilities**:
- User profile CRUD operations
- Personal information management
- Sports profile (club, licence, etc.)

**Key Classes**:
- `User`: Entity model with personal/sports info
- `UserRepository`: Abstract interface
- `UserRepositoryImpl`: API + cache coordination
- `UserApiSources`: HTTP client
- `UserLocalSources`: SQLite cache
- `EditProfileScreen`: Profile editing form
- `ProfileScreen`: Read-only profile view

**Profile Data**:
```dart
User {
  id: int
  email: String              // Immutable
  firstName: String
  lastName: String
  phoneNumber: String?
  birthDate: String?         // ISO 8601
  club: String?
  licenceNumber: String?
  ppsNumber: String?         // PPS form reference
  chipNumber: String?        // Race chip number
  profileImageUrl: String?
  createdAt: DateTime
}
```

### Team Module

**Responsibilities**:
- Team CRUD and member management
- Team validation workflow
- Race registration coordination
- Dossard number generation

**Key Classes**:
- `Team`: Team entity with metadata
- `TeamRepository`: Abstract interface
- `TeamRepositoryImpl`: Repository with validation logic
- `TeamDetailView`: Team detail and member management
- `TeamRaceListView`: List of teams for a race
- `TeamRaceRegistrationView`: Team creation and registration form

**Team Operations**:
```dart
// Create team and register to race
createTeamAndRegisterToRace(
  team: Team,
  memberIds: List<int>,
  raceId: int
)

// Validate team (race manager only)
validateTeamForRace(teamId: int, raceId: int)

// Get team with race status
getTeamByIdWithRaceStatus(teamId: int, raceId: int)

// Add member to team
addTeamMember(teamId: int, userId: int, raceId: int)

// Edit member details
updateUserPPS(userId: int, ppsForm: String?, raceId: int, teamId: int)
updateUserChipNumber(userId: int, raceId: int, chipNumber: int?, teamId: int)
```

**Permission Model**:
```
Team Creator:
  - Add/remove members
  - Edit own profile
  - View team details

Race Manager:
  - Add/remove members
  - Edit all member profiles
  - Validate/invalidate team
  - Delete team
  - View all race teams
  - Manage race day operations

Team Member:
  - View team details
  - Edit own profile only
  - Cannot modify other members
```

### Raid Module

**Responsibilities**:
- Raid/race listing
- Raid details and filtering
- Raid registration

**Key Classes**:
- `Raid`: Race/raid entity
- `RaidRepository`: Abstract interface
- `RaidRepositoryImpl`: API + cache coordination
- `RaidListView`: Raid list with search/filter

### Race Module

**Responsibilities**:
- Race configuration and metadata
- Race rules and constraints
- Race team management

**Key Classes**:
- `Race`: Race entity
- `RacesRepository`: Abstract interface
- `RacesRepositoryImpl`: API + cache coordination

### Club Module

**Responsibilities**:
- Club management (CRUD)
- Club admin features
- Club-specific dashboards

**Key Classes**:
- `Club`: Club entity
- `ClubRepository`: Abstract interface
- `ClubRepositoryImpl`: API + cache coordination
- `ClubProvider`: State management for club operations
- `ClubListScreen`: Admin view of all clubs

---

## Data Flow

### User Registration Flow

```
RegisterScreen
    ↓
User enters email/password
    ↓
registerButton.onPressed()
    ↓
AuthProvider.register(email, password)
    ↓
AuthLocalSources.register(email, password)
    ↓
API: POST /auth/register
    ↓
Backend validates and returns token
    ↓
Token saved to SharedPreferences
    ↓
currentUser updated with user data
    ↓
isAuthenticated = true
    ↓
Navigator.pop() back to Home
    ↓
Home renders with authenticated user
```

### Team Registration Flow

```
TeamRaceRegistrationView
    ↓
User enters team name and selects members
    ↓
submitForm()
    ↓
Form validation (name, members required)
    ↓
AuthProvider retrieves current userId
    ↓
Team object created with managerId = userId
    ↓
TeamRepositoryImpl.createTeamAndRegisterToRace()
    ↓
1. TeamApiSources.createTeam()
    ↓ (POST /teams)
    ↓
2. TeamApiSources.registerTeamToRace()
    ↓ (POST /races/{raceId}/teams)
    ↓ (generates dossard)
    ↓
3. For each member:
    ↓ TeamApiSources.registerUserToRace()
    ↓ (POST /races/{raceId}/users)
    ↓
All succeed → Cache team locally
    ↓
Show success SnackBar
    ↓
Navigator.pop(context, true)
    ↓
TeamRaceListView rebuilds
```

### Profile Update Flow

```
EditProfileScreen
    ↓
User modifies profile fields
    ↓
saveButton.onPressed()
    ↓
Form validation
    ↓
_saveProfile()
    ↓
AuthProvider.updateProfile(fields)
    ↓
UserRepositoryImpl.updateUserFields(userId, fields)
    ↓
1. Retrieve token from AuthLocalSources
    ↓
2. UserApiSources.updateUserFields(userId, fields)
    ↓ (PUT /users/{userId})
    ↓
3. On success, cache response locally
    ↓
currentUser updated in AuthProvider
    ↓
All Consumer<AuthProvider> rebuild
    ↓
ProfileScreen reflects changes
    ↓
Show success SnackBar
    ↓
Navigator.pop() back to ProfileScreen
```

### Offline Fallback Flow

```
Any Repository method called
    ↓
Try API request
    ↓
Network error (no internet)
    ↓
Exception caught in catch block
    ↓
Try local SQLite fetch
    ↓
Return cached data (if available)
    ↓
    OR
    ↓
Show error message
    ↓
User experience: App still functional with cached data
```

---

## State Management

### Provider Architecture

**Provider Types**:

1. **ChangeNotifierProvider**: Stateful, notifies listeners
   ```dart
   ChangeNotifierProvider<AuthProvider>.value(authProvider)
   ChangeNotifierProvider<ClubProvider>()
   ```
   Used for: Auth state, Club operations

2. **Provider**: Read-only, immutable repositories
   ```dart
   Provider<RaidRepository>.value(snapshot.data!['raidRepository'])
   ```
   Used for: Repositories, data sources

3. **Consumer**: Reactive widget wrapper
   ```dart
   Consumer<AuthProvider>(
     builder: (context, authProvider, _) { ... }
   )
   ```
   Used for: Conditional UI based on state

4. **Provider.of()**: Manual access (no rebuild)
   ```dart
   final repo = Provider.of<RaidRepository>(context, listen: false)
   ```
   Used for: One-time reads in callbacks

### Auth State Management

**AuthProvider**:
```dart
class AuthProvider extends ChangeNotifier {
  User? currentUser;
  bool isAuthenticated;
  
  Future<void> login(email, password)
  Future<void> register(email, password)
  Future<void> logout()
  Future<void> updateProfile(fields)
  
  void notifyListeners() // Trigger rebuilds on changes
}
```

**Usage in Screens**:
```dart
// Reactive UI rebuild on auth changes
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (!authProvider.isAuthenticated) {
      return LoginScreen();
    }
    return HomeScreen();
  }
)

// One-time read in callback
ElevatedButton(
  onPressed: () {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.login(email, password);
  }
)
```

### Repository Access

**Via Provider**:
```dart
// In widgets
final raidRepo = Provider.of<RaidRepository>(context, listen: false);
final raids = await raidRepo.getAllRaids();

// In screens with StatelessWidget
class RaidsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<RaidRepository>(context, listen: false);
    return RaidListView(repository: repository);
  }
}
```

---

## User Interfaces

### Navigation Structure

```
main.dart
    ↓
SanglierExplorerApp (FutureBuilder for DI)
    ↓
MainScreen (Scaffold with Drawer)
    ├─ drawer: Navigation menu
    │   ├─ UserAccountsDrawerHeader (auth state)
    │   ├─ Home
    │   ├─ Raids
    │   ├─ Clubs (admin only)
    │   ├─ Profile (authenticated)
    │   └─ Auth (visitors)
    │
    └─ body: Home (landing page)
        ├─ Hero section (CTAs)
        ├─ B2B section (clubs)
        ├─ B2C section (runners)
        ├─ Tutorial section
        └─ Footer

Named Routes:
  /login → LoginScreen
  /register → RegisterScreen
  /home → MainScreen
  /raids → RaidsScreen
```

### Key Screens

**Home (Landing Page)**:
- Hero section with image and CTAs
- B2B section for race organizers
- B2C section for runners
- Tutorial steps
- Responsive layout (mobile: stacked, desktop: side-by-side)

**Profile Screen**:
- Avatar with network image fallback
- Read-only profile information
- Edit button navigates to EditProfileScreen
- Logout button

**EditProfileScreen**:
- Form with TextFormFields for all editable fields
- DatePicker for birth date
- Form validation (required fields)
- Save button with loading state

**TeamDetailView**:
- Team header with dossard number
- Validation badge and button (manager only)
- Member list with editable fields
- Add/remove member buttons
- Delete team button (manager only)

**TeamRaceListView**:
- List of teams registered to race
- Race info header
- Team cards with member count
- Access control before navigation

**TeamRaceRegistrationView**:
- Form to create team and register members
- Race info and constraints displayed
- Autocomplete user selector
- Team size validation
- Atomic creation + registration

### Responsive Design

**LayoutBuilder Pattern**:
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 500) {
      // Mobile: Stacked buttons (Column)
      return Column(children: [...])
    } else {
      // Desktop: Side-by-side buttons (Row)
      return Row(children: [...])
    }
  }
)
```

**Applied To**:
- Hero CTA buttons (Home screen)
- Tutorial steps layout
- Form elements

---

## Setup and Installation

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- iOS development tools (Xcode) or Android development tools (Android Studio)
- Node.js/npm (optional, for backend setup)

### Environment Setup

1. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd sae5_g13_mobile
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL**:
   Edit `lib/core/config/app_config.dart`:
   ```dart
   class AppConfig {
     static const String apiBaseUrl = 'https://api.example.com';
     static const String appName = 'Orient\'Action';
   }
   ```

4. **Initialize Database**:
   Database is initialized automatically on first app run via `DatabaseHelper.database`.

### Running the App

**Development**:
```bash
flutter run
```

**Debug Mode**:
```bash
flutter run -d <device_id> --debug
```

**Release Build**:
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Testing

**Unit Tests**:
```bash
flutter test
```

**Widget Tests**:
```bash
flutter test test/widget_test.dart
```

### Backend API Requirements

The application expects a Laravel REST API with endpoints:

**Auth**:
- `POST /auth/login` - User login
- `POST /auth/register` - User registration

**Users**:
- `GET /users` - List all users
- `GET /users/{id}` - Get user by ID
- `PUT /users/{id}` - Update user
- `PUT /users/{id}` - Update user fields

**Raids**:
- `GET /raids` - List raids
- `GET /raids/{id}` - Get raid details
- `POST /raids` - Create raid
- `PUT /raids/{id}` - Update raid

**Races**:
- `GET /races` - List races
- `GET /races/{id}` - Get race details
- `POST /races/{id}/teams` - Register team to race

**Teams**:
- `POST /teams` - Create team
- `GET /teams/{id}` - Get team details
- `PUT /teams/{id}` - Update team
- `DELETE /teams/{id}` - Delete team
- `POST /teams/{id}/members` - Add member
- `DELETE /teams/{id}/members/{userId}` - Remove member

**Clubs**:
- `GET /clubs` - List clubs
- `GET /clubs/{id}` - Get club details
- `POST /clubs` - Create club
- `PUT /clubs/{id}` - Update club

All endpoints return responses in format: `{ "data": {...} }`

---

## Performance Optimization

### Caching Strategy

- Network-first with local fallback
- Automatic cache invalidation on updates
- Write-through caching for API responses
- Pull-to-refresh for manual refresh

### Load Time Optimization

- FutureBuilder for async initialization
- Lazy loading of screens via Navigator
- Image optimization with network image error handling
- SQLite indexing on frequently queried fields

### Memory Management

- Dispose TextEditingControllers in StatefulWidgets
- Use `listen: false` in callbacks to avoid rebuilds
- Consumer widgets for granular rebuilds
- Unsubscribe from streams/futures when not needed

---

## Troubleshooting

### Common Issues

**Login Not Working**:
- Check API base URL in app_config.dart
- Verify backend is running and accessible
- Check network connectivity
- Check SharedPreferences initialization

**Offline Data Not Showing**:
- Ensure previous successful API call cached data
- Check SQLite database initialization
- Verify local sources are properly configured

**Team Registration Fails**:
- Check team size constraints for race
- Verify all members meet age requirement
- Ensure team name is not empty
- Check member eligibility filters

**Token Expired**:
- 401 responses trigger automatic logout
- User sent to login screen
- New token obtained on re-login
- Token stored in SharedPreferences

---

## Contributing Guidelines

### Code Style

- Follow Dart conventions
- Use meaningful variable names
- Document public methods with doc comments
- Keep methods small and focused

### Pull Request Process

1. Create feature branch from `develop`
2. Make changes with clear commit messages
3. Test on both iOS and Android
4. Submit PR with description
5. Address code review feedback

### Architecture Consistency

- Maintain layer separation (domain/data/presentation)
- Use repository pattern for data access
- Implement Provider for state management
- Follow existing naming conventions

---

## License

This project is developed for Université de Caen Normandie.

---

## Support

For issues or questions:
- Check existing GitHub issues
- Contact development team
- Consult technical documentation

---

**Last Updated**: January 2026  
**Version**: 1.0  
**Maintainers**: G13 Development Team
