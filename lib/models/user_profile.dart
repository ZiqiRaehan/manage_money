class UserProfile {
  final int? id;
  final String name;
  final String position;
  final String school;
  final String dream;
  final List<String> yearlyWishlist;
  final String? profileImagePath;

  UserProfile({
    this.id,
    required this.name,
    required this.position,
    required this.school,
    required this.dream,
    required this.yearlyWishlist,
    this.profileImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'school': school,
      'dream': dream,
      'yearlyWishlist': yearlyWishlist.join(','),
      'profileImagePath': profileImagePath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      school: map['school'],
      dream: map['dream'],
      yearlyWishlist: map['yearlyWishlist'].toString().split(',').where((s) => s.isNotEmpty).toList(),
      profileImagePath: map['profileImagePath'],
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? position,
    String? school,
    String? dream,
    List<String>? yearlyWishlist,
    String? profileImagePath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      school: school ?? this.school,
      dream: dream ?? this.dream,
      yearlyWishlist: yearlyWishlist ?? this.yearlyWishlist,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

// Default profile untuk pertama kali
UserProfile defaultProfile = UserProfile(
  name: 'Pengguna Baru',
  position: 'Pelajar',
  school: 'Sekolah',
  dream: 'Sukses',
  yearlyWishlist: [],
);