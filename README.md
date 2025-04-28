# Itunda Flutter App

A modern community marketplace and food delivery app connecting neighborhoods, built with Flutter.

## 🌟 Features

### 🏠 Neighborhood
- Community posts and discussions
- Location-based content
- Category-based filtering
- Real-time updates using WebSocket

### 🛒 Marketplace
- Product listings
- Seller profiles
- Reviews and ratings
- Bookmarking system
- Search and filtering

### 🍽️ Food Delivery (Eats)
- Restaurant listings
- Menu management
- Cart functionality
- Order tracking
- Rating system

### 💼 Jobs
- Job postings
- Job categories
- Application system
- Job search

### 💬 Chat
- Real-time messaging
- Chat history
- User profiles

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode for mobile development
- Git

### Installation

1. Clone the repository
```bash
git clone https://github.com/partoftrue/itunda_flutter.git
cd itunda_flutter
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── core/                 # Core functionality
│   ├── auth/            # Authentication
│   ├── components/      # Shared components
│   ├── config/          # Configuration
│   ├── navigation/      # Navigation
│   ├── network/         # Network handling
│   ├── providers/       # State management
│   ├── services/        # Core services
│   └── theme/           # App theming
├── features/            # Feature modules
│   ├── neighborhood/    # Neighborhood feature
│   ├── marketplace/     # Marketplace feature
│   ├── eats/           # Food delivery
│   ├── jobs/           # Jobs feature
│   └── chat/           # Chat feature
└── main.dart           # App entry point
```

## 🛠️ Tech Stack

- **State Management**: Provider, Riverpod
- **Navigation**: Go Router
- **Network**: Dio, HTTP
- **Storage**: SharedPreferences, SQLite, Hive
- **UI**: Material Design, Google Fonts
- **Authentication**: Firebase Auth
- **Location**: Geolocator
- **Real-time**: WebSocket (STOMP)
- **Image Handling**: Cached Network Image
- **Performance**: Flutter DisplayMode, Lazy Loading

## 🔒 Environment Setup

Create a `.env` file in the root directory with the following variables:

```env
API_BASE_URL=your_api_url
FIREBASE_API_KEY=your_firebase_key
GOOGLE_MAPS_API_KEY=your_maps_key
```

## 🎨 Theming

The app supports both light and dark themes, with a custom color scheme defined in `lib/core/theme/app_theme.dart`.

## 📱 Screenshots

[Add screenshots here]

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **[Your Name]** - *Initial work*

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All contributors who have helped this project grow
