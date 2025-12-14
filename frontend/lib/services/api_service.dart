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

  Future<List<Imovel>> getImoveis() async {
    final response = await http.get(Uri.parse('$baseUrl/imoveis/'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Imovel.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar imóveis');
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

  Future<Map<String, dynamic>?> analisarVocacao(int imovelId, {int raio = 250}) async {
    final url = Uri.parse('$baseUrl/imoveis/$imovelId/analisar?raio=$raio');
    
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
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final url = Uri.parse('$baseUrl/dashboard');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erro no dashboard: ${response.body}');
        return {"total_imoveis": 0, "valor_patrimonio": 0.0, "potencial_receita": 0.0};
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return {"total_imoveis": 0, "valor_patrimonio": 0.0, "potencial_receita": 0.0};
    }
  }
  Future<Map<String, dynamic>> getFinanceOverview(int imovelId) async {
    final url = Uri.parse('$baseUrl/imoveis/$imovelId/overview');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Erro ao carregar financeiro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}