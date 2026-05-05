# TwentyMobile

TwentyMobile is a native mobile application developed with **Flutter** that serves as a unified client for CRM backends, starting with an integration with **Twenty CRM**. The project's goal is to allow users to manage contacts, companies, notes, and tasks on the go, with a modern, fast, and responsive interface.

**Official Website:** [twentymobilecrm.luciosoft.it](https://twentymobilecrm.luciosoft.it/)



**Project Namespace:** `com.luciosoft.pocketcrm`

## 🌟 Implemented Features

- **Onboarding & Authentication:** Connection to a self-hosted Twenty CRM instance via URL with two access modes: **API Token** (for administrators) or **Email/Password** (for standard users). Secure credential storage and integration with Sentry for error monitoring.
- **Demo Mode:** Full exploration of the interface and features through an isolated test environment with a security lock on mutations.
- **Dashboard (Home):** A quick overview to start the day, featuring dynamic greetings, upcoming tasks, today's tasks, and recently viewed contacts.
- **Contact Management:**
  - Interactive contact list with quick search functionality.
  - Comprehensive contact detail view.
  - Rapid creation and editing of contacts with **optimistic updates** (Optimistic UI).
  - Contact sharing and direct export to the system's address book (iOS/Android).
  - Rapid capture via integrated **Business Card Scanner**.
  - Quick actions for sending emails or starting phone calls.
- **Company Management:**
  - Company list and dedicated detail page with linked contacts.
  - Fast opening of company websites in the native browser.
- **Advanced Notes:**
  - Chronological view of linked notes.
  - Quick text note taking from details or home screen.
  - Secure **Voice Note** recording, allowing you to dictate and save information hands-free.
- **Task Management & Notifications:**
  - List of assigned tasks with dynamic filtering (To Do / Completed).
  - **Task Assignment:** Support for assigning tasks to specific workspace members (automatic for email login, manual via dropdown for admins).
  - Scheduling with due dates.
  - Advanced notification system (local push notifications) to remind about upcoming or overdue tasks.
- **UI/UX & Localization:**
  - Configuration and onboarding interface entirely in **English**.
  - Robust adaptive layouts for software keyboard handling (preventing unintended rebuilds and text selections).
  - Automatic cache invalidation on user change to ensure the integrity of displayed data.

## 🏛 Architecture and Project Structure

The architecture follows **Domain-Driven Design (DDD)** principles combined with a **Feature-First** approach in the presentation layer. The app uses the **Connector Pattern** to abstract calls to the source CRM.
An abstract `CRMRepository` interface is implemented by `TwentyConnector` (the GraphQL client for Twenty CRM). This allows for future expansions to other CRMs without modifying business logic or the UI.

The structure inside `lib/` is organized by feature:

```text
lib/
├── core/                           # Global dependency injection (Riverpod), Router, Theme, Utils, Notifications
├── domain/                         # Core data models (Contact, Company, Note, Task), Repository interfaces
├── data/                           # GraphQL implementation (TwentyConnector), local storage Hive/SecureStorage
├── presentation/                   # UI Layer (Feature-First)
│   ├── onboarding/                 # Initial setup and Demo access
│   ├── home/                       # Dashboard 
│   ├── contacts/                   # Contact module
│   ├── contact_detail/             # Contact details, voice note player/recorder
│   ├── companies/                  # Company module
│   ├── scan/                       # Business card scanner
│   ├── notes/                      # Text notes module
│   └── tasks/                      # Tasks module
└── shared/                         # Aesthetic widgets and cross-feature components (e.g., Demo block)
```

## 🛠 Main Technology Stack

- **Framework:** Flutter (Mobile, iOS/Android ready)
- **State Management & DI:** Riverpod (`flutter_riverpod`, `riverpod_annotation`)
- **Multi-Path Routing:** GoRouter
- **API Integrations:** GraphQL (`graphql_flutter`)
- **Code Generation:** Freezed & JSON Serializable
- **Notifications:** `flutter_local_notifications`, `timezone`
- **Security & Storage:** Flutter Secure Storage, Hive

## 🚀 Development and Setup

To start the project locally:

1. Ensure you have the Flutter SDK installed.
2. Pull the packages:
   ```bash
   flutter pub get
   ```
3. Regenerate the code for models and providers (Riverpod & Freezed):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Launch the app on a simulator (having thoroughly tested the layout widgets):
   ```bash
   flutter run
   ```

5. Build the app bundle for Android App Store release:
   ```bash
   flutter build appbundle --release
   ```

## 📄 License
TwentyMobile is an open-source project distributed under the **AGPL-3.0** license.
