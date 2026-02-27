import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class FakeStoreService {
  static const String baseUrl = 'https://fakestoreapi.com';

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        body: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> signup(String email, String username, String password) async {
    try {
      // FakeStore API dummy POST to create user
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        body: {
          'email': email,
          'username': username,
          'password': password,
          'name': jsonEncode({'firstname': username, 'lastname': ''}),
          'address': jsonEncode({
            'city': 'kilcoole',
            'street': '7835 new road',
            'number': 3,
            'zipcode': '12926-3874',
            'geolocation': {'lat': '-37.3159', 'long': '81.1496'},
          }),
          'phone': '1-570-236-7033',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getUserProfile(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
