# Marina Native Android App Module

This module provides a Kotlin-based, offline-first replacement for the previous Flutter client. It follows an MVVM architecture with a Room database, repository layer, ViewModels with LiveData, and prepares Retrofit + WorkManager scaffolding for online synchronization.

## Project Structure

```
app-marina/
└── app/
    ├── build.gradle.kts
    └── src/main/
        ├── java/com/hotel/management/
        │   ├── adapters/               # RecyclerView adapters and DiffUtil implementations
        │   ├── database/               # Room database, DAOs, and type converters
        │   ├── models/                 # Entity models, relations, dashboard/report DTOs
        │   ├── repository/             # Offline-first repositories wrapping Room + API stubs
        │   ├── ui/                     # Activities, fragments, and screen packages
        │   ├── utils/                  # Preferences, security, networking, and workers
        │   └── viewmodel/              # ViewModels and shared factory
        └── res/                        # Material 3 resources, layouts, drawables, navigation
```

## Build & Run

1. Open **app-marina** in Android Studio Hedgehog or newer, or run from the command line:

   ```bash
   ./gradlew :app:assembleDebug
   ```

2. Ensure that the Android Gradle Plugin 8.5+ and Kotlin 1.9.24+ are installed (already configured in `build.gradle.kts`).

3. Launch the app on API 24+ devices or emulators. The module uses Java 17 language features with desugaring enabled.

## Architecture Overview

- **MVVM + Repository Pattern:** ViewModels expose LiveData derived from Flow queries. Repositories orchestrate Room access and stub remote calls through Retrofit.
- **Offline Database:** Room entities mirror the MySQL schema (bookings, booking_notes, rooms, payments, expenses, employees, cash_register, cash_transactions, invoices, suppliers, users). TypeConverters handle ISO dates and string lists.
- **Synchronization Ready:** `NetworkClient` and `HotelApiService` provide Retrofit scaffolding. `SyncWorker` (scheduled via WorkManager) coordinates repository synchronization stubs for future REST endpoints.
- **Shared Preferences & Security:** `PreferencesManager` wraps SharedPreferences for auth tokens, sync flags, and login attempts. `SecurityUtils` supplies salted SHA-256 hashing for user credentials.
- **UI:** Material Design 3 with RTL-ready layouts, reusable status chips, statistic cards, and filter components. Navigation Component drives flows from Splash/Login → Dashboard → feature screens.
- **Adapters:** DiffUtil-powered adapters cover bookings, rooms, payments, expenses, employees, cash transactions, invoices, and booking notes.

## Offline → Online Sync Strategy

1. **Local-First Mutations:** All create/update/delete operations persist to Room through repositories.
2. **Sync Worker:** `SyncWorker` runs periodically (6-hour cadence by default) and fans out to repository `syncWithRemote()` functions.
3. **Retrofit Stubs:** Each repository consumes `HotelApiService` methods, ready to be hooked to real endpoints. Replace stubs with concrete API implementations and extend payload DTOs as needed.
4. **Conflict Handling:** Extend repositories to track dirty flags or timestamps before enabling bidirectional sync.

## Next Steps

- Wire Retrofit endpoints to the production API and finalize DTO mapping.
- Implement authentication flows and session management in `AuthViewModel` with remote verification.
- Expand WorkManager scheduling (constraints, backoff) when real sync operations are added.
- Add instrumentation/unit tests around repositories and ViewModels.
