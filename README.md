# PRIS - Personal Records & Information System 🚀

PRIS is a comprehensive **Personal Finance & Shift Tracking** application built with Flutter. It is designed for individuals who need to manage their daily work shifts alongside their expenses, providing a unified view of income and spending.

## 🌟 Key Features

* **Dual Tracking:** Log work shifts and daily expenses in one place.
* **Intelligent Categorization:** A custom keyword-based sorting engine that automatically organizes your data.
* **Vehicle Management:** Dedicated `bike_profile` module to track maintenance and related costs.
* **Offline First:** Powered by a robust SQLite backend (`pris_vault.db`) for high performance and data privacy.
* **Dynamic UI:** Clean, modern interface built with Flutter and Dart.

## 🛠️ Tech Stack

* **Frontend:** <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" /> & <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
* **Database:** <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" /> (via `sqflite`)
* **Version Control:** <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" />

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