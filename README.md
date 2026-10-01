# PremierLeague — FPL Team Viewer

A native iOS application built with Swift and UIKit that allows users to browse Fantasy Premier League (FPL) teams and their squads using the public FPL bootstrap API.

---

## 1. How to Build and Run the Application

* **Prerequisites**: Xcode Version 26.5 (17F42) or compatible running on macOS, with Swift Language Version 6.
* **Dependencies**: Zero external dependencies (no CocoaPods, Carthage, Swift Package Manager, or third-party frameworks).
* **Project Tooling**: Standard `.xcodeproj` (XcodeGen is currently not integrated).
* **Steps to Run**:
  1. Clone or download the repository from GitHub.
  2. Open `main.xcodeproj` in Xcode.
  3. Select an **iOS Simulator** destination (e.g., iPhone 16 / iPhone 17 running iOS 18+).
  4. Press `Cmd + R` to build and run.
* **Note on Device vs. Simulator**: Run on an iOS Simulator. A physical device requires setting up your own Apple Developer Account and signing certificates under the target's *Signing & Capabilities* tab.
* **Running Tests**:
  * Press `Cmd + U` in Xcode to execute the unit test suite.

---

## 2. Assumptions Made

1. **Toolchain & Environment**:
   * It is assumed that this project will be compiled and run on **Xcode Version 26.5 (17F42)** with **Swift Language Version 6**, which is the primary toolchain utilized during development. All Swift Concurrency annotations, Sendable semantics, and actor isolations adhere to Swift 6 strict concurrency checks.
2. **Data Scalability**:
   * While the current FPL dataset contains 20 teams and ~600–700 players, the architecture assumes this dataset could expand significantly in the future (e.g. historical data, multi-league expansions with tens of thousands of players).
   * Persisting raw JSON directly on disk or in-memory would introduce significant RAM spikes and JSON parsing bottlenecks on app launch. Core Data (backed by SQLite) was chosen to support efficient indexing, predicate-based querying, and lazy pagination without loading entire payloads into memory.
3. **Data Security, Privacy & Encryption**:
   * The application does not collect, process, or store any personal data or Personally Identifiable Information (PII), and therefore does not fall under GDPR compliance requirements. Because the dataset consists exclusively of public sports statistics, data encryption (at rest or via custom crypto layers) and Keychain storage were deliberately omitted to avoid unnecessary computational and battery overhead.
4. **Data Storage Suitability**:
   * `UserDefaults` was strictly limited to lightweight metadata (such as HTTP ETags). Storing full model payloads or lists in `UserDefaults` was avoided because doing so bloats the app's `.plist` file, causing it to be loaded synchronously into memory and slowing app launch times.
