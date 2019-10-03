import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exceptiona.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  bool get isAuth {
    return _token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    // it mean the token is vailed
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }

    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyD5OZpkywGD5fvCuO9g1l7DU5LSweegoA0';

    try {
      final response = await http.post(url,
          body: json.encode(
            {
              'email': email,
              'password': password,
              'returnSecureToken': true,
            },
          ));

      final responData = await json.decode(response.body);

      if (responData['error'] != null) {
        throw HttpException(responData['error']['message']);
      }

      _token = responData['idToken'];
      _userId = responData['localId'];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(
          responData['expiresIn'],
        ),
      ));
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      final userData = json.encode({
        'token': _token,
        'user': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });

      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }

    // print(json.decode(response.body));
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'] ; 
     _userId = extractedUserData['user'] ;
     _expiryDate = expiryDate ; 

     notifyListeners() ;  
     _autoLogout() ; 
     return true ; 

  }

  Future<void> logout()  async{
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final  prefs = await SharedPreferences.getInstance(); 
    prefs.clear();
  }


  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
