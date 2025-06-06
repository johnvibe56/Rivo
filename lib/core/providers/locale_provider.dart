import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLocale() {
    state = state.languageCode == 'en' 
        ? const Locale('he') 
        : const Locale('en');
  }

  bool get isRTL => state.languageCode == 'he';
}
