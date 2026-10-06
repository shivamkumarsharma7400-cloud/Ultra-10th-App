import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/mcq_test_model.dart';

class FirebaseService {
  static const String apiKey = "AIzaSyDsUT71IwjilStIPcP9GDwq_vtEOdMCxq0";
  static const String projectId = "ultra-10th-a5611";
  static const String authBaseUrl = "https://identitytoolkit.googleapis.com/v1/accounts";
  static const String firestoreBaseUrl =
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents";

  static const String _userSessionKey = "ultra_10th_student_session";

  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // -----------------------------------------
  // Session Storage
  // -----------------------------------------
  Future<void> saveUserSession(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userSessionKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(map);
        return _currentUser;
      } catch (e) {
        await clearUserSession();
      }
    }
    return null;
  }

  Future<void> clearUserSession() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
  }

  // -----------------------------------------
  // Authentication
  // -----------------------------------------
  Future<UserModel> signUp({
    required String name,
    required String mobile,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$authBaseUrl:signUp?key=$apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final msg = data['error']?['message'] ?? 'Sign up failed';
      throw _parseAuthError(msg);
    }

    final uid = data['localId'] as String;
    final idToken = data['idToken'] as String;

    final user = UserModel(
      uid: uid,
      email: email.trim(),
      name: name.trim(),
      mobile: mobile.trim(),
      role: 'student',
      idToken: idToken,
    );

    // Save in Firestore students collection (matches website schema)
    await saveStudentProfile(user);
    await saveUserSession(user);

    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$authBaseUrl:signInWithPassword?key=$apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final msg = data['error']?['message'] ?? 'Login failed';
      throw _parseAuthError(msg);
    }

    final uid = data['localId'] as String;
    final idToken = data['idToken'] as String;

    // Fetch profile from Firestore
    UserModel user;
    try {
      final profile = await getStudentProfile(uid, idToken);
      user = UserModel(
        uid: uid,
        email: email.trim(),
        name: profile['name'] ?? data['displayName'] ?? 'Student',
        mobile: profile['mobile'] ?? '',
        role: profile['role'] ?? 'student',
        idToken: idToken,
      );
    } catch (_) {
      user = UserModel(
        uid: uid,
        email: email.trim(),
        name: data['displayName'] ?? 'Student',
        role: 'student',
        idToken: idToken,
      );
    }

    await saveUserSession(user);
    return user;
  }

  Future<void> sendPasswordReset(String email) async {
    final url = Uri.parse('$authBaseUrl:sendOobCode?key=$apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestType': 'PASSWORD_RESET',
        'email': email.trim(),
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final msg = data['error']?['message'] ?? 'Failed to send password reset email';
      throw _parseAuthError(msg);
    }
  }

  // -----------------------------------------
  // Firestore Students Profile
  // -----------------------------------------
  Future<void> saveStudentProfile(UserModel user) async {
    final url = Uri.parse('$firestoreBaseUrl/students/${user.uid}');
    final body = {
      'fields': {
        'name': {'stringValue': user.name},
        'email': {'stringValue': user.email},
        'mobile': {'stringValue': user.mobile},
        'role': {'stringValue': user.role},
        'provider': {'stringValue': 'email'},
      }
    };

    final headers = {'Content-Type': 'application/json'};
    if (user.idToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${user.idToken}';
    }

    await http.patch(url, headers: headers, body: jsonEncode(body));
  }

  Future<Map<String, String>> getStudentProfile(String uid, String idToken) async {
    final url = Uri.parse('$firestoreBaseUrl/students/$uid');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final fields = data['fields'] as Map<String, dynamic>? ?? {};
      return {
        'name': fields['name']?['stringValue'] ?? '',
        'mobile': fields['mobile']?['stringValue'] ?? '',
        'role': fields['role']?['stringValue'] ?? 'student',
      };
    }
    return {};
  }

  // -----------------------------------------
  // Firestore MCQ Tests Fetching
  // -----------------------------------------
  Future<List<McqTest>> fetchMcqTests() async {
    final url = Uri.parse('$firestoreBaseUrl/mcq_tests?pageSize=100');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final documents = data['documents'] as List? ?? [];

      List<McqTest> tests = [];
      for (var doc in documents) {
        if (doc is Map<String, dynamic>) {
          tests.add(McqTest.fromFirestoreDoc(doc));
        }
      }
      return tests;
    } else {
      throw Exception('Failed to load MCQ tests from website server (${response.statusCode})');
    }
  }

  // Helper for friendly error messages
  String _parseAuthError(String code) {
    if (code.contains('EMAIL_EXISTS')) {
      return 'An account already exists with this email address.';
    } else if (code.contains('INVALID_LOGIN_CREDENTIALS') || code.contains('INVALID_PASSWORD')) {
      return 'Incorrect email or password. Please try again.';
    } else if (code.contains('USER_NOT_FOUND')) {
      return 'No account found with this email.';
    } else if (code.contains('WEAK_PASSWORD')) {
      return 'Password should be at least 6 characters.';
    } else if (code.contains('INVALID_EMAIL')) {
      return 'Please enter a valid email address.';
    } else if (code.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
      return 'Too many attempts. Please try again in a few moments.';
    }
    return 'Authentication error: $code';
  }
}
