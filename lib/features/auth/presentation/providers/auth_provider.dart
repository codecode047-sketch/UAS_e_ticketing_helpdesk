import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? token;
  final String role;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.token,
    this.role = 'user',
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? token,
    String? role,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _secureStorage;
  final AuthService _authService = AuthService();

  AuthNotifier(this._secureStorage) : super(const AuthState());

  Future<void> checkToken() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final role = await _secureStorage.read(key: 'user_role') ?? 'user';
    if (token != null && token.isNotEmpty) {
      state = AuthState(
        status: AuthStatus.authenticated,
        token: token,
        role: role,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final apiResult = await _authService.login(username, password);
      if (apiResult['success'] == true) {
        final role = apiResult['role'] as String? ?? 'user';
        final token = apiResult['token'] as String? ?? 'api_token_123';

        await _secureStorage.write(key: 'auth_token', value: token);
        await _secureStorage.write(key: 'user_role', value: role);

        state = AuthState(
          status: AuthStatus.authenticated,
          token: token,
          role: role,
        );
        return true;
      }
    } catch (_) {
      // API gagal, lanjut ke mock login
    }

    await Future.delayed(const Duration(milliseconds: 800));

    if (password != 'suryagantengdewe') {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Email atau password salah',
      );
      return false;
    }

    String role;
    if (username == 'msury@gmail.com') {
      role = 'admin';
    } else if (username == 'helpdesk@gmail.com') {
      role = 'helpdesk';
    } else if (username == 'user@gmail.com') {
      role = 'user';
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Email atau password salah',
      );
      return false;
    }

    final mockToken = 'mock_token_123';

    await _secureStorage.write(key: 'auth_token', value: mockToken);
    await _secureStorage.write(key: 'user_role', value: role);

    state = AuthState(
      status: AuthStatus.authenticated,
      token: mockToken,
      role: role,
    );
    return true;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'user_role');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    await Future.delayed(const Duration(milliseconds: 800));

    if (fullName.isEmpty || username.length < 4 || password.length < 6) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid registration data',
      );
      return false;
    }

    state = const AuthState(status: AuthStatus.unauthenticated);
    return true;
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid email address',
      );
      return false;
    }

    state = const AuthState(status: AuthStatus.unauthenticated);
    return true;
  }

  void clearError() {
    state = AuthState(status: state.status, token: state.token, role: state.role);
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});

final roleProvider = Provider<String>((ref) {
  return ref.watch(authProvider).role;
});
