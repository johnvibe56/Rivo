import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rivo/l10n/app_localizations.dart';

class ProductFormValidator {
  static String? validateTitle(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.titleRequired;
    }
    return null;
  }

  static String? validateDescription(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.descriptionRequired;
    }
    return null;
  }

  static String? validatePrice(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.priceRequired;
    }
    
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return AppLocalizations.of(context)!.invalidPrice;
    }
    return null;
  }

  static String? validateImage(File? imageFile, BuildContext context) {
    if (imageFile == null) {
      return AppLocalizations.of(context)!.imageRequired;
    }
    return null;
  }
}