5. **Team Ordering**:
   * Teams are assumed to be displayed in ascending order of their unique `id` (matching the API's default ordering and sorted via `id` in `CDTeamRepository`), rather than alphabetically by name or by league table standings.
6. **Device Support & Screen Orientation**:
   * The application is targeted exclusively for **iOS iPhone devices in portrait orientation**. Landscape orientation, iPad split-view/multitasking, and macOS Catalyst/watchOS variants are currently not supported.

---

## 3. Architectural Decisions & Why

### Architecture Overview: MVVM + Repository + Navigator + POP
The application adheres strictly to **Protocol-Oriented Programming (POP)**, **SOLID principles**, loose coupling, and dependency injection via protocols.

```
┌────────────────────────┐         ┌────────────────────────┐
│  TeamsViewController   │ ◄────── │     TeamsViewModel     │
└────────────────────────┘         └───────────┬────────────┘
            │                                  │
            ▼                                  ▼
┌────────────────────────┐         ┌────────────────────────┐
│     TeamsNavigator     │         │     FPLDataService     │
└───────────┬────────────┘         └─────┬────────────┬─────┘
            │                            │            │
            ▼                            ▼            ▼
┌────────────────────────┐    ┌───────────────┐ ┌───────────────┐
│  SquadViewController   │    │ FPLAPIService │ │ Core Data /   │
└────────────────────────┘    │  (URLSession) │ │ Repositories  │
                              └───────────────┘ └───────────────┘
```

1. **Protocol-Oriented Programming (POP) & Dependency Inversion**:
   * Every architectural layer is defined by protocols (`TeamsViewModelable`, `SquadViewModelable`, `PlayerRepository`, `TeamRepository`, `FPLAPIServicable`, `FPLDataServicable`, `PersistentStoragable`, `ETagStore`, `KeyValueStore`).
   * Repositories accept injected `PersistentStoragable` interfaces rather than referencing singletons directly, allowing clean unit testing with lightweight in-memory test doubles and zero side effects.
2. **MVVM (Model-View-ViewModel)**:
   * Keeps ViewControllers lightweight and focused purely on UI rendering and Auto Layout constraints.
   * Business logic, sorting, filtering, and data formatting reside strictly inside ViewModels (`TeamsViewModel`, `SquadViewModel`).
3. **Explicit State Machines (Enums over Booleans)**:
   * Instead of managing disjointed boolean flags (`isLoading`, `hasError`, `isEmpty`), screens are driven by mutually exclusive state enums (`TeamsViewState`, `SquadViewState`, `CacheState`).
   * This guarantees invalid states are impossible and makes adding future states (e.g., editing, filtering) straightforward.
4. **Navigator / Coordinator Pattern**:
   * Navigation from the Teams screen to the Squad screen is delegated to `TeamsNavigator`.
   * This decouples ViewControllers from knowing about destination controllers, simplifying unit testing and making screen transitions easily interchangeable or extensible for CRUD operations.
5. **Centralized Theming & Presentation Layer (`AppTheme`)**:
   * UI styling, position badge colors, player availability indicators, and dynamic team color palettes are centralized inside `AppTheme.swift`.
   * This completely decouples presentation/color logic from data models (`PlayerPosition`, `PlayerStatus`) and views, providing a single source of truth for design tokens.
6. **Isolated Core Data Concurrency**:
   * Heavy batch ingestion and player/team creation are strictly isolated to private background contexts via `getBackgroundContext().perform { ... }`, keeping the main thread free for smooth 60fps scrolling.
   * `viewContext` automatically merges changes (`automaticallyMergesChangesFromParent = true`) using `NSMergeByPropertyObjectTrumpMergePolicy` for seamless UI synchronization without UI lockups.
7. **Selective Deserialization & Single-Pass Parse**:
   * The raw `bootstrap-static` JSON payload is ~2.5–3 MB and contains over 50 fields per player and 25 per team.
   * `FPLBootstrapResponse` decodes and persists only the fields utilized by the app (~9 per player, 3 per team), discarding ~85% of unused JSON overhead off the main thread via `Task.detached`.
8. **Offline Persistence & Stale-While-Revalidate UX**:
   * Core Data provides persistent local storage across cold launches.
   * On cold launch, cached data is loaded immediately into the UI. Revalidation occurs concurrently in a background task, ensuring the user is never blocked by a network spinner when local data is available.

---

## 4. Brainstorming, Prioritization & Caching Strategy

### 4.1 Prioritization Within the Time-Box (20–40 min)
When reviewing the requirements against the recommended 20–40 minute time frame, I identified multiple potential avenues for implementation. Following the instruction to *"prioritise correctness, code quality, native iOS implementation, and thoughtful handling of asynchronous state"*, I systematically brainstormed and prioritized as follows:

1. **High Priority (Core Deliverables — Completed)**:
   * **Correctness & Complete UX**: All required screens (Teams and Squad grouped by position and sorted by points), real-time search, pull-to-refresh, retry, and all 6 loading/error UI states.
   * **Robust Offline Persistence**: Using Core Data with SQLite batch ingestion rather than dumping raw JSON files on disk, ensuring scalable querying.
   * **Protocol-Oriented Architecture (POP)**: Clean separation of concerns (MVVM + Repositories + Navigator + Dependency Injection) so every module is easily mockable and testable.
   * **Swift 6 Concurrency & Unit Tests**: Full adherence to modern Swift Concurrency (`Sendable`, actor isolation) and unit test coverage for decoding, transformations, filtering, and caching with zero dependencies on the live API.

2. **Medium Priority (Postman Inspection & Cache Policy Trade-Off)**:
   * **Postman Header Observation**: During initial API exploration in Postman, I inspected the response headers and identified:
     * `Content-Encoding: gzip` — Supported transparently by `URLSession.shared`.
     * `Cache-Control: max-age=300` — Indicates the server considers data fresh for 5 minutes (300 seconds).
     * `ETag` — Allows conditional requests via `If-None-Match` to return `304 Not Modified`.
   * **Architectural Trade-Off & Decision**:
     * While native `URLCache` can automatically manage HTTP cache headers, on iOS it has known real-world limitations (unpredictable cache eviction under disk pressure, payload size thresholds, and failure to persist across cold launches).
     * Furthermore, `URLCache` only stores raw HTTP responses—it does not support predicate-based filtering, diacritic-insensitive player search, or relation mapping.
     * Therefore, I prioritized building **deterministic offline persistence via Core Data** and a **custom ETag store (`UserDefaultsETagStore`)** sending `If-None-Match` and handling `304 Not Modified`.
   * **Why Full Cache-Control was Not Fully Implemented**:
     * Fully respecting `max-age=300` requires client-side TTL tracking (`Date().timeIntervalSince(lastFetch) < 300`) to completely bypass network dispatch within the freshness window. Given the time constraints, I chose to prioritize deterministic offline Core Data fallback and 304 payload elimination, leaving client-side TTL enforcement as a clearly documented next step.

3. **Low Priority (Deferred to Future Improvements)**:
   * Advanced UI animations, XcodeGen project generation, CI/CD automated test workflows, and complex reactive bindings (`Box<T>`).

---

## 5. Anything You Would Improve with More Time

1. **Full Cache-Control Freshness Window (Client-Side TTL)**:
   * Add a `lastFetchTimestamp` check in `FPLDataService` or `UserDefaultsETagStore` honoring the server's `max-age=300`. If `Date().timeIntervalSince(lastFetch) < 300`, skip the network request entirely on standard launches, eliminating even the lightweight 304 round-trip.
2. **In-Flight Request Deduplication**:
   * Maintain an active `Task<(FPLBootstrapResponse?, String?), Error>?` in `FPLAPIService` to coalesce simultaneous requests if multiple screens or triggers request bootstrap data at the same time.
3. **Box Architecture for Reactive View Updates**:
   * While the current implementation uses clean closure bindings (`stateDidChange`, `contentDidChange`), introducing a generic `Box<T>` / `Observable<T>` pattern would formalize data binding across ViewModels without introducing third-party reactive dependencies (like Combine or RxSwift), providing a consistent and scalable reactive binding system.
4. **XcodeGen Integration**:
   * Add a `project.yml` configuration to generate the Xcode project deterministically, avoiding `.pbxproj` merge conflicts in team workflows.
5. **CI/CD Pipelines & Automated Workflows**:
   * Set up GitHub Actions or Xcode Cloud CI/CD pipelines to automate build validation, execute unit tests across multiple iOS Simulator destinations on every pull request, and run static analysis (SwiftLint) to guarantee code quality before merging.
6. **Type-Safe Assets & Localization**:
   * Integrate SwiftGen or Xcode String Catalogs for strongly-typed localization (`Localizable.strings`) and asset symbols instead of raw strings.
7. **Protocol-Driven Cell Configuration**:
   * Formalize cell configuration using reusable cell configurator protocols or generic list adapters.
8. **Retry with Exponential Backoff & Jitter**:
   * Add a 1-shot exponential backoff retry for transient network timeouts (e.g., `URLError.timedOut` or 503 errors).
9. **Test Suite Expansion**:
   * Add comprehensive performance tests for large Core Data batch insertions and snapshot UI regression tests.

---

## 6. Known Limitations

* **Code Signing on Physical Devices**: Because development team certificates and provisioning profiles are omitted from the open-source submission, the project must be run on an **iOS Simulator** unless personal signing credentials are added.
* **Static Colors for New Teams**: Team badge colors are mapped from a predefined palette; newly promoted clubs without dedicated palette entries fall back to deterministic hash colors rather than dynamic SVG/PNG asset badges.
