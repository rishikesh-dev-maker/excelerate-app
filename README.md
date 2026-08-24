# Excelerate Mobile Learning Companion

Excelerate is a Flutter mobile application for discovering experiential-learning programs, viewing program details, enrolling, and sharing feedback. It is backed locally by a `json-server` mock REST API.

## Features

- Register and sign in with mock API accounts
- Browse the live program catalogue from the mock API
- Search programs and filter by Technology, Business, or Design
- View program duration, learning outcomes, progress, and learning journey
- Submit enrollment requests and feedback
- Persist a mock login token with `shared_preferences`
- Show loading, retry, validation, and network-error states

## Navigation

`Login` → `Home` → `Programs` → `Program Details` → `Enrollment` or `Feedback`

The Progress and Profile navigation items are reserved for future development.

## Project Structure

```text
excelerate-app/
├── Mobile/                         # Flutter application
│   ├── lib/
│   │   ├── core/api/                # HTTP client, endpoint configuration, errors
│   │   ├── models/                  # User, program, enrollment, feedback models
│   │   ├── repositories/            # API-backed data access
│   │   ├── screens/                 # Login, home, catalogue, forms, details
│   │   ├── services/                # Token storage and compatibility helpers
│   │   ├── theme/                   # App theme and branding
│   │   └── main.dart                # Application entry point and routes
│   └── pubspec.yaml
├── mock-api/                        # Local json-server REST API
│   ├── db.json                      # Mock users, programs, enrollments, feedback
│   ├── routes.json                  # API route configuration
│   └── package.json
└── README.md
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Node.js 16+
- An Android emulator, iOS Simulator, browser, or physical device

### 1. Start the mock API

```bash
cd mock-api
npm install
npm start
```

The API runs on `http://localhost:3000`.

### 2. Run the Flutter app

Open a second terminal:

```bash
cd Mobile
flutter pub get
flutter run
```

The app automatically uses:

- `http://localhost:3000` on Flutter web and iOS Simulator
- `http://10.0.2.2:3000` on Android Emulator

For a physical device, update the API base URL to your computer's local-network IP address.

## Demo Account

```text
Email: demo@excelerate.org
Password: Demo1234
```

You can also create an account from the registration screen. New users, enrollments, and feedback are saved to `mock-api/db.json`.

## Mock API Endpoints

| Endpoint | Purpose |
| --- | --- |
| `GET /programs` | Program catalogue |
| `GET /users?email=<email>` | Find a user during sign-in |
| `POST /users` | Register a user |
| `GET`, `POST /enrollments` | Retrieve or create enrollments |
| `GET`, `POST /feedback` | Retrieve or create feedback |

## Screenshots

![Login screen](image.png)
![Home dashboard](image-1.png)
![Programs catalogue](image-2.png)
![Program details](image-3.png)
![Enrollment flow](image-4.png)
![Feedback flow](image-5.png)
![alt text](image-6.png)
![alt text](image-7.png)
![alt text](image-8.png)
## Development Commands

```bash
cd Mobile
flutter analyze
flutter test
flutter format lib/ test/
```
