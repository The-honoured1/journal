import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'storage_provider.dart';

class AuthNotifier extends StateNotifier<UserModel> {
  final Ref _ref;

  AuthNotifier(this._ref)
      : super(UserModel(
          uid: '',
          name: 'Guest',
          email: 'guest@journal.com',
          profilePicUrl: 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=150&auto=format&fit=crop&q=80',
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
      profilePicUrl: session['profilePicUrl'],
      isLoggedIn: session['isLoggedIn'],
    );
  }

  Future<void> login(String email, String password, String name) async {
    state = UserModel(
      uid: 'user-id-123',
      name: name.isNotEmpty ? name : 'Guest',
      email: email,
      profilePicUrl: 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=150&auto=format&fit=crop&q=80',
      isLoggedIn: true,
    );
    await _ref.read(storageServiceProvider).saveUserSession(state.name, state.email, state.profilePicUrl ?? '', true);
  }

  Future<void> register(String name, String email, String profilePicUrl) async {
    state = UserModel(
      uid: 'user-id-123',
      name: name,
      email: email.isNotEmpty ? email : 'user@journal.com',
      profilePicUrl: profilePicUrl,
      isLoggedIn: true,
    );
    await _ref.read(storageServiceProvider).saveUserSession(name, state.email, profilePicUrl, true);
  }

  Future<void> updateProfileNameAndPic(String newName, String newPicUrl) async {
    state = state.copyWith(name: newName, profilePicUrl: newPicUrl);
    await _ref.read(storageServiceProvider).saveUserSession(newName, state.email, newPicUrl, state.isLoggedIn);
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
