# Flutter Animated Login Package Architecture

## Project Structure

```
lib/
├── flutter_auth.dart                # Main package export
├── src/
│   ├── animations/                  # Animation classes
│   │   ├── card_flip.dart
│   │   ├── fade_slide.dart
│   │   └── loading_button.dart
│   ├── config/                      # Configuration classes
│   │   ├── auth_config.dart         # Main configuration
│   │   ├── login_config.dart        # Login options
│   │   ├── signup_config.dart       # Signup options
│   │   ├── reset_config.dart        # Password reset options
│   │   └── verify_config.dart       # OTP verification options
│   ├── constants/                   # App constants
│   │   ├── defaults.dart
│   │   ├── regex.dart
│   │   └── enums.dart
│   ├── controllers/                 # State controllers
│   │   ├── auth_controller.dart
│   │   ├── form_controller.dart
│   │   └── auth_state.dart
│   ├── l10n/                        # Localization
│   │   ├── arb/
│   │   │   ├── app_en.arb
│   │   │   └── app_es.arb
│   │   └── l10n.dart
│   ├── models/                      # Data models
│   │   ├── auth_data.dart
│   │   ├── user_data.dart
│   │   └── auth_result.dart
│   ├── theme/                       # Theming
│   │   ├── auth_theme.dart
│   │   ├── auth_theme_extension.dart
│   │   └── theme_defaults.dart
│   ├── utils/                       # Utility functions
│   │   ├── validation.dart
│   │   ├── responsive.dart
│   │   └── form_utils.dart
│   └── widgets/                     # UI components
│       ├── auth_card.dart           # Main card widget
│       ├── auth_flow.dart           # Main flow widget
│       ├── pages/
│       │   ├── login_page.dart
│       │   ├── signup_page.dart
│       │   ├── reset_page.dart
│       │   └── verify_page.dart
│       ├── fields/
│       │   ├── auth_button.dart
│       │   ├── email_field.dart
│       │   ├── password_field.dart
│       │   ├── phone_field.dart
│       │   └── pin_input.dart
│       ├── oauth/
│       │   ├── oauth_button.dart
│       │   └── providers.dart
│       └── common/
│           ├── auth_title.dart
│           ├── divider.dart
│           └── messages.dart
└── test/                           # Tests
    ├── unit/
    ├── widget/
    └── integration/
```

## Key Features

- **Clean Architecture** - Separation of concerns with clear layers
- **State Management** - Using Riverpod for predictable state
- **Responsive Design** - Adapts to all screen sizes
- **Smooth Animations** - Polished transitions between auth states
- **Comprehensive Theming** - Complete customization through ThemeExtensions
- **Localization Ready** - Full i18n support
- **Accessibility** - Built with a11y in mind
- **Performance Optimized** - Minimal rebuilds, efficient rendering