# PRIS - Personal Records & Information System 🚀

PRIS is a comprehensive **Personal Finance & Shift Tracking** application built with Flutter. It is designed for individuals who need to manage their daily work shifts alongside their expenses, providing a unified view of income and spending.

## 🌟 Key Features

* **Dual Tracking:** Log work shifts and daily expenses in one place.
* **Intelligent Categorization:** A custom keyword-based sorting engine that automatically organizes your data.
* **Vehicle Management:** Dedicated `bike_profile` module to track maintenance and related costs.
* **Offline First:** Powered by a robust SQLite backend (`pris_vault.db`) for high performance and data privacy.
* **Dynamic UI:** Clean, modern interface built with Flutter and Dart.

## 🛠️ Tech Stack

* **Frontend:** [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
* **Database:** [SQLite](https://sqlite.org/index.html) (via `sqflite`)
* **State Management:** Provider / Bloc (Update as per your specific choice)
* **Version Control:** Git & GitHub

## 📂 Database Architecture

The application uses a relational schema to ensure data integrity:
* `shifts`: Stores work timing and earnings.
* `expenses`: Detailed logs of daily spending.
* `bike_profile`: Tracks vehicle-specific data and maintenance schedules.
* `categories`: Customizable tags for the sorting engine.

## 🚀 Getting Started

### Prerequisites
* Flutter SDK installed
* Android Studio / VS Code with Flutter extensions
* Dart 3.x

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/Sourish-Chakraborty04/PRIS.git](https://github.com/Sourish-Chakraborty04/PRIS.git)