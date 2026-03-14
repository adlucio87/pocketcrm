# TwentyMobile

TwentyMobile è un'applicazione mobile sviluppata in **Flutter** che funge da client unificato per CRM backend, partendo dall'integrazione con **Twenty CRM**. L'obiettivo del progetto è permettere agli utenti di gestire contatti, aziende, note e task in mobilità, con un'interfaccia moderna, veloce e reattiva.

**Namespace del progetto:** `com.luciosoft.pocketcrm`

## 🌟 Funzionalità Implementate

- **Onboarding & Autenticazione:** Connessione a un'istanza self-hosted di Twenty CRM tramite URL e API Token personalizzati, salvati in modo sicuro.
- **Gestione Contatti:**
  - Lista contatti interattiva con funzionalità di ricerca testuale rapida.
  - Dettaglio contatto con raggruppamento delle informazioni.
  - Creazione e modifica rapida dei contatti con **aggiornamento ottimistico** (Optimistic UI) per un feedback visuale immediato.
  - Salvataggio diretto del contatto nella rubrica del telefono (integrazione nativa).
  - Tap sulle azioni rapide per inviare email o avviare chiamate telefoniche direttamente dall'app.
- **Gestione Aziende (Companies):**
  - Lista aziende e pagina di dettaglio dedicata.
  - Visualizzazione dei contatti collegati all'azienda.
  - Collegamento diretto per aprire il sito web dell'azienda nel browser.
- **Appunti e Note:**
  - Visualizzazione cronologica delle note collegate a Contatti e Aziende.
  - Creazione di nuove note testuali direttamente dal dettaglio dell'entità.
  - Modifica rapida delle note esistenti tramite Bottom Sheet dedicato.
  - Supporto per il rendering dei contenuti block-based di Twenty CRM.
- **Gestione Task:**
  - Lista dei task assegnati con filtro dinamico per stato (Da completare / Completati).
  - Funzione "Mark as done" con transizioni fluide.
  - Creazione di nuovi task con assegnazione di una data di scadenza (tramite un Due Date Picker rapido integrato).

## 🏛 Architettura e Struttura del Progetto

L'architettura segue i principi del **Domain-Driven Design (DDD)** uniti a un approccio **Feature-First** nella directory di presentazione. L'app usa il **Connector Pattern** per astrarre le chiamate al CRM sorgente.
Esiste un'interfaccia astratta `CRMRepository` implementata da `TwentyConnector` (il client GraphQL per Twenty CRM). Questo permette future espansioni verso altri CRM senza modificare la logica di business o la UI.

La struttura completa delle cartelle all'interno di `lib/` è la seguente:

```text
lib/
├── main.dart
├── core/
│   ├── di/                         # Dependency injection globale (Riverpod e Repository provider)
│   ├── router/                     # Configurazione delle rotte dell'app con GoRouter
│   ├── theme/                      # Design system tematico, colori nativi, tipografia
│   └── utils/                      # Helper globali, costanti e estensioni Dart
├── domain/
│   ├── models/                     # Modelli dati di core (Contact, Company, Note, Task) autogenerati con Freezed
│   ├── repositories/               # Interfacce astratte (CRMRepository)
│   └── usecases/                   # Logiche di business centralizzate se svincolate dal singolo provider
├── data/
│   ├── connectors/
│   │   └── twenty_connector.dart   # Implementazione GraphQL e parser specifica per Twenty CRM
│   ├── local/                      # Storage locale per cache (es. Hive / SharedPrefs)
│   └── graphql/                    # File .graphql contenenti query e mutation originali
├── presentation/                   # Strato UI organizzato rigorosamente per funzionalità (Feature-First)
│   ├── onboarding/                 # Schermate di configurazione iniziale (setup URL istanza + API token)
│   ├── contacts/                   # Modulo per la lista e la ricerca dei contatti
│   ├── contact_detail/             # Schermata di dettaglio del singolo contatto con estensioni
│   ├── companies/                  # Modulo per la lista aziende e relativo dettaglio
│   ├── notes/                      # Bottom sheet e widget isolati per la visualizzazione/modifica note
│   ├── tasks/                      # Lista dei task pendenti e completati e creation screen
│   └── shared/                     # Componenti UI condivisi cross-feature (es. widget per relazioni incrociate, picker d'uso comune)
└── shared/                         # Codice condiviso puramente estetico
    └── widgets/                    # UI blocks di basso livello (es. Renderer BlockNote, loader)
```

## 🛠 Stack Tecnologico Principale

- **Framework:** Flutter (Mobile, iOS/Android ready)
- **Gestione Stato & DI:** Riverpod (`flutter_riverpod`, `riverpod_annotation`)
- **Routing Multi-Path:** GoRouter
- **Integrazioni e API:** GraphQL (`graphql_flutter`), per eseguire query, mutation e introspezioni.
- **Generazione Codice:** Freezed & JSON Serializable per serializzazione dichiarativa JSON -> Model
- **Privacy & Storage:** Flutter Secure Storage

## 🚀 Sviluppo e Setup

Per avviare il progetto localmente:

1. Assicurati di avere l'SDK di Flutter installato.
2. Esegui il pull dei pacchetti:
   ```bash
   flutter pub get
   ```
3. Rigenera il codice dei modelli e provider (Riverpod & Freezed):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Lancia l'app su un simulatore (avendo testato a fondo i widget di layout):
   ```bash
   flutter run
   ```

5. Compila l'app per il rilascio:
   ```bash
   flutter build appbundle --release
   ```

## 📄 Licenza
PocketCRM è un progetto open-source distribuito sotto licenza **AGPL-3.0**.
