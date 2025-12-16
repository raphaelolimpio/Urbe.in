import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';
import '../models/imovel_model.dart';
import '../models/dashboard_model.dart';

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
      print('Erro de conexão (cadastrarUsuario): $e');
      return null;
    }
  }

  Future<List<Imovel>> getImoveis() async {
    final url = Uri.parse('$baseUrl/imoveis/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Imovel.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao carregar imóveis: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição getImoveis: $e');
      return [];
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
      print('Erro de conexão (cadastrarImovel): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> analisarVocacao(
    int imovelId, {
    int raio = 250,
  }) async {
    final url = Uri.parse('$baseUrl/imoveis/$imovelId/analisar?raio=$raio');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print('Erro na análise: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão (analisarVocacao): $e');
      return null;
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
      throw Exception('Erro de conexão (getFinanceOverview): $e');
    }
  }

  Future<DashboardResumo> getDashboardMetrics() async {
    final url = Uri.parse('$baseUrl/dashboard/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return DashboardResumo.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          'Falha ao carregar métricas do dashboard: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro ao carregar Dashboard: $e');
      return DashboardResumo(
        totalImoveis: 0,
        valorPatrimonio: 0.0,
        receitaMensalEstimada: 0.0,
        noiAnualTotal: 0.0,
        ativosSubperformando: 0,
      );
    }
  }
}
