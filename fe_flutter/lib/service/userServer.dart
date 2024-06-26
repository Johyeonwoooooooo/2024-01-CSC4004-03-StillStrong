import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fe_flutter/model/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> login(User user) async {
  try {
    final response = await http.post(
      Uri.parse('http://3.35.140.200:8080/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      Map<String, dynamic> responseData = jsonDecode(response.body);

      int userId = responseData['userId'];
      String cookieValue = responseData['cookieValue'];
      pref.setInt("userId", userId);

      var object = pref.get("userId");

      print('Received userId: $object');
      print('Received cookieValue: $cookieValue');

      return cookieValue;

    } else {
      print("Failed to login");
      return null;
    }
  } catch(e) {
    print("Failed to send user data: $e");
    return null;
  }
}

Future<void> join(User user) async {
  try {
    final response = await http.post(
      Uri.parse('http://3.35.140.200:8080/join'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      final SharedPreferences pref = await SharedPreferences.getInstance();

      int userId = responseData['userId'];
      String userNickname = responseData['userNickname'];
      String cookieValue = responseData['cookieValue'];
      pref.setInt("userId", userId);

      print('Received userId: $userId');
      print('Received userNickname: $userNickname');
      print('Received cookieValue: $cookieValue');
    } else {
      throw Exception("Failed to send data");
    }
  } catch(e) {
    print("Failed to send user data: $e");
  }
}

Future<void> patchFavorites(Map<String, dynamic> favorite) async {
  try {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt("userId");
    final response = await http.patch(
      Uri.parse('http://3.35.140.200:8080/user/register/favorite?userId=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(favorite),
    );

    if (response.statusCode == 200) {
      print('Favorites updated successfully.');
    } else {
      print('Failed to update favorites: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Failed to update favorites: $e');
  }
}

Future<List<String>> getAllergies() async {
  try {
    final response = await http.get(Uri.parse('http://3.35.140.200:8080/user/get/allergyList'));
    if (response.statusCode == 200) {
      final decodeData = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(decodeData);
      final List<String> allergies = List<String>.from(data['allergies']);
      return allergies;
    } else {
      throw Exception('Failed to get allergies : ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to get allergies: $e');
  }
}

Future<void> patchAllergies(Map<String, dynamic> allergy) async {
  try {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt("userId");
    final response = await http.patch(
      Uri.parse('http://3.35.140.200:8080/user/register/allergy?userId=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(allergy),
    );

    if (response.statusCode == 200) {
      print('Allergies updated successfully.');
    } else {
      print('Failed to update allergies: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Failed to update allergies: $e');
  }
}

Future<void> findPw(User user) async {
  try {
    final response = await http.post(
      Uri.parse('http://3.35.140.200:8080/find-pw'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      print('Data posted successfully');
    } else {
      print('Failed to post data: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Failed to post data: $e');
  }
}

Future<void> updatePw(String updatePassword, String confirmPassword) async {
  try {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt("userId");
    final Map<String, String> requestBody = {
      'updatePassword': updatePassword,
      'confirmPassword': confirmPassword,
    };

    final response = await http.post(
      Uri.parse('http://3.35.140.200:8080/update-pw?userId=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      print('Password updated successfully.');
    } else {
      print('Failed to update password: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Failed to update password: $e');
  }
}

Future<User> getUserInfo() async {
  try {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt("userId");

    final response = await http.get(
      Uri.parse('http://3.35.140.200:8080/user/get/detail?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return User.fromJson(jsonData);
    } else {
      throw Exception('Failed to get userinfo : ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to get userinfo: $e');
  }
}

Future<void> patchUser(User user) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  int? userId = pref.getInt("userId");
  String uri = 'http://3.35.140.200:8080/user/update?userId=$userId';
  print(uri);

  final request = await http.patch(
    Uri.parse(uri),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode(user.toJsonForEdit()),
  );
  print('statusCode : ${request.statusCode}');
  if (request.statusCode == 200) {
    print('Patch successful');
  } else {
    throw Exception('Failed to patch data');
  }
}

Future<void> logout() async {
  try {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt("userId");
    final response = await http.get(
      Uri.parse('http://3.35.140.200:8080//logout?userId=${userId}'),
    );

    if (response.statusCode == 200) {
      print('logout 완료');
    } else {
      throw Exception('Failed to logout : ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error : $e');
  }
}