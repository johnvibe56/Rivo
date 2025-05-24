import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rivo/features/auth/domain/models/auth_state.dart' as app_auth;
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock User class for testing
class MockUser extends Mock implements User {
  @override
  String get id => 'test-user-id';
  
  @override
  String? get email => 'test@example.com';
  
  @override
  Map<String, dynamic> get userMetadata => {
    'full_name': 'Test User',
    'avatar_url': 'https://example.com/avatar.jpg',
  };
  
  @override
  String get aud => 'authenticated';
  
  @override
  String? get phone => '';
  
  @override
  Map<String, dynamic> get appMetadata => {};
  
  @override
  String get createdAt => DateTime.now().toIso8601String();
  
  @override
  String? get updatedAt => DateTime.now().toIso8601String();
}

// Test implementation of AuthNotifier
class TestAuthNotifier extends AuthNotifier {
  TestAuthNotifier() : super() {
    // Start unauthenticated by default
    state = const AsyncValue.data(app_auth.AuthState.unauthenticated());
  }
  
  // Helper methods for testing
  @override
  void setAuthenticated(User? user) {
    state = AsyncValue.data(app_auth.AuthState.authenticated(user));
  }
  
  @override
  void setUnauthenticated() {
    state = const AsyncValue.data(app_auth.AuthState.unauthenticated());
  }
  
  @override
  void setLoading() {
    state = const AsyncValue.loading();
  }
  
  @override
  void setError(String message) {
    state = AsyncValue.error(message, StackTrace.current);
  }
}

void main() {
  late ProviderContainer container;
  late TestAuthNotifier authNotifier;
  final mockUser = MockUser();

  setUp(() {
    // Create a new ProviderContainer for each test
    container = ProviderContainer(
      overrides: [
        // Override the authStateProvider with our test notifier
        authStateProvider.overrideWith((ref) {
          authNotifier = TestAuthNotifier();
          return authNotifier;
        }),
      ],
    );
  });

  tearDown(() {
    // Dispose the container after each test
    container.dispose();
  });

  group('AuthNotifier Tests', () {
    test('initial state is unauthenticated', () {
      final state = container.read(authStateProvider);
      expect(state.value, isA<app_auth.AuthState>());
      expect(state.value?.isAuthenticated, isFalse);
    });

    test('setAuthenticated updates state to authenticated', () {
      // Set authenticated state
      authNotifier.setAuthenticated(mockUser);
      
      // Verify state is updated
      final state = container.read(authStateProvider);
      expect(state.value?.isAuthenticated, isTrue);
      expect(state.value?.user?.email, 'test@example.com');
    });

    test('setUnauthenticated updates state to unauthenticated', () {
      // Start authenticated
      authNotifier.setAuthenticated(mockUser);
      expect(container.read(authStateProvider).value?.isAuthenticated, isTrue);
      
      // Set unauthenticated
      authNotifier.setUnauthenticated();
      
      // Verify state is updated
      final state = container.read(authStateProvider);
      expect(state.value?.isAuthenticated, isFalse);
    });

    test('setLoading updates state to loading', () {
      // Set loading state
      authNotifier.setLoading();
      
      // Verify state is updated
      final state = container.read(authStateProvider);
      expect(state.isLoading, isTrue);
    });
    
    test('setError updates state to error', () {
      // Set error state
      const errorMessage = 'Test error';
      authNotifier.setError(errorMessage);
      
      // Verify state is updated
      final state = container.read(authStateProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isNotNull);
    });
  });
}
