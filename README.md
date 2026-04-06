# PRIS - Personal Records & Information System 🚀

PRIS is a comprehensive **Personal Finance & Shift Tracking** application built with Flutter. It is designed for individuals who need to manage their daily work shifts alongside their expenses, providing a unified view of income and spending.

## 🌟 Key Features

* **Dual Tracking:** Log work shifts and daily expenses in one place.
* **Intelligent Categorization:** A custom keyword-based sorting engine that automatically organizes your data.
* **Vehicle Management:** Dedicated `bike_profile` module to track maintenance and related costs.
* **Offline First:** Powered by a robust SQLite backend (`pris_vault.db`) for high performance and data privacy.
* **Dynamic UI:** Clean, modern interface built with Flutter and Dart.

## 🛠️ Tech Stack

* **Frontend:** <img src="https://images.seeklogo.com/logo-png/35/2/flutter-logo-png_seeklogo-354671.png" /> & <img src="https://images.seeklogo.com/logo-png/27/2/dart-logo-png_seeklogo-273023.png" />
* **Database:** <img src="https://images.seeklogo.com/logo-png/27/1/sqlite-logo-png_seeklogo-273915.png" />
* **Version Control:** <img src="https://cdn.iconscout.com/icon/free/png-256/free-git-icon-svg-download-png-1175219.png?f=webp&w=128" />
  <img src="https://www.pngmart.com/files/22/GitHub-PNG-Background-Image.png" />

## 📂 Database Architecture

The application uses a relational schema to ensure data integrity:
* `shifts`: Stores work timing and earnings.
* `expenses`: Detailed logs of daily spending.
* `bike_profile`: Tracks vehicle-specific data and maintenance schedules.
* `categories`: Customizable tags for the sorting engine.

## 📂 Project File Structure

```text
PRIS/
├── android/              # Android-specific configurations
├── ios/                  # iOS-specific configurations
├── lib/                  # Main project code
│   ├── database/         # SQLite database handlers & schemas
│   │   └── db_helper.dart
│   ├── models/           # Data models (Shifts, Expenses, etc.)
│   ├── screens/          # App screens (Home, Profile, etc.)
│   ├── services/         # Keyword sorting engine & logic
│   └── main.dart         # Entry point of the app
├── assets/               # Images, fonts, and static data
├── pubspec.yaml          # Project dependencies & metadata
└── README.md             # Project documentation

## 🚀 Getting Started

### Prerequisites
* Flutter SDK installed
* Android Studio / VS Code with Flutter extensions
* Dart 3.x

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/Sourish-Chakraborty04/PRIS.git](https://github.com/Sourish-Chakraborty04/PRIS.git)