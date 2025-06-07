import 'package:intl/intl.dart';
import 'package:rivo/l10n/l10n.dart';
import 'package:flutter/material.dart';

class AppDateUtils {
  static String formatPurchaseDate(DateTime date, BuildContext context) {
    final format = DateFormat(
      Localizations.localeOf(context).languageCode == 'he' 
        ? 'd בMMM yyyy' 
        : 'MMM d, yyyy',
    );
    return format.format(date);
  }

  static String formatShortDate(DateTime date, BuildContext context) {
    final format = DateFormat(
      Localizations.localeOf(context).languageCode == 'he' 
        ? 'dd/MM/yyyy' 
        : 'MM/dd/yyyy',
    );
    return format.format(date);
  }

  static String getPurchasedOnText(String formattedDate, BuildContext context) {
    return context.l10n.purchasedOn(formattedDate);
  }
}
