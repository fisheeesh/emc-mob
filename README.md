# Emotion Check-In Application

![Feature Graphic](assets/images/feature_graphic.png)

A Flutter-based mobile application that enables employees to check in their emotional state daily, helping organizations maintain better workplace wellness and employee engagement.

## 📱 About

The Emotion Check-In Application (EMC) is designed to help organizations track and understand employee emotional well-being. By providing a simple, intuitive interface for daily emotional check-ins, the app helps HR teams and management gain insights into workplace sentiment and take timely actions to improve employee satisfaction and productivity.

## 📑 Table of Contents

- [About](#-about)
- [Key Features](#-key-features)
- [Technical Stack](#️-technical-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Architecture](#️-architecture)
- [App Screens](#-app-screens)
- [Security Features](#-security-features)
- [API Integration](#-api-integration)
- [Offline Functionality](#-offline-functionality)
- [Building for Production](#-building-for-production)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)
- [Project Background](#-project-background)
- [Download](#-download)
- [Privacy Policy](#-privacy-policy)
- [Version History](#-version-history)
- [License](#️-license)

## ✨ Key Features

### 🎭 Emotion Tracking
- **Daily Check-ins**: Quick and easy emotional state logging with emoji-based selections
- **Three Categories**: Emotions organized into Negative, Neutral, and Positive categories
- **Custom Notes**: Add personal notes to provide context for your emotional state
- **Historical View**: Calendar-based visualization of past check-ins

### 👤 User Management
- **Secure Authentication**: JWT-based login with automatic token refresh
- **Profile Management**: Edit personal information, upload avatars, and update contact details
- **Employee Information**: View department, position, and work-related details

### 📊 Data & Analytics
- **Check-in Calendar**: Visual representation of emotional patterns over time
- **Check-in Details**: View past entries with timestamps and notes
- **Offline Support**: SQLite local storage for offline functionality
- **Data Synchronization**: Automatic sync with backend when online

### 🔒 Security & Privacy
- **Secure Storage**: Flutter Secure Storage for sensitive data
- **Token Management**: Automatic token refresh and session management
- **Encrypted Communication**: HTTPS-only API communication

## 🛠️ Technical Stack

### Frontend
- **Framework**: Flutter 3.9.2
- **State Management**: Provider
- **Local Storage**: SQLite (sqflite)
- **Secure Storage**: flutter_secure_storage
- **UI Components**: Material Design 3

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.5+1
  http: ^1.5.0
  flutter_secure_storage: ^9.2.4
  sqflite: ^2.4.2
  jwt_decoder: ^2.0.1
  google_fonts: ^6.3.2
  table_calendar: ^3.2.0
  intl: ^0.20.2
  image_picker: ^1.2.0
  shared_preferences: ^2.5.3
```

## 📁 Project Structure

```
lib/
├── components/          # Reusable UI components (buttons, form fields)
├── database/           # SQLite database helper
├── enums/              # Application enums
├── models/             # Data models
│   ├── check_in_model.dart      # Check-in record structure
│   ├── emotion_model.dart        # Emotion categories and items
│   └── employee_model.dart       # Employee profile data
├── providers/          # State management providers
│   ├── check_in_provider.dart   # Check-in operations and state
│   ├── emotion_provider.dart    # Emotion data management
│   ├── employee_provider.dart   # Employee profile management
│   └── login_provider.dart      # Authentication and session
├── screens/            # Application screens
│   ├── auth/                    # Authentication flows
│   ├── main/                    # Core app screens (home, profile, check-in)
│   ├── onBoard/                 # Onboarding introduction
│   └── splash/                  # Splash screen
├── services/           # API service layer
│   ├── emotion_service.dart     # Emotion API calls and caching
│   └── employee_service.dart    # Employee data API calls
├── utils/              # Utility classes (constants, helpers, theme, validators)
└── main.dart           # Application entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/fisheeesh/emc_mob.git
   cd emc_mob
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   
   Update the API URLs in `lib/utils/constants/urls.dart`:
   ```dart
   static const String PROD_URL = "https://your-api-domain.com";
   ```

4. **Run the application**
   ```bash
   # For development
   flutter run
   
   # For production build
   flutter build apk  # Android
   flutter build ios  # iOS
   ```

## 🏗️ Architecture

### State Management
The app uses the **Provider** pattern for state management, with separate providers for:
- **LoginProvider**: Authentication and user session
- **CheckInProvider**: Emotion check-in operations
- **EmotionProvider**: Emotion categories and data
- **EmployeeProvider**: Employee profile management

### Data Flow
1. **Login**: User authenticates → Tokens stored securely → Navigate to Home
2. **Check-in**: Select emotion → Add notes → Submit to API → Store locally
3. **Sync**: App fetches latest data → Updates local DB → Refreshes UI
4. **Offline**: All operations work offline → Auto-sync when connection restored

### Local Database Schema

**checkins table**
```sql
CREATE TABLE checkins (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  emoji TEXT NOT NULL,
  textFeeling TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  checkInTime TEXT NOT NULL
)
```

## 📱 App Screens

### 1. Splash Screen
- Animated logo display
- Automatic navigation based on:
  - Onboarding status
  - Authentication status

### 2. Onboarding
- Two-page introduction
- Feature highlights
- Skip or complete flow

### 3. Login
- Email and password authentication
- Form validation
- Loading states
- Error handling

### 4. Home Screen
- Greeting based on time of day
- Calendar view of check-ins
- Check-in status indicator
- Quick access to profile settings

### 5. Emotion Check-in
- Three emotion categories (tabs)
- Grid of emotions with emojis
- Text input for additional notes
- Character counter (100 max)
- Submit with validation

### 6. Success Screen
- Confirmation message
- Check-in timestamp
- Emotion summary
- Return to home

### 7. Profile Screen
- Employee information display
- Avatar with initials fallback
- Department and role details
- Contact information
- Logout functionality

### 8. Edit Profile
- Update personal information
- Change avatar (image picker)
- Phone number validation
- Gender and birthdate selection
- Form validation and submission

## 🔐 Security Features

### Authentication
- JWT-based token authentication
- Automatic token refresh via backend middleware
- Secure token storage using flutter_secure_storage
- Token expiration validation

### Data Protection
- All API calls use HTTPS
- Sensitive data encrypted at rest
- No plain-text password storage
- Automatic session cleanup on logout

### Privacy
- User consent for data collection
- Optional profile information
- Local data cleared on logout
- No third-party analytics without consent

## 🌐 API Integration

### Authentication Endpoints
```
POST /api/v1/login
```

### User Endpoints
```
GET  /api/v1/user/my-history
POST /api/v1/user/check-in
GET  /api/v1/user/emotion-categories
GET  /api/v1/user/emp-data
PATCH /api/v1/user/emp-data
```

### Request Headers
```
Authorization: Bearer {access_token}
x-refresh-token: {refresh_token}
x-platform: mobile
Content-Type: application/json
```

## 📊 Offline Functionality

The app is designed to work seamlessly offline:

1. **Check-ins**: Stored locally in SQLite
2. **Emotions**: Cached with 24-hour refresh
3. **Profile**: Cached locally
4. **Sync**: Automatic background sync when online

### Cache Strategy
- Emotion categories cached for 24 hours
- Fallback data available if API fails
- Manual refresh available via pull-to-refresh

## 📦 Building for Production

### Android
```bash
# Generate release APK
flutter build apk --release

# Generate App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release

# Create archive in Xcode
open ios/Runner.xcworkspace
```

## 🔧 Configuration

### API Configuration
Update the API URLs in `lib/utils/constants/urls.dart`:

```dart
// Development URLs
static const String ANDROID_BASE_URL = "https://10.0.2.2:8080";
static const String IOS_BASE_URL = "https://192.168.1.185:8080";

// Production URL
static const String PROD_URL = "https://api.your-domain.com";
```

**Note**: 
- Android emulator uses `10.0.2.2` to access localhost on the host machine
- iOS simulator uses your local network IP address
- Update `PROD_URL` with your actual production API domain

## 🐛 Troubleshooting

### Common Issues

**Issue**: App crashes on startup
- **Solution**: Clear app data and reinstall

**Issue**: Login fails with network error
- **Solution**: Check API URL configuration in `urls.dart`

**Issue**: Images not loading
- **Solution**: Verify network permissions in AndroidManifest.xml

**Issue**: Token refresh fails
- **Solution**: Backend auth middleware must return new tokens in headers

## 🎓 Project Background

This application was developed as a **senior project** at **Mae Fah Luang University** by the **Software Engineering** department, originally inspired by and in collaboration with **ATA IT (Thailand)**.

### Academic Context
- **Institution**: Mae Fah Luang University
- **Department**: Software Engineering
- **Project Type**: Senior Project
- **Year**: 2024-2025

### System Ecosystem

This mobile application is part of the **Emotion Check-In System** ecosystem, which also includes:

- **EMC Web Application**: A comprehensive web-based dashboard for HR managers and administrators to view analytics, generate reports, and monitor employee emotional well-being across the organization.
- **Backend API**: RESTful API service that handles authentication, data storage, and business logic for both mobile and web applications.

The system aims to create a holistic approach to workplace wellness by combining daily emotional check-ins with actionable insights for management.

### Important Notes

> ⚠️ **Data Privacy & Responsibility**  
> All privacy inquiries and data subject requests should be directed to **6531503187@lamduan.mfu.ac.th**.  
> **ATA IT is not responsible** for the operation, data handling, or privacy practices of this application.

> 📧 **Contact Information**  
> For questions, support, or feedback about this project:
> - **Email**: 6531503187@lamduan.mfu.ac.th
> - **Website**: https://emotioncheckinsystem.com

### Acknowledgments

We would like to thank:
- **ATA IT (Thailand)** for the initial project inspiration and collaboration opportunity
- **Mae Fah Luang University** for academic guidance and support
- All my team members who helped shape this system to completion:
  - **Swan Yi Phyo** (Full-Stack Developer/Mobile Developer) - 6531503187
  - **Kaung Htut Hlaing** (Project Manager/Backend Developer) - 6531503145
  - **Khun Shine Si Thu** (UI/UX Designer) - 6531503149
  - **Myat Thu Kyaw** (Front-end Developer) - 6531503159

## 📱 Download

### Google Play Store
<img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" alt="Get it on Google Play" width="200"/>

**Status**: App currently in review. Will be available soon!

## 🔒 Privacy Policy

We take your privacy seriously. For detailed information about how we collect, use, and protect your data, please review our privacy policy.

[View Privacy Policy](privacy-policy.md)

## 📈 Version History

### v1.0.0 (Current)
- Initial release
- Basic emotion check-in functionality
- Profile management
- Calendar view
- Offline support

---

## ⚖️ License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

**Built with ❤️ by Software Engineering students at Mae Fah Luang University**

*Creating healthier, more empathetic workplaces where every voice matters and every emotion counts.*

</div>