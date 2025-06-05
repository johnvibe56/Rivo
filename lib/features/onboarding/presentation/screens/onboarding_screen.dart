import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      titleKey: 'welcomeToRivo',
      descriptionKey: 'onboardingWelcomeDescription',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    const OnboardingPage(
      titleKey: 'onboardingBuySellTitle',
      descriptionKey: 'onboardingBuySellDescription',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    const OnboardingPage(
      titleKey: 'onboardingSafeTitle',
      descriptionKey: 'onboardingSafeDescription',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to sign up screen when done
      context.go('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: AppButton.text(
                onPressed: () => context.go('/signup'),
                label: AppLocalizations.of(context)!.skip,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _pages[index];
                },
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24.0 : 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.3), // ignore: deprecated_member_use
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: AppButton.primary(
                onPressed: _onNext,
                label: _currentPage == _pages.length - 1 
                    ? AppLocalizations.of(context)!.getStarted
                    : AppLocalizations.of(context)!.next,
                fullWidth: true,
              ),
            ),
            
            // Sign in link
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: AppButton.text(
                onPressed: () => context.go('/login'),
                label: AppLocalizations.of(context)!.alreadyHaveAnAccountSignIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String titleKey;
  final String descriptionKey;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.titleKey,
    required this.descriptionKey,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image (replace with actual asset)
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  margin: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1), // ignore: deprecated_member_use
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 120,
                    color: theme.colorScheme.primary.withOpacity(0.3), // ignore: deprecated_member_use
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            titleKey,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            descriptionKey,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8), // ignore: deprecated_member_use
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
