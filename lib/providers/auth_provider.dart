import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    final loggedIn = prefs.getBool('is_logged_in') ?? false;

    if (userStr != null) {
      _currentUser = User.fromJson(jsonDecode(userStr));
      _isLoggedIn = loggedIn;
      notifyListeners();
    }
  }

  Future<bool> signup(String name, String username, String password) async {
    // In a real app, check if username exists. Here we just overwrite.
    final newUser = User(name: name, username: username, password: password);
    _currentUser = newUser;
    _isLoggedIn = true;
    
    await _saveUser();
    notifyListeners();
    return true;
  }

  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    
    if (userStr != null) {
      final storedUser = User.fromJson(jsonDecode(userStr));
      if (storedUser.username == username && storedUser.password == password) {
        _currentUser = storedUser;
        _isLoggedIn = true;
        await prefs.setBool('is_logged_in', true);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    notifyListeners();
  }

  Future<void> changePassword(String newPassword) async {
    if (_currentUser != null) {
      _currentUser = User(
        name: _currentUser!.name,
        username: _currentUser!.username,
        password: newPassword,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> _saveUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
      await prefs.setBool('is_logged_in', _isLoggedIn);
    }
  }
}
