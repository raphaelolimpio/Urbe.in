import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';
import '../models/imovel_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<Usuario?> cadastrarUsuario(Usuario usuario) async {
    final url = Uri.parse('$baseUrl/usuarios/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(usuario.toJson()),
      );

      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else {
        print('Erro ao cadastrar usuário: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return null;
    }
  }

  Future<Imovel?> cadastrarImovel(Imovel imovel) async {
    final url = Uri.parse('$baseUrl/imoveis/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(imovel.toJson()),
      );

      if (response.statusCode == 200) {
        return Imovel.fromJson(jsonDecode(response.body));
      } else {
        print('Erro ao cadastrar imóvel: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> analisarVocacao(int imovelId) async {
    final url = Uri.parse('$baseUrl/imoveis/$imovelId/analisar');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erro na análise: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return null;
    }
  }
  Future<List<Imovel>> buscarImoveis() async {
    final url = Uri.parse('$baseUrl/imoveis/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Imovel.fromJson(item)).toList();
      } else {
        print('Erro ao buscar imóveis: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return [];
    }
  }
}