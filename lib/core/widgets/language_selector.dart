import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isRTL = locale.languageCode == 'he';
    
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (Locale selected) {
        ref.read(localeProvider.notifier).setLocale(selected);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: [
              const Icon(Icons.language, size: 20),
              const SizedBox(width: 8),
              const Text('English'),
              if (!isRTL) const Spacer(),
              if (locale.languageCode == 'en')
                const Icon(Icons.check, size: 20),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('he'),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              const Icon(Icons.language, size: 20),
              const SizedBox(width: 8),
              Text(
                'עברית',
                textDirection: TextDirection.rtl,
              ),
              if (isRTL) const Spacer(),
              if (locale.languageCode == 'he')
                const Icon(Icons.check, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}
