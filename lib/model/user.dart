import 'dart:io';

import 'package:flutter/foundation.dart';

class User {
  String email;

  String firstName;

  String lastName;

  int credits;

  String userID;

  String profilePictureURL;

  String appIdentifier;

  User(
      {this.email = '',
      this.firstName = '',
      this.lastName = '',
      this.credits = 0,
      this.userID = '',
      this.profilePictureURL = ''})
      : appIdentifier =
            'Flutter Login Screen ${kIsWeb ? 'Web' : Platform.operatingSystem}';

  String fullName() => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
        email: parsedJson['email'] ?? '',
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        credits : parsedJson['credits'] ?? 0,
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'credits': credits,
      'id': userID,
      'profilePictureURL': profilePictureURL,
      'appIdentifier': appIdentifier
    };
  }
}
