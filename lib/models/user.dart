class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profilePicUrl;
  final bool isLoggedIn;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePicUrl,
    required this.isLoggedIn,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePicUrl,
    bool? isLoggedIn,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
