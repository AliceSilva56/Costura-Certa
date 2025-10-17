import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static const String _userBoxName = 'user_box_v1';
  static const String _kName = 'name';
  static const String _kPin = 'pin';
  static const String _kRemember = 'rememberMe';
  static const String _kLoggedIn = 'loggedIn';

  static AuthService? _instance;
  Box? _userBox;

  AuthService._();

  static AuthService get instance => _instance ??= AuthService._();

  Future<void> init() async {
    if (!Hive.isBoxOpen(_userBoxName)) {
      _userBox = await Hive.openBox(_userBoxName);
    } else {
      _userBox = Hive.box(_userBoxName);
    }
  }

  Future<bool> isLoggedIn() async {
    await _ensureReady();
    final remember = _userBox!.get(_kRemember, defaultValue: false) as bool;
    final loggedIn = _userBox!.get(_kLoggedIn, defaultValue: false) as bool;
    return remember && loggedIn;
  }

  Future<void> login({required String name, String? pin, required bool rememberMe}) async {
    await _ensureReady();
    await _userBox!.put(_kName, name);
    if (pin != null && pin.isNotEmpty) {
      await _userBox!.put(_kPin, pin);
    } else {
      await _userBox!.delete(_kPin);
    }
    await _userBox!.put(_kRemember, rememberMe);
    await _userBox!.put(_kLoggedIn, true);
  }

  Future<void> logout() async {
    await _ensureReady();
    await _userBox!.put(_kLoggedIn, false);
  }

  Future<void> clearAll() async {
    await _ensureReady();
    await _userBox!.clear();
  }

  Future<String?> getUserName() async {
    await _ensureReady();
    return _userBox!.get(_kName) as String?;
  }

  Future<bool> getRememberMe() async {
    await _ensureReady();
    return _userBox!.get(_kRemember, defaultValue: false) as bool;
  }

  Future<bool> validatePin(String? pin) async {
    await _ensureReady();
    if (pin == null) return true;
    final saved = _userBox!.get(_kPin) as String?;
    if (saved == null || saved.isEmpty) return true;
    return saved == pin;
  }

  Future<String?> getPin() async {
    await _ensureReady();
    return _userBox!.get(_kPin) as String?;
  }

  Future<void> setUserName(String name) async {
    await _ensureReady();
    await _userBox!.put(_kName, name);
  }

  Future<void> setPin(String? pin) async {
    await _ensureReady();
    if (pin == null || pin.isEmpty) {
      await _userBox!.delete(_kPin);
    } else {
      await _userBox!.put(_kPin, pin);
    }
  }

  Future<void> _ensureReady() async {
    if (_userBox == null) {
      await init();
    }
  }
}