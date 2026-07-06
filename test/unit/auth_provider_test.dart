import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:e_ticketing_helpdesk/features/auth/presentation/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  late ProviderContainer container;
  late AuthNotifier authNotifier;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        return null;
      }
      if (methodCall.method == 'write') {
        return null;
      }
      if (methodCall.method == 'delete') {
        return null;
      }
      if (methodCall.method == 'containsKey') {
        return false;
      }
      if (methodCall.method == 'readAll') {
        return <String, String>{};
      }
      return null;
    });

    container = ProviderContainer();
    authNotifier = container.read(authProvider.notifier);
  });

  tearDown(() {
    container.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('AuthNotifier', () {
    test('initial state is initial', () {
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.token, isNull);
      expect(state.role, 'user');
    });

    test('login with valid admin credentials returns true', () async {
      final result = await authNotifier.login(
        'msury@gmail.com',
        'suryagantengdewe',
      );
      expect(result, true);

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.token, 'mock_token_123');
      expect(state.role, 'admin');
    });

    test('login with helpdesk credentials sets role to helpdesk', () async {
      final result = await authNotifier.login(
        'helpdesk@gmail.com',
        'suryagantengdewe',
      );
      expect(result, true);

      final state = container.read(authProvider);
      expect(state.role, 'helpdesk');
    });

    test('login with user credentials sets role to user', () async {
      final result = await authNotifier.login(
        'user@gmail.com',
        'suryagantengdewe',
      );
      expect(result, true);

      final state = container.read(authProvider);
      expect(state.role, 'user');
    });

    test('login with wrong email returns false', () async {
      final result = await authNotifier.login(
        'wrong@gmail.com',
        'suryagantengdewe',
      );
      expect(result, false);

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.error);
    });

    test('login with wrong password returns false', () async {
      final result = await authNotifier.login('msury@gmail.com', 'wrongpass');
      expect(result, false);

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.error);
    });

    test('logout clears token and sets unauthenticated', () async {
      await authNotifier.login('msury@gmail.com', 'suryagantengdewe');
      expect(container.read(authProvider).status, AuthStatus.authenticated);

      await authNotifier.logout();
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.token, isNull);
    });

    test('register with valid data returns true', () async {
      final result = await authNotifier.register(
        fullName: 'Test User',
        username: 'testuser',
        email: 'test@test.com',
        password: 'password123',
      );
      expect(result, true);

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
    });

    test('register with empty name returns false', () async {
      final result = await authNotifier.register(
        fullName: '',
        username: 'testuser',
        email: 'test@test.com',
        password: 'password123',
      );
      expect(result, false);

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.error);
    });

    test('clearError resets error message', () async {
      await authNotifier.login('wrong@gmail.com', 'suryagantengdewe');
      expect(container.read(authProvider).errorMessage, isNotEmpty);

      authNotifier.clearError();
      expect(container.read(authProvider).errorMessage, isNull);
    });

    test('resetPassword with valid email returns true', () async {
      final result = await authNotifier.resetPassword('test@test.com');
      expect(result, true);
    });

    test('resetPassword with invalid email returns false', () async {
      final result = await authNotifier.resetPassword('invalid');
      expect(result, false);
    });
  });
}
