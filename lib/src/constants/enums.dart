// File: src/constants/enums.dart

/// Available authentication pages
enum AuthPage {
  /// Login page
  login,
  
  /// Signup/registration page
  signup,
  
  /// Password reset page
  reset,
  
  /// OTP verification page
  verify,
}

/// Authentication providers for social login
enum AuthProvider {
  /// Google authentication
  google,
  
  /// Apple authentication
  apple,
  
  /// Facebook authentication
  facebook,
  
  /// Twitter authentication
  twitter,
  
  /// GitHub authentication
  github,
  
  /// Microsoft authentication
  microsoft,
  
  /// Custom provider
  custom,
}

/// Type of authentication field
enum AuthFieldType {
  /// Email field
  email,
  
  /// Phone number field
  phone,
  
  /// Username field
  username,
  
  /// Supports email and phone (adaptive)
  emailPhone,
}

/// Direction for card flip animations
enum FlipDirection {
  /// Horizontal left to right
  horizontal,
  
  /// Horizontal right to left
  horizontalReverse,
  
  /// Vertical top to bottom
  vertical,
  
  /// Vertical bottom to top
  verticalReverse,
}

/// Type of authentication
enum LoginType {
  /// OTP authentication (no password)
  otp,
  
  /// Password authentication 
  password,
  
  /// User can choose between OTP or password
  otpAndPassword,
}

/// Which authentication methods to support
enum LoginMethods {
  /// Email and password authentication
  emailPassword,
  
  /// Email with OTP verification
  emailOtp,
  
  /// Phone with OTP verification
  phoneOtp,
  
  /// Email or phone with password
  emailPhonePassword,
  
  /// Email or phone with OTP verification
  emailPhoneOtp,
  
  /// All methods available
  all,
}