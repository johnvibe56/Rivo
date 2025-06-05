import 'package:flutter/material.dart';
import 'package:rivo/l10n/app_localizations.dart';

/// A utility class containing static methods for form field validation.
class ValidationUtils {
  ValidationUtils._(); // Prevent instantiation

  static String? validateEmail(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.validationRequired;
    }

    final regex = RegExp(r"^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$");
    if (!regex.hasMatch(value)) {
      return AppLocalizations.of(context)!.validationEmailInvalid;
    }

    return null;
  }

  static String? validatePassword(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.validationRequired;
    }

    if (value.length < 8) {
      return AppLocalizations.of(context)!.validationPasswordTooShort;
    }

    return null;
  }

  static String? validateUsername(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.validationRequired;
    }

    if (value.length < 3) {
      return AppLocalizations.of(context)!.validationUsernameTooShort;
    }

    final regex = RegExp(r"^[a-zA-Z0-9_]+$");
    if (!regex.hasMatch(value)) {
      return AppLocalizations.of(context)!.validationUsernameInvalid;
    }

    return null;
  }

  static String? validateNotEmpty(BuildContext context, String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      if (fieldName != null) {
        return '${AppLocalizations.of(context)!.validationRequired} $fieldName';
      }
      return AppLocalizations.of(context)!.validationRequired;
    }
    return null;
  }

  static String? validateBio(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Bio is optional
    }
    if (value.length > 200) {
      return AppLocalizations.of(context)!.validationBioTooLong;
    }
    return null;
  }

  static String? validateUsernameAvailability(
    BuildContext context, 
    String? value, 
    bool isAvailable,
  ) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.validationRequired;
    }
    if (!isAvailable) {
      return AppLocalizations.of(context)!.usernameAlreadyTaken;
    }
    return null;
  }
}