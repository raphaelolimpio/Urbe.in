import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/imovel_model.dart';
import '../services/api_service.dart';
import 'cadastro_imovel_screen.dart';
import 'detalhe_imovel_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  
  // Variáveis para guardar os dados
  late Future<List<Imovel>> _imoveisFuture;
  Map<String, dynamic> _metrics = {
    "total_imoveis": 0, 
    "valor_patrimonio": 0.0, 
    "potencial_receita": 0.0
  };

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    setState(() {
      _imoveisFuture = _apiService.buscarImoveis();
    });
    // Carrega as métricas separadamente
    _apiService.getDashboardMetrics().then((dados) {
      setState(() {
        _metrics = dados;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Urbe.in Investimentos', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF00C853),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarDados,
          )
        ],
      ),
      body: Column(
        children: [
          // --- ÁREA DE CARDS FINANCEIROS (FASE 6) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _financeCard(
                        "Patrimônio Total", 
                        // BLINDAGEM: Se for nulo, usa 0
                        "R\$ ${(_metrics['valor_patrimonio'] ?? 0).toStringAsFixed(0)}",
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _financeCard(
                        "Receita Mensal (Est.)", 
                        // BLINDAGEM: Se for nulo, usa 0
                        "R\$ ${(_metrics['potencial_receita'] ?? 0).toStringAsFixed(0)}",
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "${_metrics['total_imoveis']} imóveis sob gestão",
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // --- LISTA DE IMÓVEIS ---
          Expanded(
            child: FutureBuilder<List<Imovel>>(
              future: _imoveisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Nenhum imóvel cadastrado.'),
                  );
                }

                final imoveis = snapshot.data!;
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: imoveis.length,
                  itemBuilder: (context, index) {
                    final imovel = imoveis[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.business, color: Color(0xFF00C853)),
                        ),
                        title: Text(imovel.titulo, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        subtitle: Text(imovel.enderecoCompleto, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetalheImovelScreen(imovel: imovel)),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? recarregar = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroImovelScreen()),
          );
          if (recarregar == true) _carregarDados();
        },
        backgroundColor: const Color(0xFF00C853),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Novo Imóvel', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _financeCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00C853), size: 28),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}