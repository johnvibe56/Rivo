import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Fallback localizations class
class FallbackLocalizations {
  const FallbackLocalizations();
  
  // Date Formats
  String get dateFormat => 'MMM d, yyyy';
  String get dateFormatShort => 'MM/dd/yyyy';
  String purchasedOn(String date) => 'Purchased on $date';

  // Purchase History
  String get purchaseHistoryTitle => 'My Purchases';
  String get noPurchasesYet => 'No purchases yet';
  String get purchasesWillAppearHere => 'Your purchases will appear here';
  String get loadingPurchases => 'Loading purchases...';
  String get signInToViewHistory => 'Please sign in to view your purchase history';
  String get errorLoadingPurchases => 'Failed to load purchases';
  
  // Common
  String get retry => 'Retry';
  String get login => 'Login';
  String get noInternetConnection => 'No internet connection';
  String get noInternetConnectionMessage => 'Please check your internet connection and try again.';
  String get serverErrorMessage => 'Failed to load data. Please try again later.';
  String get reportIssue => 'Report Issue';
  String get goToLogin => 'Go to Login';
  String get unexpectedError => 'Unexpected Error';
  String get unexpectedErrorMessage => 'An unexpected error occurred. Please try again.';
  
  // Button labels
  String get retryButtonLabel => 'Retry';
  String get reportButtonLabel => 'Report Issue';
}

extension LocalizationExtension on BuildContext {
  FallbackLocalizations get l10n => const FallbackLocalizations();
}

class L10n {
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('he'),
  ];
}
