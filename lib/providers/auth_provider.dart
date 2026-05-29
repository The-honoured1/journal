import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'storage_provider.dart';

class AuthNotifier extends StateNotifier<UserModel> {
  final Ref _ref;

  AuthNotifier(this._ref)
      : super(UserModel(
          uid: '',
          name: 'Jose Maria',
          email: 'jose.maria@solace.com',
          isLoggedIn: false,
        )) {
    _loadSession();
  }

  void _loadSession() {
    final session = _ref.read(storageServiceProvider).getUserSession();
    state = UserModel(
      uid: session['isLoggedIn'] ? 'cached-user-id' : '',
      name: session['name'],
      email: session['email'],
      profilePicUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80",
      isLoggedIn: session['isLoggedIn'],
    );
  }

  Future<void> login(String email, String password, String name) async {
    // Standard mock login validation for local storage flow
    state = UserModel(
      uid: 'user-id-123',
      name: name.isNotEmpty ? name : 'Jose Maria',
      email: email,
      profilePicUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80",
      isLoggedIn: true,
    );
    await _ref.read(storageServiceProvider).saveUserSession(state.name, state.email, true);
  }

  Future<void> register(String name, String email, String password) async {
    state = UserModel(
      uid: 'user-id-123',
      name: name,
      email: email,
      profilePicUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80",
      isLoggedIn: true,
    );
    await _ref.read(storageServiceProvider).saveUserSession(name, email, true);
  }

  Future<void> updateProfileName(String newName) async {
    state = state.copyWith(name: newName);
    await _ref.read(storageServiceProvider).saveUserSession(newName, state.email, state.isLoggedIn);
  }

  Future<void> logout() async {
    state = UserModel(
      uid: '',
      name: 'Guest',
      email: '',
      isLoggedIn: false,
    );
    await _ref.read(storageServiceProvider).clearUserSession();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel>((ref) {
  return AuthNotifier(ref);
});
