import 'package:flutter/cupertino.dart';
import '../models/http_exception.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier{

  String _token;
  String _userId;
  DateTime _expiryTime;
  Timer _authTimer;


  bool get isAuth{
    return token != null;
  }

  String get userId{
    return _userId;
  }

  String get token{
    if (_expiryTime != null && _expiryTime.isAfter(DateTime.now()) && _token != null ){
      return _token;
    }
    return null;
  }


  Future<void> authenticate(String email,String password,String urlSegment) async{
    //TODO: urlSegment: sign up or log in ??.
    //ToDo: key = '' , from fireBase project in settings.
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAWVmkPvVQ0bqHi0vV9QQs1EIctc68eqEo';
    try{
      final response = await http.post(url,body:  json.encode({
        'email':email,
        'password': password,
        'returnSecureToken':true,
      }));

      final responseData = json.decode(response.body);
      if (responseData['error'] != null){
        throw HttpException(responseData['error']['message']);
      }
       _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryTime = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      autoLogOut();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token':_token,
        'expiryDate':_expiryTime.toIso8601String(),
        'userId':_userId,
      });
      prefs.setString('userData', userData);

    }catch(error){
      throw error;
    }

  }

  Future<bool> tryAutoLohIn() async{
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')){
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')) as Map<String , Object>;
    var expiryDate = DateTime.parse(extractedData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryTime = expiryDate;
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future<void> signup (String email , String password) async{
    return authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email , String password) async{
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logOut() async{
    _token = null;
    _userId = null;
    _expiryTime = null;
    if (_authTimer != null){
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogOut(){
    if (_authTimer != null){
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryTime.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry,),logOut);
  }

}