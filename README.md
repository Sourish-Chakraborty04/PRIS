# PRIS - Personal Resource IntelliSense 🚀

PRIS is a comprehensive **Personal Finance Tracking** application built with Flutter. It is designed for individuals who need to manage their daily work shifts alongside their expenses, providing a unified view of income and spending.

## 🌟 Key Features

* **Dual Tracking:** Log work shifts and daily expenses in one place.
* **Intelligent Categorization:** A custom keyword-based sorting engine that automatically organizes your data.
* **Vehicle Management:** Dedicated `bike_profile` module to track maintenance and related costs.
* **Offline First:** Powered by a robust SQLite backend (`pris_vault.db`) for high performance and data privacy.
* **Dynamic UI:** Clean, modern interface built with Flutter and Dart.

## 🛠️ Tech Stack

* **Frontend** <img src="https://images.seeklogo.com/logo-png/35/2/flutter-logo-png_seeklogo-354671.png" width="30"/> & <img src="https://images.seeklogo.com/logo-png/27/2/dart-logo-png_seeklogo-273023.png" width="25"/><br>
* **Database**      <img src="https://p7.hiclipart.com/preview/508/195/802/sqlite-relational-database-management-system-redis-square-icon-thumbnail.jpg" width="30"/><br>
* **Versions**      <img src="https://cdn.iconscout.com/icon/free/png-256/free-git-icon-svg-download-png-1175219.png?f=webp&w=128" width="30"/> & <img src="https://www.pngmart.com/files/22/GitHub-PNG-Background-Image.png" width="30"/>

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
```

## 🚀 How to Use PRIS Locally(Untill it is published publically)

Prerequisites: Ensure you have the Flutter SDK (3.x) and Dart installed.

Clone the repository:

```Bash
git clone https://github.com/Sourish-Chakraborty04/PRIS.git
```
Install dependencies:

```Bash
flutter pub get
```
Run the app:

```Bash
flutter run
```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

* **Fork the Project** 🍴
* **Create your Feature Branch** 🪶
* **Commit your Changes** 🔐
* **Push to the Branch** 🫸🏽
* **Open a Pull Request** 👮🏽‍♂️

### 📄 License

You can add new feature to this application and if you create something from it just drop a credit or just reach out to me.

### ✉️ Contact the Author

<a href="https://github.com/Sourish-Chakraborty04">Sourish Chakraborty</a>

### Project Link: https://github.com/Sourish-Chakraborty04/PRIS

Developed with ❤️ for better personal management.