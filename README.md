# CleanSL Mobile Application

> A comprehensive, smart waste management mobile ecosystem bridging the gap between municipal waste collection services and local residents, ensuring a cleaner, greener, and more transparent city infrastructure.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Core Modules](#core-modules)
   - [Resident Interface](#resident-interface)
   - [Driver Interface](#driver-interface)
3. [Technical Stack](#technical-stack)
4. [Project Structure](#project-structure)
5. [Academic Context](#academic-context)

---

## Project Overview

CleanSL is developed to digitize and streamline municipal waste management. The mobile application is architected to serve two distinct user bases with highly optimized interfaces. It focuses on real-time transparency, scheduling, and environmental impact tracking for residents, while prioritizing low-friction, high-speed reporting and route management for frontline drivers.

---

## Core Modules

### Resident Interface
The resident module is built to provide transparency, educate the public, and offer real-time updates regarding waste collection.

* **Real-Time Truck Tracking:** Live Google Maps integration polling driver locations via a custom tracking service. Features custom UI markers, automatic camera bounding, and dynamic ETA calculations.
* **Smart Home Dashboard:** A dynamic "Next Pickup" card that updates its progress bar and status text in real-time, switching seamlessly between scheduled states and active en-route tracking.
* **Collection Certificates & Impact Tracking:** Every completed pickup generates a digital certificate. Residents can track their personal environmental footprint, viewing dynamic metrics like CO2 emissions prevented, energy saved, and water conserved based on the specific waste category (Organic, Recyclables, General).
* **Recent Activity Log:** A filterable and searchable history of all user interactions. Intelligent routing seamlessly navigates users to either their completed pickup certificates or the detailed status pages of their filed complaints.
* **Pickup Scheduling & Reminders:** An interactive schedule page displaying in-progress, upcoming, and completed pickups, utilizing custom blurred-background reminder dialogs.

### Driver Interface
The driver module is built for efficiency, specifically targeting frontline workers who require low-friction, fast interactions.

* **Voice-to-Action Reporting:** A highly accessible, one-tap voice recording module. Drivers can report operational issues (e.g., overflowing bins, blocked routes) without typing.
* **Background Audio Processing:** Audio is captured in high-quality WAV format and securely uploaded to a backend for transcription, allowing the driver to continue their route uninterrupted.
* **Report History:** An integrated history screen fetching past transcriptions, utilizing an audio player to allow drivers to listen to previously submitted reports.
* **Driver Profile & Fleet Assignment:** Dynamic profiles displaying the driver's Employee ID, active Assigned District, and Primary Vehicle details.
* **Route & Ward Selection:** A streamlined, visual grid for drivers to select their active sector and launch their specific route paths.

---

## Technical Stack

| Component | Technology / Package | Description |
| :--- | :--- | :--- |
| **Frontend Framework** | Flutter (Dart) | Cross-platform mobile development |
| **Mapping & Geolocation** | Google Maps Flutter | Live tracking, custom markers, and bounding |
| **Audio Engine** | `record`, `audioplayers` | Low-latency voice capture and playback |
| **Networking & APIs** | `http` | REST API communication (Render backend integration) |
| **Storage** | Supabase | Secure cloud storage for audio files and assets |
| **State Management** | Stateful Widgets, Streams | Timer-based polling and stream subscriptions for live updates |
| **UI/UX & Theming** | Custom `AppTheme` | 8pt grid system, responsive scaling, Google Fonts (Inter, Roboto Slab) |

---

## Project Structure

The project follows a feature-first, modular architecture to ensure maintainability and separation of concerns across the SDGP team:

```text
lib/
├── core/
│   ├── services/          # Shared backend services, API integrations, and Supabase logic
│   ├── theme/             # Global AppTheme, colors, and typography definitions
│   └── utils/             # Responsive scaling utilities and shared constants
├── features/
│   ├── common/            # Shared features across user roles
│   │   └── onboarding/    # Welcome screens and role selection (Resident vs. Driver)
│   ├── driver/            # Driver-specific domain
│   │   ├── driver_auth/   # Driver authentication flow and sign-in pages
│   │   └── home/          # Dashboard, Ward Selection, Route logic, and Voice Reports
│   └── resident/          # Resident-specific domain
│       ├── complaints/    # Issue reporting, photo uploads, and status tracking
│       ├── guide/         # Educational content, disposal tips, and waste sorting rules
│       ├── home/          # Smart Dashboard, ETA cards, and Recent Activity log
│       ├── main_nav/      # Bottom navigation bar and primary routing logic
│       ├── profile/       # Resident account settings and preferences
│       ├── resident_auth/ # Resident authentication flow (Sign up / Log in)
│       └── schedule/      # Live Tracking, Certificates, Reminders, and Route maps
├── shared/
│   └── widgets/           # Reusable UI components (e.g., CleanSlButton, Status Pills)
└── main.dart              # Application entry point


Academic Context
This application is developed as the practical implementation for a 2nd-year Bsc (Hons) Computer Science Software Development Group Project (SDGP). It demonstrates the practical application of mobile UX design, real-time data handling, external REST API integration, and hardware-level feature access (Microphone and GPS).
