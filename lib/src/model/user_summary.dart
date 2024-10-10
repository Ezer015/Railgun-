import 'package:flutter/foundation.dart';

@immutable
class UserSummary {
  const UserSummary({
    required this.mid,
    required this.name,
    required this.face,
    required this.sign,
    this.tag,
  });

  factory UserSummary.fromJson(Map<String, Object?> json) => UserSummary(
        mid: json['mid'] as int,
        name: json['name'] as String,
        face: json['face'] as Uint8List,
        sign: json['sign'] as String,
        tag: json['tag'] as String?,
      );

  final int mid;
  final String name;
  final Uint8List face;
  final String sign;
  final String? tag;

  @override
  bool operator ==(Object other) {
    return other is UserSummary &&
        runtimeType == other.runtimeType &&
        mid == other.mid &&
        name == other.name &&
        face == other.face &&
        sign == other.sign &&
        tag == other.tag;
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      mid,
      name,
      face,
      sign,
      tag,
    );
  }
}
