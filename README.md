# Borderless, Blog & Messaging Flutter App

A Flutter application serving as the frontend for a Django-powered blog and real-time messaging platform. Features include blog posting, real-time chat, friend management, and user authentication.

## Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
- [Usage](#usage)
- [API Integration](#api-integration)
- [Real-Time Messaging](#real-time-messaging)
- [Localization](#localization)
- [Notification](#notification)
- [Goals](#goals)
- [Contributing](#contributing)
- [License](#license)

## Features
- **Blog Posts**: View, create, and manage blog posts.
- **Real-Time Messaging**: Chat with friends instantly via WebSockets.
- **Friend System**: Search for users, send friend requests, and manage friends.
- **User Authentication**: Log in, register, and log out with secure token-based auth.
- **Cross-Platform**: Works on Android, iOS, and web.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Networking**: HTTP package for API calls, WebSocket for real-time messaging
- **Backend**: Django (REST API + WebSockets via Channels)
- **Dependencies**: See `pubspec.yaml`

## Project Structure
```bash
lib/
├── api/                       # API-related files for backend communication
│   ├── api_endpoint.dart      # Defines API endpoints
│   ├── api_service.dart       # Handles HTTP requests to the Django backend
│   ├── auth_manager.dart      # Manages authentication
│   ├── login_api.dart         # API calls for login functionality
│   ├── logout.dart            # API calls for logout functionality
│   ├── websocket_api.dart     # WebSocket connection setup
│   └── websocket_service.dart # WebSocket service for real-time messaging
├── components/                # Reusable UI components
│   ├── account_drawer.dart    # Drawer for account navigation
│   ├── btn_send_comment.dart  # Button for sending comments on posts
│   ├── home.dart              # Home screen widget
│   ├── post_container.dart    # Widget for displaying a post
│   ├── reply.dart             # Widget for displaying a comment reply
│   └── reply_to_user.dart     # Widget for replying to a user in comments
├── l10n/
│   ├── app_en.arb  # English translations
│   ├── app_vi.arb  # Vietnamese translations
│   ├── app_zh_CN.arb  # Chinese simplified translations
│   ├── app_zh_TW.arb  # Chinese traditional translations
│   └── app_zh.arb  # Chinese translations
├── model/                     # Data models for the app
│   ├── chat_history.dart      # Model for chat history
│   ├── chat_list.dart         # Model for chat list
│   ├── chatlist_with_msg.dart # Model for chat list with messages
│   ├── friend_request_status.dart # Model for friend request status
│   ├── friend_request.dart    # Model for friend requests
│   ├── notification.dart      # Model for notifications
│   ├── post_comment.dart      # Model for post comments
│   ├── post_image.dart        # Model for post images
│   ├── post_video.dart        # Model for post videos
│   ├── posts.dart             # Model for blog posts
│   └── user_profile.dart      # Model for user profiles
├── provider/                  # State management using Provider
│   ├── chat_history_provider.dart # Provider for chat history state
│   ├── friend_request_provider.dart # Provider for friend request state
│   ├── language_provider.dart # Provider for language selection
│   ├── snack_bar.dart         # Provider for snack bar notifications
│   └── user_profile_provider.dart # Provider for user profile state
├── screens/                   # UI screens of the app
│   ├── account/               # Account-related screens
│   │   ├── register.dart      # Registration screen
│   │   ├── settings.dart      # Settings screen
│   │   ├── update_user.dart   # Screen to update user profile
│   │   ├── user_details.dart  # Screen to view user details
│   │   └── user_profile_page.dart # User profile page
│   ├── chat/                  # Chat-related screens
│   │   ├── chat_list.dart     # Screen to list all chats
│   │   └── chat_page.dart     # Screen for chatting with a friend
│   ├── friends/               # Friend-related screens
│   │   ├── friend_request.dart # Screen to manage friend requests
│   │   ├── friends_list.dart   # Screen to list friends
│   │   └── search_friend.dart  # Screen to search for friends
│   ├── posts/                 # Post-related screens
│   │   ├── create_post.dart   # Screen to create a new post
│   │   ├── friend_post.dart    # Screen to view friends' posts
│   │   ├── home_page.dart     # Home page with all posts
│   │   ├── post_details.dart  # Screen to view post details
│   │   ├── public_post.dart   # Screen to view public posts
│   │   └── login.dart         # Login screen
│   └── theme/                 # Theme-related files
│       ├── dark_theme.dart    # Dark theme configuration
│       ├── light_theme.dart   # Light theme configuration
│       └── theme_provider.dart # Theme provider for switching themes
├── utils/                     # Utility functions and helpers
│   ├── audio_controller.dart  # Controller for audio playback
│   ├── expandable_text.dart   # Utility for expandable text
│   ├── format_date.dart       # Utility to format dates
│   ├── friend_service.dart    # Service for friend-related operations
│   ├── gen_thumbnail.dart     # Utility to generate thumbnails
│   ├── image_preview.dart     # Utility for image previews
│   ├── is_loading.dart        # Utility to manage loading states
│   ├── language_selection.dart # Utility for language selection
│   ├── local_manager.dart     # Utility for local storage management
│   ├── login_helper.dart      # Helper for login functionality
│   ├── notification_controller.dart # Controller for notifications
│   ├── notification_manager.dart # Manager for notification handling
│   ├── page_animation.dart    # Utility for page transition animations
│   ├── pixel_placeholder.dart # Utility for placeholder images
│   ├── snack_bar.dart         # Utility for snack bar notifications
│   └── utils.dart             # General utility functions
└── main.dart                  # App entry point
```
## Setup Instructions

### Prerequisites
- **Flutter SDK**: Version 3.0+ (install from [flutter.dev](https://flutter.dev))
- **Dart**: Included with Flutter
- **IDE**: Android Studio / VS Code with Flutter plugins
- **Emulator/Device**: Android Emulator, iOS Simulator, or physical device
- **Backend**: Running Django server (see [Django Backend Repo](https://github.com/jacekong/Borderless-api.git))

### Installation
1. **Clone the Repository:**
   ```bash
   git clone https://github.com/jacekong/Borderless.git
   cd blog_messaging_flutter

2. **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3. **Configure Environment: Create a .env file**
    ```bash
    apiEndpoint=http://127.0.0.1:8000
    websocketEnpoint=ws://127.0.0.1:8000/
    ```

## Running the App
1. Start the Django Backend: Ensure your Django server is running (python manage.py runserver).
2. Launch the App
    ```bash
    flutter run
    ```

## Usage
- Login/Register: Enter credentials to access features.
- Blog: Tap "Posts" to view or create posts.
- Chat: Select a friend from the "Friend list" tab to start chatting.
- Friends: Use "Find Friends" to search and add users.

## API Integration
The app communicates with the Django backend via REST API and WebSockets:
- Base URL: Configured in .env file
- Endpoints: (see [Django Backend Repo](https://github.com/jacekong/Borderless-api.git))
- Authentication: Uses JWT or token-based auth (stored securely in SharedPreferences).

## Real-Time Messaging
- Implemented with WebSockets using the web_socket_channel package.
- Connects to ws://<backend-url>/ws/chat/<str:user_id>/.
- Messages are sent and received in real-time, displayed in the chat screen.

## Localization
The app supports multiple languages using Flutter's flutter_localizations package.

- Supported Languages: English (en), Vietnamese (vi) Chinese.
- Implementation:
    - Translation files are in the l10n/ directory (e.g., app_en.arb).
    - Generated localization classes are in generated/l10n.dart.
    - Language selection is managed by utils/language_provider.dart and utils/language_selection.dart.
- Usage:
    - Change the language in the settings.dart screen using the LanguageSelection widget.
    - Access localized strings using AppLocalizations.of(context)!.key (e.g., AppLocalizations.of(context)!.appTitle).

- Adding a New Language:
    1. Create a new ARB file in l10n/ (e.g., app_es.arb for Spanish).
    2. Add translations following the format of existing ARB files.
    3. Update language_provider.dart to support the new language code.
    4. Run flutter gen-l10n to regenerate localization classes.

## Notification
- Connects to ws://<backend-url>/ws/notifications/.

## Goals
The primary goal is to complete the development of this project and ensure all planned features are fully implemented. Key objectives include:
- Complete Core Features:
    - Finalize the blog posting, real-time messaging, and friend management functionalities.
    - Ensure all screens (e.g., home_page.dart, chat_page.dart, friend_request.dart) are fully functional and bug-free.
- Token Refresh for Logged-In Users:
    - Implement token refreshing in api/auth_manager.dart to automatically refresh the authentication token for logged-in users before it expires.
    - Update the Django backend to provide a refresh token endpoint (e.g., POST /api/token/refresh/).
    - Ensure seamless user experience without requiring re-login when the token expires.
- Adjust UI for Audio Recording:
    - Enhance the UI for audio recording in the chat feature (chat_page.dart).
    - Use utils/audio_controller.dart to improve the audio recording experience, such as adding a visual waveform, recording timer, and play/pause buttons.
    - Ensure the UI is intuitive and responsive across different devices.
- Polish and Test:
    - Conduct thorough testing on Android, iOS, and web platforms to ensure cross-platform compatibility.
    - Fix any UI/UX issues, such as alignment, padding, or responsiveness, especially in post_container.dart and chat_page.dart.
    - Add unit tests for critical components (e.g., api_service.dart, auth_manager.dart).
    
## Contributing
- Fork the repository.
- Create a feature branch (git checkout -b feature-branch).
- Commit your changes (git commit -m "Add feature").
- Push to the branch (git push origin feature-branch).
- Open a pull request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.